import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfData;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111727) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E2938) : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87, size: 20.r),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Printing.sharePdf(bytes: pdfData, filename: '$title.pdf');
            },
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfData,
        useActions: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        maxPageWidth: MediaQuery.of(context).size.width * 0.9,
        loadingWidget: const Center(child: CircularProgressIndicator(color: Color(0xFFBEF364))),
        pdfPreviewPageDecoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
