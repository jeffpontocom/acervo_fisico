// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'dart:typed_data';

void abrirArquivo(
    {required String fileName, required Uint8List pdfInBytes}) async {
  final file = Blob([pdfInBytes], 'application/pdf');
  final url = Url.createObjectUrlFromBlob(file);
  final link = document.createElement('a') as AnchorElement
    ..href = url
    ..download = fileName;
  document.body?.append(link);
  link.click();
  link.remove();
  Url.revokeObjectUrl(url);
}
