import 'package:acervo_fisico/controllers/localizar_pacote.dart';
import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/views/dialog_nao_encontrado.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocalizarDocumento {
  final BuildContext context;
  String query;

  LocalizarDocumento(this.context, this.query) {
    // Componentes
    String assuntoBase;
    String tipo;
    String sequencial;
    String idioma = '';
    String folha = '';
    String revisao = '';

    // Normalizar a query
    query = query.trim().toUpperCase();

    // Verificar quantidade de caracteres minima (6000DC15200)
    if (query.length < 11) {
      print('Query tem menos de 11 caracteres');
      ItemNaoEcontrado(context);
      return;
    }

    // Extrair query em componentes
    assuntoBase = query.substring(0, 4);

    // Se query possui 11 caracteres (6000DC15200)
    if (query.length == 11) {
      tipo = query.substring(4, 6);
      sequencial = query.substring(6, 11);
      print('Query tem 11 caracteres: Busca com 3 elementos');
      _printValores(assuntoBase, tipo, sequencial, idioma, folha, revisao);
      _executarBusca(_buscaCom3Componentes(assuntoBase, tipo, sequencial));
      return;
    }

    // Se query possui 12 caracteres ...
    if (query.length == 12) {
      // ... e termina em numero (6000PIC15200)
      if (query.characters.last.contains(RegExp(r'[0-9]'))) {
        tipo = query.substring(4, 7);
        sequencial = query.substring(7, 12);
        print(
            'Query tem 12 caracteres e termina com numero: Busca com 3 elementos');
        _executarBusca(_buscaCom3Componentes(assuntoBase, tipo, sequencial));
      }
      // ... ou termina com letra (6000DC15200P)
      else {
        tipo = query.substring(4, 6);
        sequencial = query.substring(6, 11);
        idioma = query.substring(11, 12);
        print(
            'Query tem 12 caracteres e não termina com numero: Busca com 4 elementos');
        _executarBusca(
            _buscaCom4Componentes(assuntoBase, tipo, sequencial, idioma));
      }
      _printValores(assuntoBase, tipo, sequencial, idioma, folha, revisao);
      return;
    }

    // Se tiver folha ...
    if (query.contains('(')) {
      int ini = query.indexOf('(');
      int fim = query.indexOf(')');
      folha = query.substring(ini + 1, fim);
      // 6000DC15200P(1)...
      if (ini == 12) {
        tipo = query.substring(4, 6);
        sequencial = query.substring(6, 11);
        idioma = query.substring(11, 12);
      }
      // 6000PIC15200P(1)...
      else {
        tipo = query.substring(4, 7);
        sequencial = query.substring(7, 12);
        idioma = query.substring(12, 13);
      }
      revisao = _qualRevisao(query);
    }
    // Se não tiver folha, apenas revisao ....
    else {
      revisao = _qualRevisao(query);
      String subQuery = query.replaceAll(revisao, '');
      // 6000DC15200PR0
      if (subQuery.length <= 12) {
        tipo = query.substring(4, 6);
        sequencial = query.substring(6, 11);
        idioma = query.substring(11, 12);
      }
      // 6000PIC15200PR0
      else {
        tipo = query.substring(4, 7);
        sequencial = query.substring(7, 12);
        idioma = query.substring(12, 13);
      }
    }

    // Se tiver revisao  6000DC15200PR0
    if (query.contains('R', 12)) {
      int pos = query.lastIndexOf(RegExp(r'R([0-9])'));
      revisao = query.substring(pos);
    }

    if (folha.isNotEmpty && revisao.isEmpty) {
      _executarBusca(
          _buscaComFolha(assuntoBase, tipo, sequencial, idioma, folha));
    } else if (folha.isEmpty && revisao.isNotEmpty) {
      _executarBusca(
          _buscaComRevisao(assuntoBase, tipo, sequencial, idioma, revisao));
    } else if (folha.isNotEmpty && revisao.isNotEmpty) {
      _executarBusca(_buscaComFolhaERevisao(
          assuntoBase, tipo, sequencial, idioma, folha, revisao));
    } else {
      print('Avaliar query');
      ItemNaoEcontrado(context);
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

  // Busca no Firebase
  void _executarBusca(Query<Map<String, dynamic>> busca) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });

    busca
        .withConverter<Documento>(
            fromFirestore: (snapshot, _) =>
                Documento.fromJson(snapshot.data()!),
            toFirestore: (documento, _) => documento.toJson())
        .get()
        .then((QuerySnapshot<Documento> snapshots) {
      Navigator.pop(context); // Finaliza indicador de progresso.
      if (snapshots.size == 0) {
        ItemNaoEcontrado(context);
      } else if (snapshots.size == 1) {
        LocalizarPacote(context, snapshots.docs[0].data().pacote.id);
      } else {
        // Show Bottom Dialog
        print('Mostrar bottom dialog');
      }
    });
  }

  //
  Query<Map<String, dynamic>> _buscaCom3Componentes(
      assuntoBase, tipo, sequencial) {
    return FirebaseFirestore.instance
        .collection('teste_documentos')
        .where('assuntoBase', isEqualTo: assuntoBase)
        .where('tipo', isEqualTo: tipo)
        .where('sequencial', isEqualTo: sequencial);
  }

  Query<Map<String, dynamic>> _buscaCom4Componentes(
      assuntoBase, tipo, sequencial, idioma) {
    return FirebaseFirestore.instance
        .collection('teste_documentos')
        .where('assuntoBase', isEqualTo: assuntoBase)
        .where('tipo', isEqualTo: tipo)
        .where('sequencial', isEqualTo: sequencial)
        .where('idioma', isEqualTo: idioma);
  }

  Query<Map<String, dynamic>> _buscaComFolha(
      assuntoBase, tipo, sequencial, idioma, folha) {
    return FirebaseFirestore.instance
        .collection('teste_documentos')
        .where('assuntoBase', isEqualTo: assuntoBase)
        .where('tipo', isEqualTo: tipo)
        .where('sequencial', isEqualTo: sequencial)
        .where('idioma', isEqualTo: idioma)
        .where('revisao', isEqualTo: folha);
  }

  Query<Map<String, dynamic>> _buscaComRevisao(
      assuntoBase, tipo, sequencial, idioma, revisao) {
    return FirebaseFirestore.instance
        .collection('teste_documentos')
        .where('assuntoBase', isEqualTo: assuntoBase)
        .where('tipo', isEqualTo: tipo)
        .where('sequencial', isEqualTo: sequencial)
        .where('idioma', isEqualTo: idioma)
        .where('revisao', isEqualTo: revisao);
  }

  Query<Map<String, dynamic>> _buscaComFolhaERevisao(
      assuntoBase, tipo, sequencial, idioma, folha, revisao) {
    return FirebaseFirestore.instance
        .collection('teste_documentos')
        .where('assuntoBase', isEqualTo: assuntoBase)
        .where('tipo', isEqualTo: tipo)
        .where('sequencial', isEqualTo: sequencial)
        .where('idioma', isEqualTo: idioma)
        .where('folha', isEqualTo: folha)
        .where('revisao', isEqualTo: revisao);
  }

  // Se encontrar mais de uma opção, mostrar dialogo de seleção

  // Se encontrar termo exato, ir para Widget VerPacote()
}
