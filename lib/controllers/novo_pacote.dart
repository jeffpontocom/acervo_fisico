import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/app_styles.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:acervo_fisico/views/pacote_page.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class NovoPacote {
  final BuildContext context;

  var _controllerId = TextEditingController();
  var _controllerTipo = 2;

  Widget get imagem {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      width: 64,
      height: 64,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.lightBlue, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        image: new DecorationImage(
          fit: BoxFit.cover,
          image: getTipoPacoteImagem(_controllerTipo),
        ),
      ),
    );
  }

  Widget get tipo {
    return DropdownButtonFormField<int>(
        value: _controllerTipo,
        iconDisabledColor: Colors.transparent,
        decoration: mTextField.copyWith(
          labelText: 'Tipo',
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
          _controllerTipo = value!;
        });
  }

  Widget get identificador {
    return TextField(
      controller: _controllerId,
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Ex.: 20211231.1',
      ),
      autofocus: false,
      style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  NovoPacote(this.context) {
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
                    'NOVO PACOTE',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  child: Column(
                    children: [
                      imagem,
                      tipo,
                      identificador,
                      SizedBox(
                        height: 48,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _criarPacote(
                            _controllerId.text.trim().toUpperCase(),
                            _controllerTipo,
                          );
                          _controllerId.dispose();
                        },
                        icon: Icon(Icons.save_rounded),
                        label: Text('Criar'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(150, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _criarPacote(String codigo, int tipo) async {
    // Verifica a string
    if (codigo.isEmpty) {
      Message.showError(
          context: context, message: 'Informar um codigo para o pacote!');
      return;
    }
    // Progresso
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });
    // Consulta Previa
    List<dynamic> consultaPrevia;
    QueryBuilder<Pacote> query = QueryBuilder<Pacote>(Pacote())
      ..whereEqualTo(Pacote.keyId, codigo);
    final ParseResponse apiResponse = await query.query();
    if (apiResponse.success && apiResponse.results != null) {
      consultaPrevia = apiResponse.results ?? [];
    } else {
      consultaPrevia = [];
    }
    // Criacao
    if (consultaPrevia.isEmpty) {
      var pacote = await salvarRegistro(codigo, tipo);
      Navigator.pop(context); // Fecha progresso
      if (pacote == null) {
        Message.showError(
            context: context,
            message:
                "Não foi possível criar o pacote. Verifique sua conexão e/ou login e tente mais tarde novamente.");
      } else {
        Navigator.pop(context); // Fecha bottom sheet
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PacotePage(
                    pacote: pacote,
                  )),
        );
      }
    } else {
      Navigator.pop(context); // Fecha progresso
      Message.showError(
          context: context, message: 'Já existe um pacote com esse nome.');
    }
  }

  Future<Pacote?> salvarRegistro(String codigo, int tipo) async {
    final registration = Pacote()
      ..set(Pacote.keyId, codigo)
      ..set(Pacote.keyTipo, tipo)
      ..set(Pacote.keyUpdatedBy, currentUser)
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
