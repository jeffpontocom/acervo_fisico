import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../main.dart';
import 'pacote_documentos.dart';
import 'pacote_localizacao.dart';

late Pacote mPacote;
ValueNotifier<bool> editMode = new ValueNotifier(false);
var refresh;

class PacotePage extends StatefulWidget {
  final Pacote pacote;

  PacotePage({Key? key, required this.pacote}) : super(key: key);

  @override
  _PacotePageState createState() => _PacotePageState();
}

class _PacotePageState extends State<PacotePage> {
  @override
  void initState() {
    mPacote = widget.pacote;
    editMode.value = false;
    refresh = () {
      setState(() {});
    };
    editMode.addListener(refresh);
    super.initState();
  }

  @override
  void dispose() {
    editMode.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mPacote.selado ? 'Pacote selado' : 'Pacote aberto',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              Text(
                '${mPacote.tipoToString}: ${mPacote.identificador}',
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              )
            ],
          ),
          actions: pacoteActions,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.place), text: "Localização"),
              Tab(icon: Icon(Icons.list_rounded), text: "Documentos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PacoteLocalizacao(parentCall: myCall),
            PacoteDocumentos(),
          ],
        ),
      ),
    );
  }

  VoidCallback? myCall() {
    setState(() {});
  }

  List<Widget> get pacoteActions {
    if (currentUser == null || editMode.value) {
      return [];
    } else {
      return [
        mPacote.selado
            ? TextButton.icon(
                onPressed: () {
                  setState(() {
                    abrirPacote();
                  });
                },
                icon: Icon(Icons.open_in_browser_rounded),
                label: Text('ABRIR'),
              )
            : TextButton.icon(
                onPressed: () {
                  setState(() {
                    selarPacote();
                  });
                },
                icon: Icon(Icons.verified_rounded),
                label: Text('SELAR'),
              ),
      ];
    }
  }

  void abrirPacote() {
    mPacote.updatedAct = UpdatedAction.ABRIR.index;
    mPacote.selado = false;
    mPacote.seladoBy = currentUser;
    mPacote.updatedAt = DateTime.now();
  }

  void selarPacote() {
    mPacote.updatedAct = UpdatedAction.SELAR.index;
    mPacote.selado = true;
    mPacote.seladoBy = currentUser;
    mPacote.updatedAt = DateTime.now();
  }
}
