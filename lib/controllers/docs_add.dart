import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'relatorio_add.dart';
import '../app_data.dart';
import '../models/documento.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../views/messages.dart';
import '../views/pacote_page.dart';

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
        constraints: BoxConstraints(maxWidth: 900),
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
    Message.showBottomDialog(
      context: context,
      titulo: 'Adicionar documentos',
      conteudo: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          children: [
            campoLista,
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.send_and_archive_rounded),
              label: Text('Analisar e adicionar'),
              onPressed: () {
                _analistarLista(callbackLista: () {
                  callback();
                });
              },
            ),
          ],
        ),
      ),
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
    // Remover itens em branco
    _itensParaAnalise.remove('');
    print('Analisando ${_itensParaAnalise.length} item(s)...');
    // Analisar cada item se atende padrões de documento Itaipu
    for (String value in _itensParaAnalise) {
      // Analise
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
${duplicatasToString(_duplicatas)}

Falha de conexão (tentar novamente): ${_falhas.length}
${_falhas.toSet().toString().replaceAll('{}', '- sem registro de falhas!').replaceAll('{', '- ').replaceAll('}', '.').replaceAll(', ', ';\n- ')}


Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${AppData.currentUser?.username ?? "**administrador**"}
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

  String duplicatasToString(List<Documento> lista) {
    if (lista.isEmpty) return '- nenhum!';
    String resultado = '';
    int iterator = 0;
    lista.forEach((element) {
      iterator++;
      resultado = resultado +
          '- ' +
          element.toString() +
          ' > Pacote: ' +
          element.pacote!.identificador;
      iterator < lista.length
          ? resultado = resultado + ';\n'
          : resultado = resultado + '.';
    });
    return resultado;
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

  /// Verifica se string atende padrões de documentos Itaipu
  /// Obrigatório: Assunto Base, Tipo, Sequencial, Idioma, Folha e Revisão
  /// Ex.: 4000DC15200P(1)R0A
  Documento? verificarItem(String value) {
    String assuntoBase = '';
    String tipo = '';
    String sequencial = '';
    String idioma = '';
    String folha = '';
    String revisao = '';

    // Remover traço inicial (se houver)
    while (value.startsWith('-')) {
      value = value.replaceFirst('-', '');
    }
    // Remover ponto no final (se houver)
    while (value.endsWith('.')) {
      value = value.replaceFirst('.', '', value.length - 1);
    }

    // Valida se tem o número mínimo de caracteres
    if (value.length < 17) {
      print('Item nao possui caracteres suficientes: $value');
      return null;
    }

    // Posições dos identificadores de folhas (inicio e fim)
    int posFolhaIni = value.indexOf('(');
    int posFolhaFim = value.indexOf(')');
    print('PosFolhaIni: $posFolhaIni');
    print('PosFolhaFim: $posFolhaFim');

    // Valida se o identificador de folha está no trecho possível
    if (posFolhaIni == -1 ||
        posFolhaFim == -1 ||
        posFolhaIni < 12 ||
        posFolhaIni > 13) {
      print('Identificador de folha inexistente ou mal posicionado: $value');
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

    // Cria o item validado
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

  /// Verifica se já há registro do documento no banco de dados
  Future<Documento?> verificarDuplicata(Documento documento) async {
    QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento());

    query = query
      ..whereEqualTo(Documento.keyAssuntoBase, documento.assuntoBase)
      ..whereEqualTo(Documento.keyTipo, documento.tipo)
      ..whereEqualTo(Documento.keySequencial, documento.sequencial)
      ..whereEqualTo(Documento.keyIdioma, documento.idioma)
      ..whereEqualTo(Documento.keyFolha, documento.folha)
      ..whereEqualTo(Documento.keyRevisao, documento.revisao)
      ..includeObject([Documento.keyPacote]);
    final ParseResponse apiResponse = await query.query();
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results?.first;
    } else {
      return null;
    }
  }

  /// Registra o documento no banco de dados
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
