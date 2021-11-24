import 'package:acervo_fisico/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../styles/app_styles.dart';
import '../views/mensagens.dart';
import 'pacote_query.dart';
import 'relatorio_add.dart';

class NovoPacote {
  final BuildContext context;

  TipoPacote _pacoteTipo = TipoPacote.CAIXA_A4;
  late Function(TipoPacote) callback;
  TextEditingController _controleId = TextEditingController();

  /* WIDGETS */

  /// Campo de identificação
  Widget get _identificador {
    return TextFormField(
      controller: _controleId,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        UpperCaseTextFormatter(),
        FilteringTextInputFormatter.deny(' ')
      ],
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Ex.: 20211231.1',
      ),
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  /// Imagem de tipo
  Widget get _tipoImagem {
    return Image(
      image: getTipoPacoteImagem(_pacoteTipo),
      height: 128,
      width: 128,
      fit: BoxFit.contain,
    );
  }

  /// Campo de seleção de tipo
  Widget get _tipo {
    return DropdownButton<TipoPacote>(
      value: _pacoteTipo,
      isExpanded: true,
      autofocus: false,
      alignment: Alignment.center,
      items: TipoPacote.values
          .map(
            (value) => new DropdownMenuItem(
              value: value,
              alignment: Alignment.center,
              child: new Text(
                getTipoPacoteString(value),
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
          .toList(),
      hint: Text('Tipo'),
      onChanged: (value) {
        callback(value ?? TipoPacote.CAIXA_A4);
      },
    );
  }

  NovoPacote(this.context) {
    Mensagem.bottomDialog(
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
                  });
                };
                return Row(
                  children: [
                    _tipoImagem,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _identificador,
                          const SizedBox(height: 12),
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
                    _controleId.text,
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
      Mensagem.simples(
          context: context,
          titulo: 'Atenção!',
          mensagem: 'Informe um código para o pacote.');
      return;
    }
    // Progresso
    Mensagem.aguardar(
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
      Mensagem.semConexao(context: context);
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
        Mensagem.simples(
            context: context,
            titulo: 'Erro!',
            mensagem:
                'Não foi possível criar o pacote. Verifique sua conexão e/ou login e tente mais tarde novamente.');
      } else {
        // Relatorio
        String relatorio = '''
*APP Acervo Físico*
Relatório de CRIAÇÃO 

Pacote: "${pacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy 'às' HH:mm", "pt_BR").format(DateTime.now())}
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
          Mensagem.semConexao(context: context);
        } else {
          // Abre ficha do pacote
          if (apiResponse.success && apiResponse.results != null) {
            irParaPacote(context, pacote);
          } else {
            Mensagem.simples(
                context: context,
                titulo: 'Erro!',
                mensagem:
                    'Houve algum problema na criação. Consulte se o pacote foi criado corretamente e tente novamente!');
          }
        }
      }
    } else {
      Navigator.pop(context); // Fecha progresso
      Mensagem.simples(
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
