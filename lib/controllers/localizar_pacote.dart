import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../models/pacote.dart';
import '../views/messages.dart';
import '../views/pacote_page.dart';

class LocalizarPacote {
  final BuildContext context;
  final String? termo;

  /// Realiza a busca pelo nome identificador do pacote
  LocalizarPacote(this.context, this.termo) {
    // Apresentar caso nenhum nome tenha sido informado
    if (termo == null || termo!.trim().isEmpty) {
      Message.showErro(
          context: context, message: 'Nenhum valor para pacote foi informado.');
      return;
    }
    // Abre tela de progresso
    else {
      Message.showProgressoComMessagem(
          context: context, message: 'Localizando pacote...');
      _executarBusca();
    }
  }

  void _executarBusca() async {
    List<dynamic> resultados;
    String value = termo!.trim().toUpperCase();
    //Busca exata
    QueryBuilder<Pacote> queryExata = QueryBuilder<Pacote>(Pacote())
      ..whereEqualTo(Pacote.keyId, value);
    //Busca contem
    QueryBuilder<Pacote> queryContem = QueryBuilder<Pacote>(Pacote())
      ..whereContains(Pacote.keyId, value);
    // Busca principal
    QueryBuilder<Pacote> query =
        QueryBuilder.or(Pacote(), [queryExata, queryContem])
          ..orderByAscending(Pacote.keyId);
    // Executa busca
    final ParseResponse apiResponse = await query.query();
    // Finaliza indicador de progresso.
    Navigator.pop(context);
    if (apiResponse.statusCode == -1) {
      Message.showSemConexao(context: context);
      return;
    }
    if (apiResponse.success && apiResponse.results != null) {
      resultados = apiResponse.results ?? [];
    } else {
      resultados = [];
    }
    // Apresenta resultados
    _apresentarResultados(resultados.cast());
  }

  void _apresentarResultados(List<Pacote> pacotes) {
    // Se não encontrar, mostrar dialogo de alerta
    if (pacotes.length <= 0) {
      Message.showNotFound(context: context);
    }
    // Se encontrar termo exato, ir para Widget VerPacote()
    else if (pacotes.length == 1) {
      irParaPacote(context, pacotes.first);
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
              irParaPacote(context, pacotes[index]);
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

/// Abre diretamente o pacote selecionado
Future<void> irParaPacote(BuildContext context, Pacote pacote) async {
  // Abre tela de progresso
  Message.showProgressoComMessagem(
      context: context, message: 'Abrindo pacote...');
  // Executa busca
  QueryBuilder<Pacote> query = QueryBuilder<Pacote>(Pacote())
    ..whereEqualTo('objectId', pacote.objectId)
    ..includeObject([
      Pacote.keyUpdatedBy,
      Pacote.keySeladoBy
    ]); // necessario para trazer as informacoes do objeto (nao apenas ID)
  final ParseResponse apiResponse = await query.query();
  // Fecha tela de progresso
  Navigator.pop(context);
  // Sem conexao
  if (apiResponse.statusCode == -1) {
    Message.showSemConexao(context: context);
  }
  if (apiResponse.success && apiResponse.results != null) {
    // Ir para o pacote
    var thisPacote = apiResponse.results!.first as Pacote;
    Navigator.pushNamed(context, PacotePage.routeName,
        arguments: PacoteArgumentos(thisPacote));
  } else {
    // Apresenta erro
    Message.showErro(
        context: context,
        message:
            'Falha ao tentar abrir pacote. Verifique com o administrador.');
  }
}
