import 'dart:async';
import 'package:acervo_fisico/app_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:url_strategy/url_strategy.dart';

import 'models/documento.dart';
import 'models/pacote.dart';
import 'models/relatorio.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

/// Variavel global para guardar atual usuario do sistema
ParseUser? currentUser;
// Variaveis para controle de links de entrada
Uri? incomingLink;

void main() async {
  setPathUrlStrategy(); // remove o hash '#' das URLs
  WidgetsFlutterBinding.ensureInitialized();
  await Init.initialize();
  runApp(ModularApp(module: AppModule(), child: MyApp()));
}

class Init {
  static Future initialize() async {
    await _registrarServicos();
    //await _carregarConfiguracoes();
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
      initialRoute: '/',
      /* routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new MyHomePage(),
        LoginPage.routeName: (BuildContext context) => new LoginPage(),
        UserPage.routeName: (BuildContext context) => new UserPage(),
        PacotePage.routeName: (BuildContext context) => new PacotePage(),
      }, */
      /* onGenerateRoute: (settings) {
        switch (settings.name) {
          case LoginPage.routeName:
            return MaterialPageRoute(builder: (context) => LoginPage());
          case UserPage.routeName:
            return MaterialPageRoute(builder: (context) => UserPage());
          case PacotePage.routeName:
            final pacoteId = settings.arguments as String;
            return MaterialPageRoute(
                settings: RouteSettings(name: '${settings.name}/?id=$pacoteId'),
                builder: (context) => PacotePage(mPacoteId: pacoteId));
          case '/':
          default:
            return MaterialPageRoute(builder: (context) => MyHomePage());
        }
      }, */
      debugShowCheckedModeBanner: false,
    ).modular();
  }
}
