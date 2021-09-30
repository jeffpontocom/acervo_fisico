import 'package:flutter/material.dart';

import '../controllers/localizar_documento.dart';
import '../controllers/localizar_pacote.dart';
import '../controllers/novo_pacote.dart';
import '../main.dart';
import '../util/utils.dart';
import '../views/pacote_page.dart';
import 'login.dart';
import 'perfil.dart';

enum contexto { documentos, pacotes }

class MyApp extends StatelessWidget {
  static const routeName = '/';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo físico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //visualDensity: VisualDensity.adaptivePlatformDensity,
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
      debugShowCheckedModeBanner: false,
      initialRoute: routeName,
      routes: <String, WidgetBuilder>{
        routeName: (BuildContext context) => new MyHomePage(),
        LoginPage.routeName: (BuildContext context) => new LoginPage(),
        UserPage.routeName: (BuildContext context) => new UserPage(),
        PacotePage.routeName: (BuildContext context) => new PacotePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /* VARIAVEIS */
  int _contextoAtual = contexto.documentos.index;
  List<bool> _isSelected = [true, false]; //um boleano para cada botão
  final List<Color> _cores = [Colors.grey.shade800, Colors.blue];
  final TextEditingController _controleBusca = TextEditingController();

  /* METODOS */

  /// Ir para a pagina de login ou logout dependendo do status da aplicacao
  void _loginOrLogout() async {
    final result;
    if (currentUser != null) {
      result = await Navigator.pushNamed(context, UserPage.routeName);
    } else {
      result = await Navigator.pushNamed(context, LoginPage.routeName);
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

  /* WIDGETS */

  Widget get logotipo {
    return Column(
      children: <Widget>[
        Image(
          image: AssetImage('assets/icons/ic_launcher.png'),
          height: 128,
          width: 128,
        ),
        Text(
          'Arquivo Técnico',
          style: TextStyle(
            fontSize: 18.0,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        Text(
          'acervo físico',
          style: TextStyle(
            fontSize: 40.0,
            fontFamily: 'Baumans',
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
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
        hintText: "Informe o código",
        labelStyle: TextStyle(color: _cores[_contextoAtual]),
        prefixIcon: Icon(
          Icons.search,
          color: _cores[_contextoAtual],
        ),
        filled: true,
        fillColor: Colors.white,
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
              Radius.circular(8.0),
            ),
            borderSide: BorderSide(color: _cores[_contextoAtual])),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
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
        borderRadius: BorderRadius.circular(8.0),
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

  /* METODOS DO SISTEMA */

  @override
  void dispose() {
    _controleBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black54,
        title: ListTile(
          title: Text(
              currentUser != null ? currentUser!.username! : 'Apenas consulta'),
          subtitle: Text(currentUser != null
              ? currentUser!.emailAddress!
              : 'Clique para realizar login'),
          dense: true,
          contentPadding: EdgeInsets.all(0),
          trailing: Icon(Icons.person_pin),
          visualDensity: VisualDensity.compact,
          onTap: () => _loginOrLogout(),
        ),
      ),
      body: Container(
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
              constraints: BoxConstraints(minWidth: 200, maxWidth: 600),
              child: Column(
                children: [
                  boxPesquisa,
                  SizedBox.square(dimension: 32),
                  boxSelectContexto,
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (currentUser != null && !Util.tecladoVisivel(context))
              ? FloatingActionButton.extended(
                  label: Text('Novo pacote'),
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _criarPacote();
                  },
                  heroTag: null,
                )
              : null,
    );
  }
}
