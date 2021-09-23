import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:flutter/material.dart';
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
    // Progresso
    int qtdEliminados = 0;
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
                        semanticsLabel: 'Linear progress indicator',
                      ),
                      Container(
                        height: 12,
                      ),
                      Text(
                        'Eliminado ${qtdEliminados} de ${documentosEliminar.length}',
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        });
    // Exclusões
    //Message.showProgressoComMessagem(
    //    context: context, message: 'Eliminando itens...');
    for (Documento doc in documentosEliminar) {
      if (await eliminarItem(doc.objectId!)) {
        qtdEliminados++;
      }
      controller.value = (qtdEliminados / documentosEliminar.length);
    }
    Navigator.pop(context);
    print('$qtdEliminados documentos eliminados');
    callbackLista();
  }

  Future<bool> eliminarItem(String documentoId) async {
    final documento = Documento()..objectId = documentoId;
    final ParseResponse apiResponse = await documento.delete();
    return apiResponse.success;
  }
}
