import 'dart:ui';

import 'package:acervo_fisico/controllers/localizar_documento.dart';
import 'package:acervo_fisico/controllers/localizar_pacote.dart';
import 'package:acervo_fisico/controllers/novo_pacote.dart';
import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/src/common.dart';
import 'package:flutter/material.dart';

import 'login.dart';

enum contexto { documentos, pacotes }
final _formKey = GlobalKey<FormState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo físico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // VARIAVEIS
  int _contextoAtual = contexto.documentos.index;

  // Variaveis para Botoes
  late List<bool> _isSelected = [true, false]; //um boleano para cada botão
  final List<Color> _cores = [Colors.red, Colors.blue];

  // Variaveis para campo de busca
  TextEditingController _searchController = TextEditingController();

  // METODOS DA APLICACAO
  void _loginOrLogout() {
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _localizar(String query) {
    if (_contextoAtual == contexto.documentos.index) {
      LocalizarDocumento(context, query);
    } else {
      LocalizarPacote(context, query);
    }
  }

  void _novoPacote() {
    NovoPacote(context);
  }

  Widget get logotipo {
    return Column(children: <Widget>[
      Image(
        image: AssetImage('assets/icons/ic_launcher2.png'),
        height: 128,
        width: 128,
      ),
      Text(
        'Arquivo Técnico',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
      Text(
        'acervo físico',
        style: TextStyle(
          fontSize: 40.0,
          fontFamily: 'Baumans',
        ),
      ),
    ]);
  }

  Widget get boxPesquisa {
    return TextFormField(
      key: _formKey,
      controller: _searchController,
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
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: _cores[_contextoAtual],
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
              )
            : null,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            borderSide: BorderSide(color: _cores[_contextoAtual])),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget get boxSelectContexto {
    return ToggleButtons(
      children: <Widget>[
        Container(
            width: 150,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.list_alt_rounded,
                ),
                new SizedBox(
                  width: 4.0,
                ),
                new Text(
                  "DOCUMENTO",
                )
              ],
            )),
        Container(
            width: 150,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.folder_rounded,
                ),
                new SizedBox(
                  width: 4.0,
                ),
                new Text(
                  "PACOTE",
                ),
              ],
            )),
      ],
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
      isSelected: _isSelected,
    );
  }

  // METODOS DO SISTEMA
  @override
  void dispose() {
    _searchController.dispose();
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
            boxPesquisa,
            boxSelectContexto,
          ],
        ),
      ),
      floatingActionButton: (currentUser != null && !tecladoVisivel(context))
          ? FloatingActionButton.extended(
              onPressed: () {
                _novoPacote();
              },
              label: Text('Novo pacote'),
              icon: Icon(Icons.add),
            )
          : null,
    );
  }
}
