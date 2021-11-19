import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../styles/app_styles.dart';
import '../views/messages.dart';
import 'pacote_query.dart';
import 'relatorio_add.dart';

class NovoPacote {
  final BuildContext context;

  TipoPacote _pacoteTipo = TipoPacote.CAIXA_A4;
  String _pacoteIdentificador = '';
  late Function(TipoPacote) callback;

  /* WIDGETS */

  /// Campo de identificação
  Widget get _identificador {
    return TextField(
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Ex.: 20211231.1',
      ),
      onChanged: (value) {
        _pacoteIdentificador = value;
      },
      autofocus: false,
      style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  /// Imagem de tipo
  Widget get _tipoImagem {
    return Image(
      image: getTipoPacoteImagem(_pacoteTipo),
      height: 96,
      width: 96,
      fit: BoxFit.contain,
    );
  }

  /// Campo de seleção de tipo
  Widget get _tipo {
    return DropdownButtonFormField<TipoPacote>(
        value: _pacoteTipo,
        decoration: mTextField.copyWith(
          labelText: 'Tipo',
        ),
        autofocus: false,
        isExpanded: true,
        items: TipoPacote.values
            .map(
              (value) => new DropdownMenuItem(
                value: value,
                child: new Text(
                  getTipoPacoteString(value),
                  /* style: TextStyle(
                    fontSize: 20,
                  ), */
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          callback(value ?? TipoPacote.CAIXA_A4);
        });
  }

  NovoPacote(this.context) {
    Message.showBottomDialog(
      context: context,
      titulo: 'Novo pacote',
      conteudo: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            children: [
              StatefulBuilder(
                  builder: (BuildContext context, StateSetter innerState) {
                callback = (value) {
                  innerState(() {
                    _pacoteTipo = value;
                    // execute change
                  });
                };
                return Row(
                  children: [
                    _tipoImagem,
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _identificador,
                          _tipo,
                        ],
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  _criarPacote(
                    _pacoteIdentificador,
                    _pacoteTipo.index,
                  );
                },
                icon: Icon(Icons.new_label_rounded),
                label: Text('CRIAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _criarPacote(String codigo, int tipo) async {
    codigo = codigo.toUpperCase().trim().replaceAll(' ', '');
    // Verifica a string
    if (codigo.isEmpty) {
      Message.showMensagem(
          context: context,
          titulo: 'Atenção!',
          mensagem: 'Informe um código para o pacote.');
      return;
    }
    // Progresso
    Message.showAguarde(
      context: context,
      mensagem: 'Criando pacote...',
    );
    // Consulta Previa
    List<dynamic> consultaPrevia;
    QueryBuilder<Pacote> query = QueryBuilder<Pacote>(Pacote())
      ..whereEqualTo(Pacote.keyId, codigo);
    final ParseResponse apiResponse = await query.query();
    // Se nao houver conexao
    if (apiResponse.statusCode == -1) {
      Navigator.pop(context); // Fecha progresso
      Message.showSemConexao(context: context);
      return;
    }
    // Capturar resposta
    if (apiResponse.success && apiResponse.results != null) {
      consultaPrevia = apiResponse.results ?? [];
    } else {
      consultaPrevia = [];
    }
    // Criacao
    if (consultaPrevia.isEmpty) {
      var pacote = await salvarRegistro(codigo, tipo);
      if (pacote == null) {
        Navigator.pop(context); // Fecha progresso
        Message.showMensagem(
            context: context,
            titulo: 'Erro!',
            mensagem:
                'Não foi possível criar o pacote. Verifique sua conexão e/ou login e tente mais tarde novamente.');
      } else {
        // Relatorio
        String relatorio = '''
*APP Acervo Físico*
Relatório de CRIAÇÃO do pacote: "${pacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${AppData.currentUser?.username ?? "**administrador**"}
''';
        var apiResponse = await salvarRelatorio(
          PacoteAction.CRIAR.index,
          relatorio,
          pacote,
        );
        // Fecha progresso
        Navigator.pop(context);
        // Fecha bottom dialog
        Navigator.pop(context);
        if (apiResponse.statusCode == -1) {
          Message.showSemConexao(context: context);
        } else {
          // Abre ficha do pacote
          if (apiResponse.success && apiResponse.results != null) {
            irParaPacote(context, pacote);
          } else {
            Message.showMensagem(
                context: context,
                titulo: 'Erro!',
                mensagem:
                    'Houve algum problema na criação. Consulte se o pacote foi criado corretamente e tente novamente!');
          }
        }
      }
    } else {
      Navigator.pop(context); // Fecha progresso
      Message.showMensagem(
          context: context,
          titulo: 'Erro!',
          mensagem: 'Já existe um pacote com esse nome.');
    }
  }

  Future<Pacote?> salvarRegistro(String codigo, int tipo) async {
    final registration = Pacote()
      ..set(Pacote.keyId, codigo)
      ..set(Pacote.keyTipo, tipo)
      ..set(Pacote.keyUpdatedBy, AppData.currentUser)
      ..set(Pacote.keyUpdatedAct, PacoteAction.ABRIR.index)
      ..set(Pacote.keySelado, false)
      ..set(Pacote.keySeladoBy, AppData.currentUser)
      ..set('updatedAt', DateTime.now());
    final ParseResponse apiResponse = await registration.save();
    if (apiResponse.success) {
      return apiResponse.result;
    } else {
      return null;
    }
  }
}
