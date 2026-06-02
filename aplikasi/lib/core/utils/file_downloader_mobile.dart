import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(List<int> bytes, String fileName, String mimeType) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: mimeType)],
    text: fileName,
  );
}
