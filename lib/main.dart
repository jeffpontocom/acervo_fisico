import 'dart:async';
import 'dart:developer' as dev;
import 'package:acervo_fisico/app_data.dart';
import 'package:acervo_fisico/views/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app_module.dart';
import 'models/documento.dart';
import 'models/pacote.dart';
import 'models/relatorio.dart';

/// Variavel global para receber de link de entrada (qrcode)
Uri? incomingLink;

void main() async {
  setPathUrlStrategy(); // remove o hash '#' das URLs
  WidgetsFlutterBinding.ensureInitialized();
  await Init.initialize();
  runApp(ModularApp(module: AppModule(), child: MyApp()));
}

class Init {
  static Future initialize() async {
    await dotenv.load();
    dev.log('Arquivo de chaves carregado: ${dotenv.isInitialized}',
        name: 'MAIN');
    await _registrarServicos();
    dev.log("Registro de serviços finalizado", name: 'MAIN');
  }

  /// Registra todos os serviços necessários a execução do sistema
  static _registrarServicos() async {
    // Iniciando Back4App/Parse
    final keyApplicationId = dotenv.env['Application_ID'] ?? '';
    final keyClientKey = dotenv.env['Client_ID'] ?? '';
    final keyParseServerUrl = dotenv.env['API_URL'] ?? '';
    await Parse().initialize(
      keyApplicationId,
      keyParseServerUrl,
      clientKey: keyClientKey, // Required for some setups
      debug: false, // When enabled, prints logs to console
      // Subclasses
      registeredSubClassMap: <String, ParseObjectConstructor>{
        Pacote.className: () => Pacote(),
        Documento.className: () => Documento(),
        Relatorio.className: () => Relatorio(),
      },
    );
    await AppData().init();
  }
}

/// Classe base para app
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  bool _initialUriIsHandled = false;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        incomingLink = uri;
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        incomingLink = null;
      });
    }
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      //_showSnackBar('_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (!mounted) return;
        if (uri == null) {
          print('Sem link de entrada');
        } else {
          print('Link de entrada: $uri');
        }
        incomingLink = uri;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri: ' + err.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo físico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'MavenPro',
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.accent,
          height: 48,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
            minimumSize: Size(64, 48),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(150, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
          ),
        ),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: !kReleaseMode,
    ).modular();
  }
}
