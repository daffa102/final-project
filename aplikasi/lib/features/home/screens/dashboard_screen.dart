import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Hijau di Wireframe (Big Box)
            Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.teal.shade200, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: const Text('Ringkasan Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            
            // Duo Box Warna-warni (Ungu & Pink di wireframe)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('Transaksi\n24', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(color: Colors.pink.shade100, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('Laba\nRp 1.2M', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bar Chart Box (Box Besar Biru Muda)
            Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.bar_chart, size: 64, color: Colors.blue)),
            ),
            const SizedBox(height: 16),
            
            // Info Tambahan (Box Biru Bawah)
            Container(
              height: 80,
              decoration: BoxDecoration(color: Colors.cyan.shade50, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('Notifikasi Stok Menipis', style: TextStyle(color: Colors.blueGrey))),
            ),
          ],
        ),
      ),
    );
  }
}
