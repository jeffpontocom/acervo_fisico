// ignore_for_file: avoid_web_libraries_in_flutter

//Usar na classe:
//import '../util/work_native.dart' if (dart.library.html) '../util/work_web.dart'
//    as util;

import 'dart:html';
import 'dart:typed_data';

Future<void> abrirArquivo(
    {required String fileName, required Uint8List pdfInBytes}) async {
  print('> Criando arquivo');
  final file = Blob([pdfInBytes], 'application/pdf');
  print('> Criando URL');
  final url = Url.createObjectUrlFromBlob(file);
  print('> Definindo link');
  final link = document.createElement('a') as AnchorElement
    ..href = url
    ..download = fileName;
  document.body?.append(link);
  print('> Acessando link');
  link.click();
  print('> Removendo link');
  link.remove();
  print('> Revogando URL');
  Url.revokeObjectUrl(url);
}
