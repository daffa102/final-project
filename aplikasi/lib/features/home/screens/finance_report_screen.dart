import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../pos/providers/pos_provider.dart';

class FinanceReportScreen extends StatelessWidget {
  const FinanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    
    // Calculate P&L
    double totalRevenue = pos.transactions.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['total_amount']?.toString() ?? '0') ?? 0));
    double totalGrossProfit = pos.transactions.fold(0.0, (sum, trx) => sum + (double.tryParse(trx['profit']?.toString() ?? '0') ?? 0));
    
    double otherIncome = pos.manualTransactions
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? '0') ?? 0));
        
    double otherExpenses = pos.manualTransactions
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + (double.tryParse(t['amount']?.toString() ?? '0') ?? 0));
        
    double netProfit = totalGrossProfit + otherIncome - otherExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laba Rugi & Operasional', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyiapkan Laporan PDF...'))
              );
              
              try {
                final apiService = context.read<PosProvider>().apiService;
                final response = await apiService.client.get(
                  '/finance/export',
                  options: Options(responseType: ResponseType.bytes),
                );

                  await Printing.layoutPdf(
                    onLayout: (_) => response.data,
                    name: 'Laporan-Keuangan.pdf',
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengekspor: $e')));
                  }
                }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Net Profit Card
            Card(
              color: netProfit >= 0 ? Colors.green.shade600 : Colors.red.shade600,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('ESTIMASI LABA BERSIH', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(netProfit),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Ringkasan Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFinanceRow('Pendapatan Penjualan', totalRevenue, currencyFormat, Colors.blue),
            _buildFinanceRow('Laba Kotor Penjualan', totalGrossProfit, currencyFormat, Colors.green),
            _buildFinanceRow('Pemasukan Lainnya', otherIncome, currencyFormat, Colors.teal),
            _buildFinanceRow('Pengeluaran / Biaya', otherExpenses, currencyFormat, Colors.red),
            const Divider(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Transaksi Manual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showAddTransactionDialog(context, pos),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                )
              ],
            ),
            
            if (pos.manualTransactions.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Belum ada data manual'),
              ))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pos.manualTransactions.length,
                itemBuilder: (context, index) {
                  final t = pos.manualTransactions[index];
                  final isIncome = t['type'] == 'income';
                  return ListTile(
                    leading: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? Colors.teal : Colors.red,
                    ),
                    title: Text(t['category']),
                    subtitle: Text(t['note'] ?? '-'),
                    trailing: Text(
                      '${isIncome ? "+" : "-"}${currencyFormat.format(double.tryParse(t['amount']?.toString() ?? '0') ?? 0)}',
                      style: TextStyle(
                        color: isIncome ? Colors.teal : Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, double amount, NumberFormat format, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(format.format(amount), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, PosProvider pos) {
    String type = 'expense';
    String category = '';
    double amount = 0;
    String note = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Transaksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                    DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                  decoration: const InputDecoration(labelText: 'Tipe'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Kategori (Misal: Listrik, Gaji)'),
                  onChanged: (v) => category = v,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal'),
                  onChanged: (v) => amount = double.tryParse(v) ?? 0,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Catatan'),
                  onChanged: (v) => note = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
            ElevatedButton(
              onPressed: () {
                if (category.isNotEmpty && amount > 0) {
                  pos.addManualTransaction(type: type, category: category, amount: amount, note: note);
                  Navigator.pop(context);
                }
              },
              child: const Text('SIMPAN'),
            )
          ],
        ),
      ),
    );
  }
}
