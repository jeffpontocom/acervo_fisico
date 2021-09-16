import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';

import 'pacote_page.dart';

final DateFormat _dateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();

class PacoteLocalizacao extends StatefulWidget {
  PacoteLocalizacao({Key? key}) : super(key: key);

  @override
  _PacoteLocalizacaoState createState() => _PacoteLocalizacaoState();
}

class _PacoteLocalizacaoState extends State<PacoteLocalizacao> {
  Widget get imagem {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: 128,
      height: 128,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.lightBlue, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        image: new DecorationImage(
          fit: BoxFit.cover,
          image: mPacote.tipoImagem,
        ),
      ),
    );
  }

  Widget get tipo {
    return DropdownButtonFormField<int>(
        value: mPacote.tipo,
        iconDisabledColor: Colors.transparent,
        decoration: mTextField.copyWith(
          labelText: 'Tipo',
          enabled: editMode.value,
        ),
        isExpanded: true,
        items: TipoPacote.values
            .map(
              (value) => new DropdownMenuItem(
                value: value.index,
                enabled: editMode.value,
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
          setState(() {
            mPacote.tipo = value!;
          });
        });
  }

  Widget get identificador {
    return TextFormField(
      initialValue: mPacote.identificador,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Informe o código do pacote',
      ),
      style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
      onChanged: (value) {
        mPacote.identificador = value.toLowerCase().trim();
      },
    );
  }

  Widget get locPredio {
    return TextFormField(
      initialValue: mPacote.localPredio,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Prédio',
        icon: Icon(Icons.apartment_rounded),
      ),
      style: TextStyle(fontSize: 24),
      onChanged: (value) {
        mPacote.localPredio = value.toLowerCase().trim();
      },
    );
  }

  Widget get locNivel1 {
    return TextFormField(
      initialValue: mPacote.localNivel1,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Estante',
        icon: Icon(Icons.apps_rounded),
      ),
      style: TextStyle(fontSize: 24),
      onChanged: (value) {
        mPacote.localNivel1 = value.toLowerCase().trim();
      },
    );
  }

  Widget get locNivel2 {
    return TextFormField(
      initialValue: mPacote.localNivel2,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Divisão',
        icon: Icon(Icons.align_vertical_bottom_rounded),
      ),
      style: TextStyle(fontSize: 24),
      onChanged: (value) {
        mPacote.localNivel2 = value.toLowerCase().trim();
      },
    );
  }

  Widget get locNivel3 {
    return TextFormField(
      initialValue: mPacote.localNivel3,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Andar',
        icon: Icon(Icons.align_horizontal_left_rounded),
      ),
      style: TextStyle(fontSize: 24),
      onChanged: (value) {
        mPacote.localNivel3 = value.toLowerCase().trim();
      },
    );
  }

  Widget get observacoes {
    return TextFormField(
      initialValue: mPacote.observacao,
      enabled: editMode.value,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: 8,
      textAlignVertical: TextAlignVertical.top,
      decoration: mTextField.copyWith(
        labelText: 'Observações:',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onChanged: (value) {
        mPacote.observacao = value;
      },
    );
  }

  Widget get alteracoes {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Situação atual:',
            style: const TextStyle(color: Colors.grey, fontSize: 15)),
        Wrap(
          children: [
            Text('• ${mPacote.actionToString}',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text(' em ', style: const TextStyle(color: Colors.grey)),
            Text('${_dateFormat.format(mPacote.updatedAt)}.',
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        Wrap(
          children: [
            Text(
              '• Editado por ',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              mPacote.updatedBy?.username ?? 'Importação de dados',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Wrap(
          children: [
            Text(
              mPacote.selado ? '• Selado por ' : '• Aberto por ',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              mPacote.seladoBy?.username ?? '[Sem identificação]',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget get eliminar {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          mPacote.updatedAct = UpdatedAction.ELIMINAR.index;
          mPacote.updatedBy = currentUser;
          mPacote.updatedAt = DateTime.now();
        });
        //todo: eliminar pacote
      },
      icon: Icon(Icons.delete),
      label: Text('Eliminar Pacote'),
      style: OutlinedButton.styleFrom(
        primary: Colors.red,
        minimumSize: Size(150, 50),
      ),
    );
  }

  Widget get editarOuSalvar {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          if (editMode.value) {
            mPacote.updatedAct = UpdatedAction.SALVAR.index;
            mPacote.updatedBy = currentUser;
            mPacote.updatedAt = DateTime.now();
          }
          editMode.value = !editMode.value;
        });
      },
      icon: Icon(editMode.value
          ? Icons.save_rounded
          : Icons.edit_location_alt_rounded),
      label: Text(editMode.value ? 'Salvar' : 'Editar'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(150, 50),
      ),
    );
  }

  Widget get acoes {
    return currentUser != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              editMode.value ? eliminar : Container(),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              editarOuSalvar,
            ],
          )
        : Container();
  }

  /* Future<String> getUpdateByName() async {
    if (pacote.updatedBy?.objectId == null) {
      return 'Importação dos dados';
    }
    final resp =
        await ParseUser.forQuery().getObject(pacote.updatedBy!.objectId!);
    if (resp.success && resp.results != null) {
      return (resp.results!.first as ParseUser).username ??
          'Usuário não identificado';
    } else {
      return 'Importação dos dados';
    }
  } */

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    imagem,
                                    tipo,
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 24,
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    identificador,
                                    locPredio,
                                    locNivel1,
                                    locNivel2,
                                    locNivel3,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          observacoes,
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: acoes,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Padding(
                padding: EdgeInsets.all(32),
                child: alteracoes,
              ),
            ),
          ],
        ));
  }
}
