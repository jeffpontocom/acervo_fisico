import 'package:acervo_fisico/views/editar_pacote.dart';
import 'package:acervo_fisico/views/ver_pacote.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo físico',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
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
  int _contexto = 0; // 0: Documentos; 1: Pacotes

  // Variaveis para Botoes
  late List<bool> _isSelected;
  final List<Color> _cores = [Colors.blue, Colors.red];

  // Variaveis para campo de busca
  String _searchText = '';
  late TextEditingController _searchController;

  // METODOS DA APLICACAO
  void _localizarPacote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VerPacote()),
    );
  }

  void _novoPacote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarPacote()),
    );
  }

  // METODOS DO SISTEMA
  @override
  void initState() {
    _isSelected = [true, false]; //um boleano para cada botão
    _searchController = TextEditingController();
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
      // appBar: AppBar(
      //   title: Text('ENCA.DT'),
      // ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/icons/ic_launcher2.png'),
              height: 128,
              width: 128,
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            // ),
            Text(
              'Arquivo Técnico',
              style: TextStyle(
                fontSize: 18.0,
                //fontWeight: FontWeight.bold,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(2.0),
            // ),
            Text(
              'acervo físico',
              style: TextStyle(
                fontSize: 40.0,
                fontFamily: 'Baumans',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(48.0),
            ),
            Container(
              padding: EdgeInsets.all(24.0),
              constraints: BoxConstraints(minWidth: 100, maxWidth: 600),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  _localizarPacote();
                },
                textInputAction:
                    TextInputAction.search, // Lupa no teclado virtual
                decoration: InputDecoration(
                  labelText: "Localizar",
                  hintText: "Informe o código",
                  labelStyle: TextStyle(color: _cores[_contexto]),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _cores[_contexto],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: _cores[_contexto],
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
                      borderSide: BorderSide(color: _cores[_contexto])),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                            //size: 16.0,
                            //color: Colors.red,
                          ),
                          new SizedBox(
                            width: 4.0,
                          ),
                          new Text(
                            "DOCUMENTO",
                            //style: TextStyle(color: Colors.red),
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
                            //size: 16.0,
                            //color: Colors.blue,
                          ),
                          new SizedBox(
                            width: 4.0,
                          ),
                          new Text(
                            "PACOTE",
                            //style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      )),
                ],
                fillColor: _cores[_contexto],
                selectedColor: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                onPressed: (int index) {
                  setState(() {
                    _contexto = index;
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = i == index;
                    }
                  });
                },
                isSelected: _isSelected),
            Padding(
              padding: const EdgeInsets.all(16.0),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _novoPacote,
        tooltip: 'Novo pacote',
        child: Icon(Icons.add),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  //FIM
}
