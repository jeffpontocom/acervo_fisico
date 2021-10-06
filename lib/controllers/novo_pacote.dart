import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../controllers/localizar_pacote.dart';
import '../controllers/salvar_relatorio.dart';
import '../main.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../styles/app_styles.dart';
import '../views/messages.dart';

class NovoPacote {
  final BuildContext context;

  int _pacoteTipo = 2;
  String _pacoteId = '';

  Widget get tipo {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter innerState) {
      return Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 24,
        spacing: 24,
        children: [
          Hero(
            tag: 'imgPacote',
            child: Container(
              width: 96,
              height: 96,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: getTipoPacoteImagem(_pacoteTipo),
                ),
              ),
            ),
          ),
          DropdownButtonFormField<int>(
              value: _pacoteTipo,
              iconDisabledColor: Colors.transparent,
              decoration: mTextField.copyWith(
                labelText: 'Tipo',
                constraints: BoxConstraints(maxWidth: 480),
              ),
              autofocus: false,
              isExpanded: true,
              items: TipoPacote.values
                  .map(
                    (value) => new DropdownMenuItem(
                      value: value.index,
                      child: new Text(
                        getTipoPacoteString(value.index),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                innerState(() {
                  _pacoteTipo = value!;
                });
              }),
        ],
      );
    });
  }

  Widget get identificador {
    return TextField(
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Ex.: 20211231.1',
        constraints: BoxConstraints(maxWidth: 600),
      ),
      onChanged: (value) {
        _pacoteId = value;
      },
      autofocus: false,
      style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  NovoPacote(this.context) {
    Message.showBottomDialog(
      context: context,
      titulo: 'Novo pacote',
      conteudo: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            tipo,
            identificador,
            SizedBox(
              height: 48,
            ),
            ElevatedButton.icon(
              onPressed: () {
                _criarPacote(
                  _pacoteId.trim().toUpperCase(),
                  _pacoteTipo,
                );
              },
              icon: Icon(Icons.new_label_rounded),
              label: Text('Criar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _criarPacote(String codigo, int tipo) async {
    // Verifica a string
    if (codigo.isEmpty) {
      Message.showErro(
          context: context, message: 'Informe um código para o pacote.');
      return;
    }
    // Progresso
    Message.showProgressoComMessagem(
        context: context, message: 'Criando pacote...');
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
        Message.showErro(
            context: context,
            message:
                "Não foi possível criar o pacote. Verifique sua conexão e/ou login e tente mais tarde novamente.");
      } else {
        // Relatorio
        String relatorio = '''
*APP Acervo Físico*
Relatório de CRIAÇÃO do pacote: "${pacote.identificador}"

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
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
            Message.showErro(
                context: context,
                message:
                    'Houve algum problema na criação. Consulte se o pacote foi criado corretamente e tente novamente!');
          }
        }
      }
    } else {
      Navigator.pop(context); // Fecha progresso
      Message.showErro(
          context: context, message: 'Já existe um pacote com esse nome.');
    }
  }

  Future<Pacote?> salvarRegistro(String codigo, int tipo) async {
    final registration = Pacote()
      ..set(Pacote.keyId, codigo)
      ..set(Pacote.keyTipo, tipo)
      ..set(Pacote.keyUpdatedBy, currentUser)
      ..set(Pacote.keyUpdatedAct, PacoteAction.ABRIR.index)
      ..set(Pacote.keySelado, false)
      ..set(Pacote.keySeladoBy, currentUser)
      ..set('updatedAt', DateTime.now());
    final ParseResponse apiResponse = await registration.save();
    if (apiResponse.success) {
      return apiResponse.result;
    } else {
      return null;
    }
  }
}
