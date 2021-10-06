import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:url_strategy/url_strategy.dart';

import 'models/documento.dart';
import 'models/pacote.dart';
import 'models/relatorio.dart';
import 'views/home.dart';
import 'views/login.dart';
import 'views/pacote_page.dart';
import 'views/perfil.dart';

/// Variavel global para guardar atual usuario do sistema
ParseUser? currentUser;

void main() async {
  setPathUrlStrategy(); // remove o hash '#' das URLs
  WidgetsFlutterBinding.ensureInitialized();
  await Init.initialize();
  runApp(MyApp());
}

class Init {
  static Future initialize() async {
    await _registrarServicos();
    await _carregarConfiguracoes();
  }

  /// Registra todos os serviços necessários a execução do sistema
  static _registrarServicos() async {
    print("Registro de serviços iniciado");
    // Iniciando Back4App/Parse
    final keyApplicationId = 'UJImpAAk0xdg1gB1OQtMf2bqEpe3aANxT6Sa2Vbp';
    final keyClientKey = 'ggHpKH2rUw3uwmchR4lj70gP84DWzFYnlrvJaSov';
    final keyParseServerUrl = 'https://parseapi.back4app.com';
    await Parse().initialize(
      keyApplicationId,
      keyParseServerUrl,
      clientKey: keyClientKey, // Required for some setups
      // debug: true, // When enabled, prints logs to console
      // Subclasses
      registeredSubClassMap: <String, ParseObjectConstructor>{
        Pacote.TABLE_NAME: () => Pacote(),
        Documento.TABLE_NAME: () => Documento(),
        Relatorio.TABLE_NAME: () => Relatorio(),
      },
    );
    currentUser = await ParseUser.currentUser() as ParseUser?;
    print("Registro de serviços finalizado");
  }

  static _carregarConfiguracoes() async {
    print("Carregamento de configurações iniciado");
    print("Carregamento de configurações finalizado");
  }
}

/// Classe base para app
class MyApp extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo físico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.accent,
          height: 48,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(64, 48),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
            minimumSize: Size(64, 48),
          ),
        ),
      ),
      initialRoute: routeName,
      routes: <String, WidgetBuilder>{
        routeName: (BuildContext context) => new MyHomePage(),
        LoginPage.routeName: (BuildContext context) => new LoginPage(),
        UserPage.routeName: (BuildContext context) => new UserPage(),
        PacotePage.routeName: (BuildContext context) => new PacotePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
