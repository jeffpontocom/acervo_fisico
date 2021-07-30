import 'package:acervo_fisico/controllers/localizar_documento.dart';
import 'package:acervo_fisico/controllers/localizar_pacote.dart';
//import 'package:acervo_fisico/views/editar_pacote.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

enum contexto { documentos, pacotes }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Iniciando Back4App
  final keyApplicationId = 'UJImpAAk0xdg1gB1OQtMf2bqEpe3aANxT6Sa2Vbp';
  final keyClientKey = 'ggHpKH2rUw3uwmchR4lj70gP84DWzFYnlrvJaSov';
  final keyParseServerUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);
  // Teste do Back4App
  /*
  final objectId = await savePerson();
  final person = await getPerson(objectId!);
  print('Person: ${person.toString()}');
  print('Name: ${person['name']}');
  print('Age: ${person['age']}');
  */
  // Iniciando Firebase
  //await Firebase.initializeApp();
  // Rodando o aplicativo
  runApp(MyApp());
}

/*
Future<String?> savePerson() async {
  final person = ParseObject('Person')
    ..set('name', "John Snow")
    ..set('age', 27);
  await person.save();
  return person.objectId;
}
*/

/*
//Reading your First Data Object from Back4App
Future<Map<String, dynamic>> getPerson(String objectId) async {
  QueryBuilder<ParseObject> queryPerson =
      QueryBuilder<ParseObject>(ParseObject('Person'))
        ..whereEqualTo('objectId', objectId);
  final ParseResponse apiResponse = await queryPerson.query();
  if (apiResponse.success && apiResponse.results != null) {
    final name = apiResponse.results!.first.get<String>('name');
    final age = apiResponse.results!.first.get<String>('age');
    return {'name': name, 'age': age};
  } else {
    return {};
  }
}
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo físico',
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
  late List<bool> _isSelected;
  final List<Color> _cores = [Colors.blue, Colors.red];

  // Variaveis para campo de busca
  String _searchText = '';
  late TextEditingController _searchController;

  // METODOS DA APLICACAO
  void _localizarPacote() {
    if (_contextoAtual == contexto.documentos.index) {
      LocalizarDocumento(context, _searchText);
    } else {
      LocalizarPacote(context, _searchText);
    }
  }

  void _novoPacote() {
    //Navigator.push(
    //  context,
    //  MaterialPageRoute(builder: (context) => EditarPacote()),
    //);
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
                      borderSide: BorderSide(color: _cores[_contextoAtual])),
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
