import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:acervo_fisico/views/pacote_page.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class LocalizarPacote {
  final BuildContext context;
  final String? value;

  LocalizarPacote(this.context, this.value) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });
    if (value == null || value!.trim().isEmpty) {
      Navigator.pop(context); // Finaliza indicador de progresso.
      ItemSemVinculo(context: context);
      return;
    }
    _aguardarBusca();
  }

  void _aguardarBusca() async {
    List<dynamic> resultados = await executarBusca(value!.trim().toUpperCase());
    Navigator.pop(context); // Finaliza indicador de progresso.
    _apresentarResultados(resultados.cast());
  }

  void _apresentarResultados(List<Pacote> pacotes) {
    // Se não encontrar, mostrar dialogo de alerta
    if (pacotes.length <= 0) {
      ItemNaoLocalizado(context: context);
    }
    // Se encontrar termo exato, ir para Widget VerPacote()
    else if (pacotes.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PacotePage(
                  pacote: pacotes.first,
                )),
      );
    }
    // Se encontrar mais de uma opção, mostrar dialogo de seleção
    // TODO => Mostrar o que fazer com pacotes duplicados
    else {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
          ),
          builder: (context) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Selecione o pacote',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: pacotes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Text(
                                pacotes[index].identificador,
                              ),
                              onTap: () {
                                _irParaPacote(pacotes[index]);
                                //LocalizarPacote(
                                //    context, pacotes[index].identificador);
                              });
                        }),
                  ),
                ],
              ),
            );
          });
    }
  }

  void _irParaPacote(Pacote? pacote) {
    if (pacote != null) {
      print(pacote);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PacotePage(
                  pacote: pacote,
                )),
      );
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(64),
                  child: Text(
                    'ERRO: Nenhum pacote vinculado a esse documento.',
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
  }
}

Future<List<dynamic>> executarBusca(value) async {
  //List<dynamic> resultados;

  //Busca exata
  QueryBuilder<Pacote> queryExata = QueryBuilder<Pacote>(Pacote())
    ..whereEqualTo(Pacote.keyId, value);
  //Busca contem
  QueryBuilder<Pacote> queryContem = QueryBuilder<Pacote>(Pacote())
    ..whereContains(Pacote.keyId, value);
  // Busca principal
  QueryBuilder<Pacote> query =
      QueryBuilder.or(Pacote(), [queryExata, queryContem])
        ..orderByAscending(Pacote.keyId)
        // necessario para trazer as informacoes do objeto (nao apenas ID)
        ..includeObject([Pacote.keyUpdatedBy]);

  final ParseResponse apiResponse = await query.query();
  if (apiResponse.success && apiResponse.results != null) {
    return apiResponse.results ?? [];
  } else {
    return [];
  }
}
