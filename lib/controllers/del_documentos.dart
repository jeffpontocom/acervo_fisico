import 'package:acervo_fisico/controllers/salvar_relatorio.dart';
import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:acervo_fisico/views/pacote_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class DelDocumentos {
  final BuildContext context;
  final List<Documento> documentosEliminar;
  final TickerProviderStateMixin provider;

  DelDocumentos(
      {required this.context,
      required this.documentosEliminar,
      required this.provider,
      callback}) {
    Message.showAlerta(
        context: context,
        message:
            'Os documentos excluidos não podem ser recuperados.\n\nEstá certo disso?',
        onPressed: (executar) {
          if (executar) {
            Navigator.pop(context);
            _analisarLista(callbackLista: () {
              callback();
            });
          } else {
            Navigator.pop(context);
          }
        });
  }

  void _analisarLista({callbackLista}) async {
    List<Documento> eliminados = [];
    List<Documento> falhas = [];
    // Progresso
    int qtdExecutada = 0;
    var controller = AnimationController(
      vsync: provider,
      value: 0,
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter innerState) {
              controller
                ..addListener(() {
                  innerState(() {});
                });
              return SimpleDialog(
                contentPadding: EdgeInsets.all(24),
                children: [
                  Column(
                    children: <Widget>[
                      Text(
                        'Progresso',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        height: 12,
                      ),
                      LinearProgressIndicator(
                        value: controller.value,
                        semanticsLabel: 'Indicador de progresso',
                      ),
                      Container(
                        height: 12,
                      ),
                      Text(
                        'Eliminado $qtdExecutada de ${documentosEliminar.length}',
                      ),
                      qtdExecutada == documentosEliminar.length
                          ? Text(
                              'Gerando relatorio...',
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              );
            },
          );
        });
    // Exclusões
    for (Documento doc in documentosEliminar) {
      if (await eliminarItem(doc.objectId!)) {
        eliminados.add(doc);
        qtdExecutada++;
      } else {
        falhas.add(doc);
      }
      controller.value = (qtdExecutada / documentosEliminar.length);
    }
    // Relatorio
    String relatorio = '''
*APP Acervo Físico*
Relatório de EXCLUSÕES no pacote: "${mPacote.identificador}"
${documentosEliminar.length} itens selecionados


EXCLUIDOS COM SUCESSO: ${eliminados.length}
${eliminados.toSet().toString().replaceAll('{}', '- nenhum!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


ERROS: 
Falha de conexão (tentar novamente): ${falhas.length}
${falhas.toSet().toString().replaceAll('{}', '- sem registro de falhas!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
''';
    // Salva relatorio
    await salvarRelatorio(
      PacoteAction.DEL_DOC.index,
      relatorio,
      mPacote,
    );
    // Fecha indicador de progresso
    Navigator.pop(context);
    // Apresenta relatorio
    Message.showRelatorio(
        context: context,
        message: relatorio,
        onPressed: () {
          callbackLista();
        });
  }

  Future<bool> eliminarItem(String documentoId) async {
    final documento = Documento()..objectId = documentoId;
    final ParseResponse apiResponse = await documento.delete();
    return apiResponse.success;
  }
}
