import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/finance_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'operational';
  final DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _categories = [
    {'id': 'operational', 'label': 'Operasional'},
    {'id': 'salary', 'label': 'Gaji Karyawan'},
    {'id': 'purchase', 'label': 'Pembelian Stok'},
    {'id': 'other', 'label': 'Lain-lain'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildForm(),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.grey),
                SizedBox(width: 8.w),
                Text('Riwayat Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          ),
          Expanded(
            child: finance.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : finance.expenses.isEmpty
                ? const Center(child: Text('Belum ada data pengeluaran'))
                : ListView.builder(
                    itemCount: finance.expenses.length,
                    itemBuilder: (context, index) {
                      final item = finance.expenses[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          child: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        ),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['expense_date']} • ${item['category'].toString().toUpperCase()}'),
                        trailing: Text(
                          currencyFormat.format(double.parse(item['amount'].toString())),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Pengeluaran', hintText: 'Misal: Bayar Listrik'),
                  validator: (v) => v!.isEmpty ? 'Nama harus diisi' : null,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp '),
                        validator: (v) => v!.isEmpty ? 'Nominal harus diisi' : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: _categories.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['label']!))).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: const Text('SIMPAN PENGELUARAN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<FinanceProvider>().addExpense(
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text,
    );

    if (success && mounted) {
      _nameController.clear();
      _amountController.clear();
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengeluaran berhasil dicatat!'), backgroundColor: Colors.green));
    }
  }
}
