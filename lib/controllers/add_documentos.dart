import 'dart:convert';

import 'package:acervo_fisico/controllers/salvar_relatorio.dart';
import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:acervo_fisico/views/pacote_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class AddDocumentos {
  final BuildContext context;
  final String pacoteId;
  final TickerProviderStateMixin provider;

  String _memoValores = '';

  List<String> _itensParaAnalise = [];
  List<String> _naoDocumentos = [];
  List<Documento> _duplicatas = [];
  List<Documento> _validos = [];
  List<Documento> _falhas = [];

  Widget get campoLista {
    return TextFormField(
      decoration: InputDecoration().copyWith(
        labelText: 'Lista de documentos',
        hintText: '4000dc15200p(1)r1\n4000dc15201p(1)r0c\n4000dc15201p(2)r0a',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(),
      ),
      minLines: 7,
      maxLines: 10,
      textInputAction: TextInputAction.newline,
      onChanged: (value) {
        _memoValores = value;
      },
    );
  }

  AddDocumentos(
      {required this.context,
      required this.pacoteId,
      required this.provider,
      callback}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'ADICIONAR DOCUMENTOS',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                child: Column(
                  children: [
                    campoLista,
                    SizedBox(
                      height: 24,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.send_and_archive_rounded),
                      label: Text('Analisar e adicionar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 50),
                      ),
                      onPressed: () {
                        _analistarLista(callbackLista: () {
                          callback();
                        });
                      },
                    ),
                    SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _analistarLista({callbackLista}) async {
    // Progresso
    int analisados = 0;
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
                        'Processado $analisados de ${_itensParaAnalise.length}',
                      ),
                      analisados == _itensParaAnalise.length
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
    // Separar itens e adicionar a lista para analise
    _itensParaAnalise = separarItens(_memoValores);
    _itensParaAnalise.remove('');
    print('${_itensParaAnalise.length} iten(s) identificado(s)');
    // Iniciar progresso 0/XX (Validados: xx; Duplicatas: xx; Mal-formados: xx; Falhas: xx)

    // Analisar cada item se documento
    for (String value in _itensParaAnalise) {
      //print('$value \n');
      Documento? verificado = verificarItem(value);
      // se não documento acrescentar na lista e nao documentos
      if (verificado == null) {
        _naoDocumentos.add(value);
      } else {
        Documento? duplicado = await verificarDuplicata(verificado);
        // se já existe no BD acrescenta na lista duplicatas
        if (duplicado != null) {
          _duplicatas.add(duplicado);
        } else {
          // se tudo ok tentar salvar registro
          Documento? salvo = await salvarItem(verificado);
          if (salvo == null) {
            // se registro falhar acrescentar na lista de falhas
            _falhas.add(verificado);
          } else {
            // se registro ok acrecentar na lista de validos
            _validos.add(salvo);
          }
        }
      }
      analisados++;
      controller.value = (analisados / _itensParaAnalise.length);
    }
    // Relatorio
    String s = _itensParaAnalise.length <= 1 ? '' : 's';
    String item = _itensParaAnalise.length <= 1 ? 'item' : 'itens';
    String relatorio = '''
*APP Acervo Físico*
Relatório de INCLUSÕES no pacote: "${mPacote.identificador}"
${_itensParaAnalise.length} $item identificado$s


ADICIONADOS COM SUCESSO: ${_validos.length}
${_validos.toSet().toString().replaceAll('{}', '- nenhum!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


ERROS:

Formatação do código (verificar): ${_naoDocumentos.length}
${_naoDocumentos.toSet().toString().replaceAll('{}', '- nenhum!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}

Em OUTRO PACOTE (conferir in loco): ${_duplicatas.length}
${_duplicatas.toSet().toString().replaceAll('{}', '- nenhum!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}

Falha de conexão (tentar novamente): ${_falhas.length}
${_falhas.toSet().toString().replaceAll('{}', '- sem registro de falhas!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
''';
    // Salva relatorio
    await salvarRelatorio(
      PacoteAction.ADD_DOC.index,
      relatorio,
      mPacote,
    );
    // Fecha indicador de progresso
    Navigator.pop(context);
    // Fecha dialogo de inclusao
    Navigator.pop(context);
    // Apresenta relatorio
    Message.showRelatorio(
        context: context,
        message: relatorio,
        onPressed: () {
          callbackLista();
        });
  }

  List<String> separarItens(String values) {
    LineSplitter ls = new LineSplitter();
    if (values.isEmpty) return [];
    values = values.toUpperCase();
    values = values.replaceAll(' ', '');
    values = values.replaceAll(';', '\n');
    values = values.replaceAll('\n\n', '\r');
    return ls.convert(values);
  }

  Documento? verificarItem(String value) {
    String assuntoBase = '';
    String tipo = '';
    String sequencial = '';
    String idioma = '';
    String folha = '';
    String revisao = '';

    if (value.length < 17) {
      print('Item nao possui caracteres suficientes: $value');
      return null;
    }
    if (!(value.contains('('))) {
      print('Item nao possui identificador de folha: $value');
      return null;
    }

    // identificadores de folhas
    int posFolhaIni = value.indexOf('(');
    int posFolhaFim = value.indexOf(')');

    if (posFolhaFim == -1 || posFolhaIni < 12 || posFolhaIni > 13) {
      print('Ma formacao do codigo: $value');
      return null;
    }

    // 1. Assunto Base
    assuntoBase = value.substring(0, 4);

    // 2. Tipo
    // 3. Sequencial
    if (posFolhaIni == 12) {
      // Item possui tipo com 2 caracteres
      tipo = value.substring(4, 6);
      sequencial = value.substring(6, 11);
    } else if (posFolhaIni == 13) {
      // Item possui tipo com  3 caracteres
      tipo = value.substring(4, 7);
      sequencial = value.substring(7, 12);
    }

    // 4. Idioma (se nao possuir retorna null)
    idioma = value[posFolhaIni - 1];
    if (!(idioma == 'P' || idioma == 'E' || idioma == 'I' || idioma == 'O')) {
      print('Item nao possui idioma valido: $value');
      return null;
    }

    // 5. Folha
    folha = value.substring(posFolhaIni + 1, posFolhaFim);

    // 6. Revisao (se nao possuir retorna null)
    revisao = value.substring(posFolhaFim + 1);
    if (revisao.isEmpty ||
        revisao.length == 1 ||
        revisao.length > 5 ||
        !(revisao.startsWith('R') ||
            revisao.startsWith('C') ||
            revisao.startsWith('M'))) {
      print('Item nao possui revisao valida: $value');
      return null;
    }

    // Demais testes
    if (assuntoBase.isEmpty ||
        tipo.isEmpty ||
        sequencial.isEmpty ||
        idioma.isEmpty ||
        folha.isEmpty ||
        revisao.isEmpty) {
      print('Falha na composicao de algum elemento, verificar string: $value');
      return null;
    }

    Documento doc = new Documento();
    doc.assuntoBase = assuntoBase;
    doc.tipo = tipo;
    doc.sequencial = sequencial;
    doc.idioma = idioma;
    doc.folha = folha;
    doc.revisao = revisao;
    print('Item validado: ${doc.toString()}');
    return doc;
  }

  Future<Documento?> verificarDuplicata(Documento documento) async {
    QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento());

    query = query
      ..whereEqualTo('assuntoBase', documento.assuntoBase)
      ..whereEqualTo('tipo', documento.tipo)
      ..whereEqualTo('sequencial', documento.sequencial)
      ..whereEqualTo('idioma', documento.idioma)
      ..whereEqualTo('folha', documento.folha)
      ..whereEqualTo('revisao', documento.revisao)
      ..includeObject([Documento.keyPacote]);
    final ParseResponse apiResponse = await query.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results?.first;
    } else {
      return null;
    }
  }

  Future<Documento?> salvarItem(Documento documento) async {
    final registration = Documento()
      ..set(Documento.keyAssuntoBase, documento.assuntoBase)
      ..set(Documento.keyTipo, documento.tipo)
      ..set(Documento.keySequencial, documento.sequencial)
      ..set(Documento.keyIdioma, documento.idioma)
      ..set(Documento.keyFolha, documento.folha)
      ..set(Documento.keyRevisao, documento.revisao)
      ..set(Documento.keyPacote, Pacote()..objectId = pacoteId);
    final ParseResponse apiResponse = await registration.save();
    if (apiResponse.success) {
      return apiResponse.result;
    } else {
      return null;
    }
  }
}
