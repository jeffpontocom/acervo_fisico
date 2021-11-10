import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../models/documento.dart';
import '../views/messages.dart';
import 'pacote_query.dart';

class LocalizarDocumento {
  final BuildContext context;
  String query;

  LocalizarDocumento(this.context, this.query) {
    // Componentes para busca
    String assuntoBase;
    String tipo;
    String sequencial;
    String idioma = '';
    String folha = '';
    String revisao = '';

    // Normalizar o termo digitado
    query = query.trim().toUpperCase();

    if (query.isEmpty) {
      // Apresenta erro
      Message.showErro(
          context: context,
          message: 'Nenhum valor para documento foi informado.');
      return;
    }

    // Verificar quantidade de caracteres minima (6000DC15200)
    if (query.length < 11) {
      print('Query tem menos de 11 caracteres');
      Message.showNotFound(context: context);
      return;
    }

    // Separar o termo em componentes da bsuca
    // 1. Assunto Base
    assuntoBase = query.substring(0, 4);
    // Se query possui 11 caracteres (6000DC15200)
    if (query.length == 11) {
      print('Query tem 11 caracteres: Busca com 3 elementos');
      // 2. Tipo
      tipo = query.substring(4, 6);
      // 3. Sequencial
      sequencial = query.substring(6, 11);
      // Buscar
      _executarBusca(assuntoBase, tipo, sequencial, null, null, null);
      _printValores(assuntoBase, tipo, sequencial, idioma, folha, revisao);
      return;
    }

    // Se query possui 12 caracteres ...
    if (query.length == 12) {
      // ... e termina em numero (6000PIC15200)
      if (query.characters.last.contains(RegExp(r'[0-9]'))) {
        print(
            'Query tem 12 caracteres e termina com numero: Busca com 3 elementos');
        // 2. Tipo
        tipo = query.substring(4, 7);
        // 3. Sequencial
        sequencial = query.substring(7, 12);
        // Buscar
        _executarBusca(assuntoBase, tipo, sequencial, null, null, null);
      }
      // ... ou termina com letra (6000DC15200P)
      else {
        print(
            'Query tem 12 caracteres e não termina com numero: Busca com 4 elementos');
        // 2. Tipo
        tipo = query.substring(4, 6);
        // 3. Sequencial
        sequencial = query.substring(6, 11);
        // 4. Idioma
        idioma = query.substring(11, 12);
        // Buscar
        _executarBusca(assuntoBase, tipo, sequencial, idioma, null, null);
      }
      _printValores(assuntoBase, tipo, sequencial, idioma, folha, revisao);
      return;
    }

    // Se tiver folha ...
    if (query.contains('(')) {
      int ini = query.indexOf('(');
      int fim = query.indexOf(')');
      // 5. Folha
      folha = query.substring(ini + 1, fim);
      // Ex.: 6000DC15200P(1)...
      if (ini == 12) {
        // 2. Tipo
        tipo = query.substring(4, 6);
        // 3. Sequencial
        sequencial = query.substring(6, 11);
        // 4. Idioma
        idioma = query.substring(11, 12);
      }
      // Ex.: 6000PIC15200P(1)...
      else {
        // 2. Tipo
        tipo = query.substring(4, 7);
        // 3. Sequencial
        sequencial = query.substring(7, 12);
        // 4. Idioma
        idioma = query.substring(12, 13);
      }
      // 6. Revisao
      revisao = _qualRevisao(query);
    }

    // Se não tiver folha, apenas revisao ....
    else {
      // 6. Revisao
      revisao = _qualRevisao(query);
      String subQuery = query.replaceAll(revisao, '');
      // Ex.: 6000DC15200PR0
      if (subQuery.length <= 12) {
        // 2. Tipo
        tipo = query.substring(4, 6);
        // 3. Sequencial
        sequencial = query.substring(6, 11);
        // 4. Idioma
        idioma = query.substring(11, 12);
      }
      // Ex.: 6000PIC15200PR0
      else {
        // 2. Tipo
        tipo = query.substring(4, 7);
        // 3. Sequencial
        sequencial = query.substring(7, 12);
        // 4. Idioma
        idioma = query.substring(12, 13);
      }
    }

    // Se tiver revisao 6000DC15200PR0
    if (query.contains('R', 12)) {
      int pos = query.lastIndexOf(RegExp(r'R([0-9])'));
      // 6. Revisao
      revisao = query.substring(pos);
    }

    // Busca com folha e sem revisao
    if (folha.isNotEmpty && revisao.isEmpty) {
      _executarBusca(assuntoBase, tipo, sequencial, idioma, folha, null);
    }
    // Busca sem folha e com revisao
    else if (folha.isEmpty && revisao.isNotEmpty) {
      _executarBusca(assuntoBase, tipo, sequencial, idioma, null, revisao);
    }
    // Busca com folha e com revisao
    else if (folha.isNotEmpty && revisao.isNotEmpty) {
      _executarBusca(assuntoBase, tipo, sequencial, idioma, folha, revisao);
    }
    // Sem folha e sem revisão: ANALISAR POSSIBILIDADE DE ERROS
    else {
      print('Avaliar query');
      Message.showNotFound(context: context);
    }
    _printValores(assuntoBase, tipo, sequencial, idioma, folha, revisao);
  }

