import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController _cashController = TextEditingController();
  
  double _change = 0;
  String _paymentMethod = 'cash'; // Default metode pembayaran

  @override
  void initState() {
    super.initState();
    _cashController.text = '0';
  }

  void _calculateChange(double total) {
    double cash = double.tryParse(_cashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() {
      _change = cash - total;
    });
  }

  void _handlePay(PosProvider pos) async {
    double cash = double.tryParse(_cashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    
    // QRIS/Transfer logic: amountPaid is always exactly total
    if (_paymentMethod != 'cash') {
       cash = pos.cartTotal;
    }

    if (_paymentMethod == 'cash' && cash < pos.cartTotal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uang tunai kurang!')));
      return;
    }

    final success = await pos.processCheckout(
      paymentMethod: _paymentMethod, 
      amountPaid: cash
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaksi Berhasil! Tersimpan ke Database Opsional (Pending Sync)'),
        backgroundColor: Colors.green,
      ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(pos.error ?? 'Gagal memproses transaksi'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.watch<PosProvider>();
    final total = pos.cartTotal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pembayaran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const Divider(height: 32),
            
            // Total Tagihan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 16)),
                  Text(
                    currencyFormat.format(total), 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Pilihan Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMethodSelector(Icons.money, 'Cash', 'cash'),
                _buildMethodSelector(Icons.qr_code, 'QRIS', 'qris'),
                _buildMethodSelector(Icons.account_balance, 'Transfer', 'transfer'),
              ],
            ),
            const SizedBox(height: 24),

            // Input Uang Tunai (Hanya muncul jika tipe = Cash)
            if (_paymentMethod == 'cash') ...[
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Uang Diterima',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixText: 'Rp ',
                ),
                onChanged: (_) => _calculateChange(total),
              ),
              const SizedBox(height: 16),
              
              // Tampilan Kembalian
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian:', style: TextStyle(fontSize: 18)),
                  Text(
                    currencyFormat.format(_change > 0 ? _change : 0),
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: _change >= 0 ? Colors.green : Colors.red
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: pos.isLoading ? null : () => _handlePay(pos),
                child: pos.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('PROSES PEMBAYARAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector(IconData icon, String label, String value) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
          // Trigger kembalian = 0 kalo bukan cash
          if (value != 'cash') _change = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
