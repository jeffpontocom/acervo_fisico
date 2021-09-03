import 'package:acervo_fisico/views/home.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'models/documento.dart';
import 'models/pacote.dart';

const String TABLE_PACOTE = 'TestePacote';
const String TABLE_DOCUMENTO = 'TesteDocumento';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Iniciando Back4App
  final keyApplicationId = 'UJImpAAk0xdg1gB1OQtMf2bqEpe3aANxT6Sa2Vbp';
  final keyClientKey = 'ggHpKH2rUw3uwmchR4lj70gP84DWzFYnlrvJaSov';
  final keyParseServerUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey, // Required for some setups
    debug: true, // When enabled, prints logs to console
    // Subclasses
    registeredSubClassMap: <String, ParseObjectConstructor>{
      TABLE_PACOTE: () => Pacote(),
      TABLE_DOCUMENTO: () => Documento(),
    },
  );
  // Rodando o aplicativo
  runApp(MyApp());
}
