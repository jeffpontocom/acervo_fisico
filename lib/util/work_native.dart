import 'dart:io';

import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> abrirArquivo(
    {required String fileName, required Uint8List pdfInBytes}) async {
  print('> Encontrando diretorio');
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  print('> Criando arquivo');
  final file = File(appDocPath + '/' + fileName);
  print('> Salvando como ${file.path} ...');
  await file.writeAsBytes(pdfInBytes);
  print('> Abrindo arquivo');
  OpenFile.open(file.path, type: 'application/pdf');
}
