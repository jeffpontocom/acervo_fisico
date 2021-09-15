import 'dart:ui';

import 'package:acervo_fisico/controllers/localizar_documento.dart';
import 'package:acervo_fisico/controllers/localizar_pacote.dart';
import 'package:acervo_fisico/controllers/novo_pacote.dart';
import 'package:acervo_fisico/main.dart';
import 'package:flutter/material.dart';

import 'login.dart';

enum contexto { documentos, pacotes }

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
  final List<Color> _cores = [Colors.green, Colors.lightBlue];

  // Variaveis para campo de busca
  String _searchText = '';
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

  void _localizar() {
    if (_contextoAtual == contexto.documentos.index) {
      LocalizarDocumento(context, _searchText);
    } else {
      LocalizarPacote(context, _searchText);
    }
  }

  void _novoPacote() {
    NovoPacote(context);
  }

  // METODOS DO SISTEMA
  @override
  void initState() {
    ///_isSelected = [true, false];
    //_searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          /* IconButton(
            onPressed: () => _loginOrLogout(),
            icon: Icon(Icons.person),
          ), */
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 32.0,
          children: <Widget>[
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(48.0),
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.5,
                      maxWidth: MediaQuery.of(context).size.width),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      _localizar();
                    },
                    textInputAction:
                        TextInputAction.search, // Lupa no teclado virtual
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
                      suffixIcon: _searchText.isNotEmpty
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
                          borderSide:
                              BorderSide(color: _cores[_contextoAtual])),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                ToggleButtons(
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
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (currentUser != null && !tecladoVisivel)
          ? FloatingActionButton(
              onPressed: () {
                _novoPacote();
              },
              tooltip: 'Novo pacote',
              child: Icon(Icons.add),
              backgroundColor: Colors.deepOrange.shade800,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  bool get tecladoVisivel {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }
}
