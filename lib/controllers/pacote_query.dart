import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../models/pacote.dart';
import '../views/mensagens.dart';
import '../views/pacote_page.dart';

class LocalizarPacote {
  final BuildContext context;
  final String? termo;

  /// Realiza a busca pelo nome identificador do pacote
  LocalizarPacote(this.context, this.termo) {
    // Apresentar caso nenhum nome tenha sido informado
    if (termo == null || termo!.trim().isEmpty) {
      Mensagem.simples(
          context: context,
          titulo: 'Atenção!',
          mensagem: 'Nenhum valor para pacote foi informado.');
      return;
    }
    // Abre tela de progresso
    else {
      Mensagem.aguardar(
        context: context,
        mensagem: 'Localizando pacote(s)...',
      );
      _executarBusca();
    }
  }

  void _executarBusca() async {
    List<dynamic> resultados;
    String value = termo!.trim().toUpperCase().replaceAll(' ', '');
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
      Mensagem.semConexao(context: context);
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
      Mensagem.naoEncontrado(context: context);
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
      Mensagem.bottomDialog(
        context: context,
        titulo: 'Selecione o pacote',
        conteudo: listaPacotes,
      );
    }
  }
}

/// Abre diretamente o pacote selecionado
Future<void> irParaPacote(BuildContext context, Pacote pacote) async {
  Navigator.pushNamed(context, PacotePage.routeName + '?id=${pacote.objectId}');
}
