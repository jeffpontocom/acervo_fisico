import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class DelDocumentos {
  final BuildContext context;
  final List<Documento> documentosEliminar;

  DelDocumentos(
      {required this.context, required this.documentosEliminar, callback}) {
    Message.showAlerta(
        context: context,
        message:
            'Os documentos excluidos não podem ser recuperados.\n\nEstá certo disso?',
        onPressed: (executar) {
          if (executar) {
            _analisarLista(callbackLista: () {
              Navigator.pop(context);
              callback();
            });
          } else {
            Navigator.pop(context);
          }
        });
  }

  void _analisarLista({callbackLista}) async {
    int qtdEliminados = 0;
    for (Documento doc in documentosEliminar) {
      if (await eliminarItem(doc.objectId!)) {
        qtdEliminados++;
        print('$qtdEliminados documentos eliminados');
      }
    }
    callbackLista();
  }

  Future<bool> eliminarItem(String documentoId) async {
    final documento = Documento()..objectId = documentoId;
    final ParseResponse apiResponse = await documento.delete();
    return apiResponse.success;
  }
}
