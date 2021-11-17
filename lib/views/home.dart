import 'dart:async';

import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/customs.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../controllers/docs_query.dart';
import '../controllers/pacote_query.dart';
import '../controllers/pacote_add.dart';
import '../main.dart';
import '../util/utils.dart';
import 'login.dart';
import 'pacote_page.dart';
import 'perfil.dart';

enum contexto { documentos, pacotes }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /* VARIAVEIS */
  ValueNotifier totalDocs = ValueNotifier(0);
  ValueNotifier totalPacotes = ValueNotifier(0);

  /// Contextuais
  int _contextoAtual = contexto.documentos.index;
  List<bool> _isSelected = [true, false]; //um boleano para cada botão
  final List<Color> _cores = [Colors.brown.shade600, Colors.blue.shade600];
  final TextEditingController _controleBusca = TextEditingController();

  /// Conexão com a internet
  /* late StreamSubscription<ConnectivityResult> _subscription;
  SnackBar snackBar = new SnackBar(
    content: Text('Seja bem vindo!'),
  ); */

  /* METODOS */

  /// Atualiza status de conexao
  /* void _updateStatus(ConnectivityResult connectivityResult) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (connectivityResult == ConnectivityResult.mobile) {
      snackBar = SnackBar(
        content: Text('Conexão mobile estabelecida!'),
        backgroundColor: Colors.green.shade900,
      );
    } else if (connectivityResult == ConnectivityResult.wifi) {
      snackBar = SnackBar(
        content: Text('Conexão wifi estabelecida!'),
        backgroundColor: Colors.green.shade900,
      );
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      snackBar = SnackBar(
        content: Text('Conexão ethernet estabelecida!'),
        backgroundColor: Colors.green.shade900,
      );
    } else {
      snackBar = SnackBar(
        content: Text('Sem conexão com a internet!'),
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: Colors.red.shade900,
        duration: Duration(days: 365),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _irParaLinkEntrada(); //// teste
  } */

  /// Ir para a pagina de login ou logout dependendo do status da aplicacao
  void _loginOrLogout() async {
    final result;
    if (AppData.currentUser != null) {
      result = await Modular.to.pushNamed(UserPage.routeName);
      //result = await Navigator.pushNamed(context, UserPage.routeName);
    } else {
      result = await Modular.to.pushNamed(LoginPage.routeName);
      //result = await Navigator.pushNamed(context, LoginPage.routeName);
    }
    // caso tenha realizado login ou logout com sucesso, recarregar a pagina
    if (result == true) {
      setState(() {});
    }
  }

  /// Localizar documentos ou pacotes dependendo do contexto selecionado
  void _localizar(String query) {
    if (_contextoAtual == contexto.documentos.index) {
      LocalizarDocumento(context, query);
    } else {
      LocalizarPacote(context, query);
    }
  }

  /// Abrir dialogo para criacao de pacote
  void _criarPacote() {
    NovoPacote(context);
  }

  /// Ir para link de entrada
  void _irParaLinkEntrada() {
    if (incomingLink != null)
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final id = incomingLink?.queryParameters['id']!;
        incomingLink = null;
        print('Acessando por link de entrada - Pacote: $id');
        Navigator.pushNamed(context, PacotePage.routeName + '?id=$id');
      });
  }

  /* WIDGETS */

  Widget get logotipo {
    return Column(
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Image(
          image: AssetImage('assets/icons/ic_launcher.png'),
          height: 128,
          width: 128,
        ),
        const Text(
          'Arquivo Técnico',
          style: TextStyle(
            fontSize: 16.0,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        const Text(
          'Acervo físico',
          style: TextStyle(
              fontSize: 40.0,
              fontFamily: 'Baumans',
              fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        MyGreyText('${AppData.version}'),
      ],
    );
  }

  Widget get boxPesquisa {
    return TextFormField(
      key: null,
      controller: _controleBusca,
      onFieldSubmitted: (value) {
        _localizar(value);
      },
      textInputAction: TextInputAction.search, // Lupa no teclado virtual
      decoration: InputDecoration(
        labelText: "Localizar",
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: "Informe o código",
        labelStyle: TextStyle(color: _cores[_contextoAtual]),
        prefixIcon: Icon(
          Icons.search,
          color: _cores[_contextoAtual],
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: _controleBusca.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: _cores[_contextoAtual],
                ),
                onPressed: () {
                  setState(() {
                    _controleBusca.clear();
                  });
                },
              )
            : null,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
            borderSide: BorderSide(
              color: _cores[_contextoAtual],
              //style: BorderStyle.none,
            )),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
          borderSide: BorderSide(
            color: Colors.transparent,
            style: BorderStyle.none,
          ),
        ),
      ),
    );
  }

  Widget get boxSelectContexto {
    return LayoutBuilder(builder: (context, constraints) {
      return ToggleButtons(
        constraints: BoxConstraints(
          minWidth: (constraints.maxWidth - 30) / 2,
          maxWidth: (constraints.maxWidth - 30) / 2,
          minHeight: 48,
        ),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(
                Icons.list_alt_rounded,
              ),
              Text(
                "DOCUMENTO",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              )
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(
                Icons.folder_rounded,
              ),
              const Text(
                "PACOTE",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              )
            ],
          ),
        ],
        isSelected: _isSelected,
        fillColor: _cores[_contextoAtual],
        selectedColor: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        onPressed: (int index) {
          setState(() {
            _contextoAtual = index;
            for (int i = 0; i < _isSelected.length; i++) {
              _isSelected[i] = i == index;
            }
          });
        },
      );
    });
  }

  _contarDocs() async {
    QueryBuilder<Documento> queryBuilder = QueryBuilder<Documento>(Documento());
    var apiResponse = await queryBuilder.count();
    if (apiResponse.success && apiResponse.result != null) {
      setState(() {
        totalDocs.value = apiResponse.count;
      });
    }
  }

  _contarPacotes() async {
    QueryBuilder<Pacote> queryBuilder = QueryBuilder<Pacote>(Pacote());
    var apiResponse = await queryBuilder.count();
    if (apiResponse.success && apiResponse.result != null) {
      setState(() {
        totalPacotes.value = apiResponse.count;
      });
    }
  }

  /* METODOS DO SISTEMA */

  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    //_subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await _contarDocs();
    await _contarPacotes();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controleBusca.dispose();
    //_subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          shadowColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          toolbarHeight: 64,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Olá,',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppData.currentUser?.username ?? 'Consulte livremente',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _loginOrLogout(),
              iconSize: 36,
              icon: Image(
                image: AssetImage(AppData.currentUser == null
                    ? 'assets/icons/private-key.png'
                    : 'assets/icons/data-management.png'),
              ),
            ),
          ],
        ),
        body: Center(
          child: Scrollbar(
            isAlwaysShown: true,
            showTrackOnHover: true,
            hoverThickness: 18,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  runSpacing: 32,
                  spacing: 32,
                  children: [
                    logotipo,
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 200, maxWidth: 450),
                      child: Column(
                        children: [
                          boxPesquisa,
                          const SizedBox.square(dimension: 32),
                          boxSelectContexto,
                        ],
                      ),
                    ),
                    Text(
                      _contextoAtual == contexto.documentos.index
                          ? '${nformat.format(totalDocs.value)} documentos registrados'
                          : '${nformat.format(totalPacotes.value)} pacotes arquivados',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton:
            (AppData.currentUser != null && !Util.tecladoVisivel(context))
                ? FloatingActionButton.extended(
                    label: Text('Novo pacote'),
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _criarPacote();
                    },
                    heroTag: null,
                  )
                : null);
  }

  var nformat = NumberFormat.decimalPattern('pt_BR');
}
