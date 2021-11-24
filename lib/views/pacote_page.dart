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
import 'mensagens.dart';
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
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mPacote.selado ? 'Pacote selado' : 'Pacote aberto',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          Text(
            '${mPacote.identificador}',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ],
      ),
      actions: pacoteActions,
      bottom: tabBars,
    );
  }

  TabBar get tabBars {
    return TabBar(
      tabs: [
        Tab(
          height: 56,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              Icon(Icons.place),
              Text(
                'Localização',
                softWrap: false,
              )
            ],
          ),
        ),
        Tab(
          height: 56,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              Icon(Icons.list_rounded),
              Text(
                'Documentos',
                softWrap: false,
              )
            ],
          ),
        ),
        Tab(
          height: 56,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              Icon(Icons.history_rounded),
              Text(
                'Histórico',
                softWrap: false,
              )
            ],
          ),
        ),
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
                  MyGreyText('Carregando dados do pacote...')
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
    Mensagem.showExecutar(
        context: context,
        titulo: 'Atenção!',
        mensagem:
            'Tem certeza que deseja ABRIR esse pacote?\n\nEssa ação implica em responsabilidade sobre os itens adicionados e/ou excluidos. Execute essa ação apenas se estiver com o pacote em mãos.',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Mensagem.aguardar(
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
Relatório de ABERTURA

Pacote: "${mPacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy 'às' HH:mm", "pt_BR").format(DateTime.now())}
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
    Mensagem.showExecutar(
        context: context,
        titulo: 'Atenção!',
        mensagem:
            'Tem certeza que deseja SELAR esse pacote?\n\nEssa ação implica em responsabilidade sobre os itens adicionados e/ou excluidos. Execute essa ação apenas se estiver com o pacote em mãos.\n\nNão esqueça de assinar o selo!',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Mensagem.aguardar(
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
Relatório de SELAMENTO 

Pacote: "${mPacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy 'às' HH:mm", "pt_BR").format(DateTime.now())}
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
