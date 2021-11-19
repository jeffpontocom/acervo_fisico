import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../controllers/docs_query.dart';
import '../controllers/pacote_query.dart';
import '../controllers/pacote_add.dart';
import '../models/documento.dart';
import '../models/pacote.dart';
import '../util/utils.dart';
import 'login.dart';
import 'perfil.dart';

enum ContextoBusca { documentos, pacotes }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /* VARIAVEIS */

  /// Contextuais
  ContextoBusca _contextoAtual = ContextoBusca.documentos;
  List<bool> _selecionado = [true, false]; //um boleano para cada botão
  final List<Color> _cores = [Colors.brown.shade600, Colors.blue.shade600];
  final TextEditingController _controleBusca = TextEditingController();

  /// Contadores
  ValueNotifier _totalDocs = ValueNotifier(0);
  ValueNotifier _totalPacotes = ValueNotifier(0);

  /* METODOS */

  /// Ir para a pagina de login ou logout dependendo do status da aplicacao
  void _acessarPerfil() async {
    final result;
    if (AppData.currentUser != null) {
      result = await Modular.to.pushNamed(UserPage.routeName);
    } else {
      result = await Modular.to.pushNamed(LoginPage.routeName);
    }
    // caso tenha realizado login ou logout com sucesso, recarregar a pagina
    if (result == true) {
      setState(() {});
    }
  }

  /// Localizar documentos ou pacotes dependendo do contexto selecionado
  void _localizar(String query) {
    if (_contextoAtual == ContextoBusca.documentos) {
      LocalizarDocumento(context, query);
    } else {
      LocalizarPacote(context, query);
    }
  }

  /// Abrir dialogo para criacao de pacote
  void _criarPacote() {
    NovoPacote(context);
  }

  /// Conta o total de documentos registrados no sistema
  _contarDocs() async {
    QueryBuilder<Documento> queryBuilder = QueryBuilder<Documento>(Documento());
    var apiResponse = await queryBuilder.count();
    if (apiResponse.success && apiResponse.result != null) {
      setState(() {
        _totalDocs.value = apiResponse.count;
      });
    }
  }

  /// Conta o total de pacotes registrados no sistema
  _contarPacotes() async {
    QueryBuilder<Pacote> queryBuilder = QueryBuilder<Pacote>(Pacote());
    var apiResponse = await queryBuilder.count();
    if (apiResponse.success && apiResponse.result != null) {
      setState(() {
        _totalPacotes.value = apiResponse.count;
      });
    }
  }

  /* WIDGETS */

  Widget get _appInfo {
    return Column(
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
        Text(
          '${AppData.version}',
          style: TextStyle(color: Colors.grey),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );
  }

  Widget get _boxPesquisa {
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
        labelStyle: TextStyle(color: _cores[_contextoAtual.index]),
        prefixIcon: Icon(
          Icons.search,
          color: _cores[_contextoAtual.index],
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: _controleBusca.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: _cores[_contextoAtual.index],
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
              color: _cores[_contextoAtual.index],
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

  Widget get _boxSelecaoContexto {
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
        isSelected: _selecionado,
        fillColor: _cores[_contextoAtual.index],
        selectedColor: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        onPressed: (int index) {
          setState(() {
            _contextoAtual = ContextoBusca.values[index];
            for (int i = 0; i < _selecionado.length; i++) {
              _selecionado[i] = i == index;
            }
          });
        },
      );
    });
  }

  /* METODOS DO SISTEMA */

  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _contarDocs();
    _contarPacotes();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controleBusca.dispose();
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
                  fontSize: 15,
                ),
              ),
              Text(
                AppData.currentUser?.username ?? 'Consulte livremente',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _acessarPerfil(),
              iconSize: 36,
              icon: Hero(
                tag: 'perfil',
                child: Image(
                  image: AssetImage(AppData.currentUser == null
                      ? 'assets/icons/private-key.png'
                      : 'assets/icons/data-management.png'),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
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
                      _appInfo,
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: 200, maxWidth: 450),
                        child: Column(
                          children: [
                            _boxPesquisa,
                            const SizedBox.square(dimension: 32),
                            _boxSelecaoContexto,
                          ],
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        child: Text(
                          _contextoAtual == ContextoBusca.documentos
                              ? '${Util.mNumFormat.format(_totalDocs.value)} documentos arquivados'
                              : '${Util.mNumFormat.format(_totalPacotes.value)} pacotes registrados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton:
            (AppData.currentUser != null && !Util.tecladoVisivel(context))
                ? FloatingActionButton.extended(
                    label: const Text(
                      'Novo pacote',
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    icon: const Icon(Icons.add),
                    backgroundColor: Colors.blue.shade900,
                    onPressed: () {
                      _criarPacote();
                    },
                    heroTag: null,
                  )
                : null);
  }
}
