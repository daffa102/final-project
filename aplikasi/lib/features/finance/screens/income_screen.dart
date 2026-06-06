import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/finance_provider.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().fetchIncomes();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Pemasukan', style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text('Riwayat Pemasukan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          ),
          Expanded(
            child: finance.isLoading
                ? const Center(child: CircularProgressIndicator())
                : finance.incomes.isEmpty
                    ? const Center(child: Text('Belum ada data pemasukan'))
                    : ListView.builder(
                        itemCount: finance.incomes.length,
                        itemBuilder: (context, index) {
                          final item = finance.incomes[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withValues(alpha: 0.1),
                              child: const Icon(Icons.add_circle_outline, color: Colors.green),
                            ),
                            title: Text(
                              item['name']?.toString() ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item['income_date']?.toString() ?? ''),
                            trailing: Text(
                              currencyFormat.format(double.tryParse(item['amount'].toString()) ?? 0),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemasukan',
                    hintText: 'Misal: Tambah Modal, Piutang Masuk',
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama harus diisi' : null,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nominal',
                          prefixText: 'Rp ',
                        ),
                        validator: (v) => v!.isEmpty ? 'Nominal harus diisi' : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Tanggal'),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: const Text('SIMPAN PEMASUKAN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<FinanceProvider>().addIncome(
      name: _nameController.text,
      amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (success && mounted) {
      _nameController.clear();
      _amountController.clear();
      _noteController.clear();
      setState(() => _selectedDate = DateTime.now());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemasukan berhasil dicatat!'), backgroundColor: Colors.green),
      );
    }
  }
}