  void _printValores(assuntoBase, tipo, sequencial, idioma, folha, revisao) {
    print('Assunto: ' + assuntoBase);
    print('Tipo: ' + tipo);
    print('Sequencial: ' + sequencial);
    print('Idioma: ' + idioma);
    print('Folha: ' + folha);
    print('Revisao: ' + revisao);
  }

  String _qualRevisao(String query) {
    if (query.contains('R', 12) ||
        query.contains('C', 12) ||
        query.contains('M', 12)) {
      int pos = query.lastIndexOf(RegExp(r'[A-Z]([0-9])'));
      return query.substring(pos);
    } else {
      return '';
    }
  }

  /// Busca na base de dados
  void _executarBusca(assuntoBase, tipo, sequencial, String? idioma,
      String? folha, String? revisao) async {
    List<dynamic> resultados;
    QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento());

    Message.showProgressoComMessagem(
        context: context, message: 'Localizando documento...');

    if (idioma == null && folha == null && revisao == null) {
      query = query
        ..whereEqualTo('assuntoBase', assuntoBase)
        ..whereEqualTo('tipo', tipo)
        ..whereEqualTo('sequencial', sequencial);
    } else if (folha == null && revisao == null) {
      query = query
        ..whereEqualTo('assuntoBase', assuntoBase)
        ..whereEqualTo('tipo', tipo)
        ..whereEqualTo('sequencial', sequencial)
        ..whereEqualTo('idioma', idioma);
    } else if (revisao == null) {
      query = query
        ..whereEqualTo('assuntoBase', assuntoBase)
        ..whereEqualTo('tipo', tipo)
        ..whereEqualTo('sequencial', sequencial)
        ..whereEqualTo('idioma', idioma)
        ..whereEqualTo('folha', folha);
    } else if (folha == null) {
      query = query
        ..whereEqualTo('assuntoBase', assuntoBase)
        ..whereEqualTo('tipo', tipo)
        ..whereEqualTo('sequencial', sequencial)
        ..whereEqualTo('idioma', idioma)
        ..whereEqualTo('revisao', revisao);
    } else {
      query = query
        ..whereEqualTo('assuntoBase', assuntoBase)
        ..whereEqualTo('tipo', tipo)
        ..whereEqualTo('sequencial', sequencial)
        ..whereEqualTo('idioma', idioma)
        ..whereEqualTo('folha', folha)
        ..whereEqualTo('revisao', revisao);
    }

    query = query
      ..includeObject([Documento.keyPacote])
      ..orderByAscending('idioma')
      ..orderByAscending('folha')
      ..orderByAscending('revisao');

    final ParseResponse apiResponse = await query.query();
    Navigator.pop(context); // Finaliza indicador de progresso.
    if (apiResponse.statusCode == -1) {
      Message.showSemConexao(context: context);
      return;
    }
    if (apiResponse.success && apiResponse.results != null) {
      resultados = apiResponse.results ?? [];
    } else {
      resultados = [];
    }
    _apresentarResultados(resultados.cast());
  }

  /// Apresenta os resultados ou vai direto para o pacote
  void _apresentarResultados(List<Documento> documentos) {
    // Se nenhum documento localizado
    if (documentos.length == 0) {
      Message.showNotFound(context: context);
    }
    // Se apenas um documento localizado, vai direto ao pacote
    else if (documentos.length == 1) {
      irParaPacote(context, documentos.first.pacote!);
    }
    // Se diversos documentos localizados, mostrar dialogo de selecao
    else {
      // Constroi a lista
      ListView listaDocumentos = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: documentos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              documentos[index].toString(),
            ),
            subtitle: Text(documentos[index].pacote?.identificador != null
                ? 'Pacote: ${documentos[index].pacote!.identificador}'
                : 'ERRO: Sem pacote vinculado'),
            //trailing: Icon(Icons.document_scanner_rounded),
            visualDensity: VisualDensity.compact,
            onTap: documentos[index].pacote != null
                ? () {
                    irParaPacote(context, documentos[index].pacote!);
                  }
                : null,
          );
        },
      );
      // Apresenta o dialog
      Message.showBottomDialog(
          context: context,
          titulo: 'Selecione o documento',
          conteudo: listaDocumentos);
    }
  }
}
