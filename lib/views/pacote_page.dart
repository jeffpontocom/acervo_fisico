import 'package:acervo_fisico/styles/customs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../controllers/relatorio_add.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../views/pacote_relatorios.dart';
import 'messages.dart';
import 'pacote_documentos.dart';
import 'pacote_localizacao.dart';

Pacote mPacote = Pacote();
ValueNotifier<bool> editMode = new ValueNotifier(false);
var refresh;

class PacotePage extends StatefulWidget {
  static const routeName = '/pacote';
  final String? mPacoteId;

  PacotePage({Key? key, required this.mPacoteId}) : super(key: key);

  @override
  _PacotePageState createState() => _PacotePageState();
}

class _PacotePageState extends State<PacotePage> {
  Future<Pacote> getPacote() async {
    QueryBuilder<Pacote> query = QueryBuilder<Pacote>(Pacote())
      ..whereEqualTo(keyVarObjectId, widget.mPacoteId)
      ..includeObject([Pacote.keySeladoBy, Pacote.keyUpdatedBy]);
    var response = await query.query();
    return response.results?.first as Pacote;
  }

  AppBar get appBar {
    return AppBar(
      leading: BackButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Modular.to.navigate('/');
          }
        },
      ),
      titleSpacing: 0,
      centerTitle: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título
          Text(
            mPacote.selado ? 'Pacote selado' : 'Pacote aberto',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          // Subtítulo
          Text(
            'ID: ${mPacote.identificador}',
            style: TextStyle(color: Colors.blue.shade200, fontSize: 13.0),
          )
        ],
      ),
      actions: pacoteActions,
      bottom: tabBars,
    );
  }

  TabBar get tabBars {
    return TabBar(
      tabs: [
        Tab(icon: Icon(Icons.place), text: "Localização"),
        Tab(icon: Icon(Icons.list_rounded), text: "Documentos"),
        Tab(icon: Icon(Icons.history_rounded), text: "Histórico"),
      ],
    );
  }

  Widget get tabViews {
    return TabBarView(
      children: [
        PacoteLocalizacao(parentCall: myCall),
        PacoteDocumentos(),
        PacoteRelatorios(),
      ],
    );
  }

  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
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
    return FutureBuilder(
      future: getPacote(),
      builder: (context, AsyncSnapshot<Pacote> snapshot) {
        if (snapshot.hasData) {
          mPacote = snapshot.data!;
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: appBar,
              body: tabViews,
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Ocorreu um erro:\n${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 24,
                children: [
                  CircularProgressIndicator(),
                  MyGreyText('Carregando dados do pacote')
                ],
              ),
            ),
          );
        }
      },
    );
  }

  VoidCallback? myCall() {
    setState(() {});
  }

  List<Widget> get pacoteActions {
    if (AppData.currentUser == null || editMode.value) {
      return [];
    } else {
      return [
        mPacote.selado
            ? TextButton.icon(
                label: Text('ABRIR'),
                icon: Icon(Icons.unarchive_rounded),
                onPressed: () {
                  setState(() {
                    abrirPacote();
                  });
                },
              )
            : TextButton.icon(
                label: Text('SELAR'),
                icon: Icon(Icons.verified_rounded),
                onPressed: () {
                  setState(() {
                    selarPacote();
                  });
                },
              ),
      ];
    }
  }

  void abrirPacote() {
    // abre mensagem alerta
    Message.showExecutar(
        context: context,
        titulo: 'Atenção!',
        mensagem:
            'Tem certeza que deseja ABRIR esse pacote?\n\nEssa ação implica em responsabilidade sobre os itens adicionados e/ou excluidos. Execute essa ação apenas se estiver com o pacote em mãos.',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Message.showAguarde(
              context: context,
              mensagem: 'Abrindo pacote...',
            );
            // executa alteracoes
            mPacote.updatedAct = PacoteAction.ABRIR.index;
            mPacote.selado = false;
            mPacote.seladoBy = AppData.currentUser;
            //mPacote.updatedAt = DateTime.now().toUtc();
            await mPacote.update();

            // Relatorio
            String relatorio = '''
*APP Acervo Físico*
Relatório de ABERTURA do pacote: "${mPacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${AppData.currentUser?.username ?? "**administrador**"}
''';
            await salvarRelatorio(
              PacoteAction.ABRIR.index,
              relatorio,
              mPacote,
            );
            //fecha progresso
            Navigator.pop(context);
          }
          // atualiza interface pai
          myCall();
        });
  }

  void selarPacote() {
    // abre mensagem alerta
    Message.showExecutar(
        context: context,
        titulo: 'Atenção!',
        mensagem:
            'Tem certeza que deseja SELAR esse pacote?\n\nEssa ação implica em responsabilidade sobre os itens adicionados e/ou excluidos. Execute essa ação apenas se estiver com o pacote em mãos.\n\nNão esqueça de assinar o selo!',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Message.showAguarde(
              context: context,
              mensagem: 'Selando pacote...',
            );
            // executa alteracoes
            mPacote.updatedAct = PacoteAction.SELAR.index;
            mPacote.selado = true;
            mPacote.seladoBy = AppData.currentUser;
            //mPacote.updatedAt = DateTime.now().toUtc();
            await mPacote.update();

            // Relatorio
            String relatorio = '''
*APP Acervo Físico*
Relatório de SELAMENTO do pacote: "${mPacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${AppData.currentUser!.username}
''';
            await salvarRelatorio(
              PacoteAction.SELAR.index,
              relatorio,
              mPacote,
            );
            //fecha progresso
            Navigator.pop(context);
          } else {}
          // atualiza interface pai
          myCall();
        });
  }
}
