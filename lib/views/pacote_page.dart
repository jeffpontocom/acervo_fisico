import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../controllers/salvar_relatorio.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../views/pacote_relatorios.dart';
import '../main.dart';
import 'messages.dart';
import 'pacote_documentos.dart';
import 'pacote_localizacao.dart';

late Pacote mPacote;
ValueNotifier<bool> editMode = new ValueNotifier(false);
var refresh;

class PacoteArgumentos {
  final Pacote pacote;
  PacoteArgumentos(this.pacote);
}

class PacotePage extends StatefulWidget {
  static const routeName = '/pacote';

  PacotePage({Key? key}) : super(key: key);

  @override
  _PacotePageState createState() => _PacotePageState();
}

class _PacotePageState extends State<PacotePage> {
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
  void didChangeDependencies() {
    if (ModalRoute.of(context)?.settings.arguments == null) {
      Navigator.pop(context);
      return;
    }
    final PacoteArgumentos args =
        ModalRoute.of(context)!.settings.arguments as PacoteArgumentos;
    mPacote = args.pacote;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    editMode.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                mPacote.selado ? 'Pacote selado' : 'Pacote aberto',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              Text(
                //'${mPacote.tipoToString}: ${mPacote.identificador}',
                'ID: ${mPacote.identificador}',
                style: TextStyle(color: Colors.blue.shade200, fontSize: 13.0),
              )
            ],
          ),
          actions: pacoteActions,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.place), text: "Localização"),
              Tab(icon: Icon(Icons.list_rounded), text: "Documentos"),
              Tab(icon: Icon(Icons.history_rounded), text: "Histórico"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PacoteLocalizacao(parentCall: myCall),
            PacoteDocumentos(),
            PacoteRelatorios(),
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
    Message.showAlerta(
        context: context,
        message:
            'Tem certeza que deseja ABRIR esse pacote?\n\nEssa ação implica em responsabilidade sobre os itens adicionados e/ou excluidos. Execute essa ação apenas se estiver com o pacote em mãos.',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Message.showProgressoComMessagem(
                context: context, message: 'Abrindo pacote...');
            // executa alteracoes
            mPacote.updatedAct = PacoteAction.ABRIR.index;
            mPacote.selado = false;
            mPacote.seladoBy = currentUser;
            //mPacote.updatedAt = DateTime.now().toUtc();
            await mPacote.update();

            // Relatorio
            String relatorio = '''
*APP Acervo Físico*
Relatório de ABERTURA do pacote: "${mPacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
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
    Message.showAlerta(
        context: context,
        message:
            'Tem certeza que deseja SELAR esse pacote?\n\nEssa ação implica em responsabilidade sobre os itens adicionados e/ou excluidos. Execute essa ação apenas se estiver com o pacote em mãos.\n\nNão esqueça de assinar o selo!',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Message.showProgressoComMessagem(
                context: context, message: 'Selando pacote...');
            // executa alteracoes
            mPacote.updatedAct = PacoteAction.SELAR.index;
            mPacote.selado = true;
            mPacote.seladoBy = currentUser;
            //mPacote.updatedAt = DateTime.now().toUtc();
            await mPacote.update();

            // Relatorio
            String relatorio = '''
*APP Acervo Físico*
Relatório de SELAMENTO do pacote: "${mPacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
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
