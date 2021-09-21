import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/app_styles.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'pacote_page.dart';

final DateFormat _dateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();

class PacoteLocalizacao extends StatefulWidget {
  PacoteLocalizacao({Key? key}) : super(key: key);

  @override
  _PacoteLocalizacaoState createState() => _PacoteLocalizacaoState();
}

class _PacoteLocalizacaoState extends State<PacoteLocalizacao> {
  Widget get cabecalho {
    return Container(
      height: 56.0,
      color: Colors.blueGrey,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Dados básicos',
            style: Theme.of(context).primaryTextTheme.subtitle1,
          ),
          currentUser != null ? editarOuSalvar : Container(),
        ],
      ),
    );
  }

  Widget get imagem {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: 128,
      height: 128,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        //border: Border.all(color: Colors.lightBlue, width: 1),
        //borderRadius: BorderRadius.all(Radius.circular(16.0)),
        image: new DecorationImage(
          fit: BoxFit.cover,
          image: mPacote.tipoImagem,
        ),
      ),
    );
  }

  Widget get tipo {
    return editMode.value
        ? DropdownButtonFormField<int>(
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
                    //enabled: editMode.value,
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
            })
        : Container();
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
        Wrap(
          children: [
            Text('Situação atual: ',
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
        Wrap(
          children: [
            Text('• ', style: const TextStyle(color: Colors.grey)),
            Text('${mPacote.actionToString}',
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
    return TextButton.icon(
      onPressed: () {
        setState(() {
          mPacote.updatedAct = UpdatedAction.ELIMINAR.index;
          mPacote.updatedBy = currentUser;
          mPacote.updatedAt = DateTime.now();
        });
        //todo: eliminar pacote
      },
      icon: Icon(Icons.delete),
      label: Text('Eliminar pacote'),
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        minimumSize: Size(150, 50),
      ),
    );
  }

  Widget get editarOuSalvar {
    return TextButton.icon(
      label: Text(editMode.value ? 'SALVAR' : 'EDITAR'),
      icon: Icon(editMode.value
          ? Icons.save_rounded
          : Icons.edit_location_alt_rounded),
      onPressed: () {
        setState(() {
          if (editMode.value) {
            Message.showAlerta(
                context: context,
                message:
                    'Tem certeza que deseja salvar as alterações nos dados básicos deste pacote?',
                onPressed: (value) {
                  if (value) {
                    mPacote.updatedAct = UpdatedAction.SALVAR.index;
                    mPacote.updatedBy = currentUser;
                    mPacote.updatedAt = DateTime.now();
                  } else {
                    /* Future<Pacote> query = (QueryBuilder<Pacote>(Pacote())
                      ..whereEqualTo('objectId', mPacote.objectId)
                      ..find()
                      ..first()) as Future<Pacote>;
                    query.then((value) => mPacote = value); */
                  }
                  Navigator.pop(context);
                });
          }
          editMode.value = !editMode.value;
        });
      },
      style: TextButton.styleFrom(
        minimumSize: Size(double.minPositive, double.infinity),
      ),
    );
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
            cabecalho,
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24),
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
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: editMode.value ? eliminar : Container(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            editMode.value
                ? Container()
                : Container(
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: alteracoes,
                    ),
                  ),
          ],
        ));
  }
}
