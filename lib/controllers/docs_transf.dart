import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'relatorio_add.dart';
import '../app_data.dart';
import '../models/documento.dart';
import '../models/enums.dart';
import '../views/messages.dart';
import '../views/pacote_page.dart';

class TransfDocumentos {
  final BuildContext context;
  final List<Documento> docsParaTransferir;
  final TickerProviderStateMixin provider;
  Pacote? pacoteRecebedor;

  TransfDocumentos(
      {required this.context,
      required this.docsParaTransferir,
      required this.provider,
      callback}) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController ctrPacoteRecebedor = TextEditingController();
    Message.showExecutar(
      context: context,
      titulo: 'Ação necessária!',
      mensagem: '''
Informe o localizador do pacote para o qual deseja transferir os documentos.

Apenas pacotes abertos podem receber transferências.
      ''',
      extra: Form(
        key: _formKey,
        child: TextFormField(
            controller: ctrPacoteRecebedor,
            validator: (value) {
              return pacoteRecebedor != null
                  ? null
                  : 'Nenhum pacote encontrado';
            },
            decoration: mTextField.copyWith(
                suffixIcon: pacoteRecebedor != null
                    ? Icon(Icons.check)
                    : Icon(Icons.search)),
            onFieldSubmitted: (texto) {
              _buscarPacotes(
                termo: texto,
                callback: (encontrado) {
                  pacoteRecebedor = encontrado;
                  if (pacoteRecebedor != null) {
                    ctrPacoteRecebedor.text = pacoteRecebedor!.identificador;
                  }
                  _formKey.currentState?.validate();
                },
              );
            }),
      ),
      onPressed: (executar) {
        if (executar) {
          if (pacoteRecebedor != null) {
            Navigator.pop(context);
            _analisarLista(callbackLista: () {
              callback();
            });
          } else {
            _formKey.currentState?.validate();
          }
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  _analisarLista({callbackLista}) async {
    List<Documento> docsTransferidos = [];
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
                        'Transferindo $qtdExecutada de ${docsParaTransferir.length}',
                      ),
                      qtdExecutada == docsParaTransferir.length
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
    for (Documento doc in docsParaTransferir) {
      if (await transferirItem(doc)) {
        docsTransferidos.add(doc);
        qtdExecutada++;
      } else {
        falhas.add(doc);
      }
      controller.value = (qtdExecutada / docsParaTransferir.length);
    }
    // Relatorio
    String relatorio = '''
*APP Acervo Físico*
Relatório de TRANSFERÊNCIAS entre pacotes

De: "${mPacote.identificador}"
Para: "${pacoteRecebedor!.identificador}"

${docsParaTransferir.length} itens selecionados


TRANSFERIDOS COM SUCESSO: ${docsTransferidos.length}
${docsTransferidos.toSet().toString().replaceAll('{}', '- nenhum!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


ERROS: 
Falha de conexão (tentar novamente): ${falhas.length}
${falhas.toSet().toString().replaceAll('{}', '- sem registro de falhas!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


Executado em ${DateFormat("dd/MM/yyyy 'às' HH:mm", "pt_BR").format(DateTime.now())}
Por ${AppData.currentUser?.username ?? "**administrador**"}
''';
    // Salva relatorio
    await salvarRelatorio(
      PacoteAction.TRANSFERIR.index,
      relatorio,
      mPacote,
    );
    await salvarRelatorio(
      PacoteAction.TRANSFERIR.index,
      relatorio,
      pacoteRecebedor!,
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

  Future<bool> transferirItem(Documento documento) async {
    documento
      ..set(
          Documento.keyPacote, Pacote()..objectId = pacoteRecebedor!.objectId);
    final ParseResponse apiResponse = await documento.update();
    return apiResponse.success;
  }

  _buscarPacotes({required String termo, callback}) async {
    Message.showAguarde(
      context: context,
      mensagem: 'Localizando pacote(s)...',
    );
    List<dynamic> resultados;
    String value = termo.trim().toUpperCase();
    //Busca exata
    QueryBuilder<Pacote> queryExata = QueryBuilder<Pacote>(Pacote())
      ..whereEqualTo(Pacote.keyId, value);
    //Busca contem
    QueryBuilder<Pacote> queryContem = QueryBuilder<Pacote>(Pacote())
      ..whereContains(Pacote.keyId, value);
    // Busca principal
    QueryBuilder<Pacote> query =
        QueryBuilder.or(Pacote(), [queryExata, queryContem])
          ..whereEqualTo(Pacote.keySelado, false)
          ..whereNotEqualTo('objectId', mPacote.objectId)
          ..orderByAscending(Pacote.keyId);
    // Executa busca
    final ParseResponse apiResponse = await query.query();
    // Finaliza indicador de progresso.
    Navigator.pop(context);
    if (apiResponse.statusCode == -1) {
      Message.showSemConexao(context: context);
      callback(null);
      return;
    }
    if (apiResponse.success && apiResponse.results != null) {
      resultados = apiResponse.results ?? [];
    } else {
      resultados = [];
    }
    // Apresenta resultados
    List<Pacote> pacotes = resultados.cast();
    // Se não encontrar, mostrar dialogo de alerta
    if (pacotes.length <= 0) {
      callback(null);
    }
    // Se encontrar termo exato, ir para Widget VerPacote()
    else if (pacotes.length == 1) {
      callback(pacotes.first);
    }
    // Se encontrar mais de uma opção, mostrar dialogo de seleção
    else {
      // Constroi a lista
      ListView listaPacotes = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: pacotes.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(pacotes[index].selado
                ? Icons.verified_rounded
                : Icons.unarchive_rounded),
            title: Text(
              pacotes[index].identificador,
            ),
            onTap: () {
              Navigator.pop(context);
              callback(pacotes[index]);
            },
          );
        },
      );
      // Apresenta o dialog
      Message.showBottomDialog(
        context: context,
        titulo: 'Selecione o pacote',
        conteudo: listaPacotes,
      );
    }
  }
}
