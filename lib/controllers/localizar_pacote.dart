import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/views/dialog_nao_localizado.dart';
import 'package:acervo_fisico/views/ver_pacote.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class LocalizarPacote {
  final BuildContext context;
  final String value;

  LocalizarPacote(this.context, this.value) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });

    _executarBusca(value).then((value) {
      Navigator.pop(context); // Finaliza indicador de progresso.
      // Se não encontrar, mostrar dialogo de alerta
      if (value.length <= 0) {
        ItemNaoLocalizado(context);
      }
      // Se encontrar termo exato, ir para Widget VerPacote()
      else if (value.length == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerPacote(
                    pacote: value.first,
                  )),
        );
      }
      // Se encontrar mais de uma opção, mostrar dialogo de seleção
      else {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(64),
                    child: Text(
                      'ERRO: Existe mais de um pacote com esse identificador',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            });
      }
    }).onError((error, stackTrace) {
      print('Deu erro!');
    });
  }
}

Future<List<dynamic>> _executarBusca(value) async {
  QueryBuilder<Pacote> query = QueryBuilder<Pacote>(Pacote())
    ..whereEqualTo('identificador', value)
    // necessario para trazer as informacoes do objeto (nao apenas ID)
    ..includeObject([Pacote.keyUpdatedBy]);
  final ParseResponse apiResponse = await query.query();
  if (apiResponse.success && apiResponse.results != null) {
    return apiResponse.results ?? [];
  } else {
    return [];
  }
}
