import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<Printer> _printers = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanPrinters();
  }

  Future<void> _scanPrinters() async {
    setState(() => _isScanning = true);
    try {
      final printers = await Printing.listPrinters();
      setState(() => _printers = printers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencari printer: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? null : _scanPrinters,
          )
        ],
      ),
      body: _printers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.print_disabled_outlined, size: 64.r, color: Colors.grey),
                   SizedBox(height: 16.h),
                   Text(_isScanning ? 'Mencari printer...' : 'Tidak ada printer ditemukan', style: TextStyle(color: Colors.grey)),
                   if (!_isScanning) ...[
                     SizedBox(height: 16.h),
                     ElevatedButton(onPressed: _scanPrinters, child: const Text('Cari Ulang'))
                   ]
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: _printers.length,
              itemBuilder: (context, index) {
                final printer = _printers[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  child: ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(printer.name),
                    subtitle: Text(printer.url),
                    trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Printer ${printer.name} terpilih sebagai default'))
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
