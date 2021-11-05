import 'dart:io';

import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

void abrirArquivo(
    {required String fileName, required Uint8List pdfInBytes}) async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  final file = File(appDocPath + '/' + fileName);
  print('Save as file ${file.path} ...');
  await file.writeAsBytes(pdfInBytes);
  OpenFile.open(file.path, type: 'application/pdf');
}
