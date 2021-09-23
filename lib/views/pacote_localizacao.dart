import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/src/common.dart';
import 'package:acervo_fisico/styles/app_styles.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:acervo_fisico/views/pacote_documentos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'home.dart';
import 'pacote_page.dart';

final DateFormat _dateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();

class PacoteLocalizacao extends StatefulWidget {
  PacoteLocalizacao({Key? key, this.parentCall}) : super(key: key);
  final VoidCallback? parentCall;

  @override
  _PacoteLocalizacaoState createState() => _PacoteLocalizacaoState();
}

class _PacoteLocalizacaoState extends State<PacoteLocalizacao> {
  // Controladores para campos do formulario
  int _controleTipo = mPacote.tipo;
  TextEditingController _controleId =
      TextEditingController(text: mPacote.identificador);
  TextEditingController _controlePredio =
      TextEditingController(text: mPacote.localPredio);
  TextEditingController _controleNivel1 =
      TextEditingController(text: mPacote.localNivel1);
  TextEditingController _controleNivel2 =
      TextEditingController(text: mPacote.localNivel2);
  TextEditingController _controleNivel3 =
      TextEditingController(text: mPacote.localNivel3);
  TextEditingController _controleObs =
      TextEditingController(text: mPacote.observacao);

  // Widgets
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
          image: getTipoPacoteImagem(_controleTipo),
        ),
      ),
    );
  }

  Widget get tipo {
    return editMode.value
        ? DropdownButtonFormField<int>(
            value: _controleTipo,
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
                _controleTipo = value!;
              });
            })
        : Container();
  }

  Widget get identificador {
    return TextFormField(
      controller: _controleId,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Informe o código do pacote',
      ),
      style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
      /* onChanged: (value) {        
        mPacote.identificador = value.toLowerCase().trim();
      }, */
    );
  }

  Widget get locPredio {
    return TextFormField(
      controller: _controlePredio,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Prédio',
        icon: Icon(Icons.apartment_rounded),
      ),
      style: TextStyle(fontSize: 24),
      /* onChanged: (value) {
        mPacote.localPredio = value.toLowerCase().trim();
      }, */
    );
  }

  Widget get locNivel1 {
    return TextFormField(
      controller: _controleNivel1,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Estante',
        icon: Icon(Icons.apps_rounded),
      ),
      style: TextStyle(fontSize: 24),
      /* onChanged: (value) {
        mPacote.localNivel1 = value.toLowerCase().trim();
      }, */
    );
  }

  Widget get locNivel2 {
    return TextFormField(
      controller: _controleNivel2,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Divisão',
        icon: Icon(Icons.align_vertical_bottom_rounded),
      ),
      style: TextStyle(fontSize: 24),
      /* onChanged: (value) {
        mPacote.localNivel2 = value.toLowerCase().trim();
      }, */
    );
  }

  Widget get locNivel3 {
    return TextFormField(
      controller: _controleNivel3,
      enabled: editMode.value,
      decoration: mTextField.copyWith(
        labelText: 'Andar',
        icon: Icon(Icons.align_horizontal_left_rounded),
      ),
      style: TextStyle(fontSize: 24),
      /* onChanged: (value) {
        mPacote.localNivel3 = value.toLowerCase().trim();
      }, */
    );
  }

  Widget get observacoes {
    return TextFormField(
      controller: _controleObs,
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
      /* onChanged: (value) {
        mPacote.observacao = value;
      }, */
    );
  }

  Widget get alteracoes {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            Text('Situação atual: ',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
        Wrap(
          children: [
            Text('• ', style: const TextStyle(color: Colors.grey)),
            Text('${mPacote.actionToString}',
                style: TextStyle(
                    color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            Text(' em ', style: const TextStyle(color: Colors.grey)),
            Text('${_dateFormat.format(mPacote.updatedAt.toLocal())}.',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        Wrap(
          children: [
            Text(
              '• Editado por ',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              mPacote.updatedBy?.username ?? 'Importação de dados',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
      label: Text('Eliminar pacote'),
      icon: Icon(Icons.delete),
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        minimumSize: Size(150, 50),
      ),
      onPressed: () {
        eliminarPacote();
      },
    );
  }

  Widget get editarOuSalvar {
    return TextButton.icon(
      label: Text(editMode.value ? 'SALVAR' : 'EDITAR'),
      icon: Icon(editMode.value
          ? Icons.save_rounded
          : Icons.edit_location_alt_rounded),
      onPressed: () async {
        if (editMode.value) {
          await salvarAlteracoes();
        }
        setState(() {
          editMode.value = !editMode.value;
        });
      },
      style: TextButton.styleFrom(
        minimumSize: Size(double.minPositive, double.infinity),
      ),
    );
  }

  // METODOS

  /// Carrega os dados originais no controladores de texto
  /// (desfaz alteracoes no pacote)
  void dadosOriginais() {
    _controleTipo = mPacote.tipo;
    _controleId.text = mPacote.identificador;
    _controlePredio.text = mPacote.localPredio;
    _controleNivel1.text = mPacote.localNivel1;
    _controleNivel2.text = mPacote.localNivel2;
    _controleNivel3.text = mPacote.localNivel3;
    _controleObs.text = mPacote.observacao;
  }

  /// Salva as alteracoes no pacote
  Future<void> salvarAlteracoes() async {
    // abre mensagem alerta
    Message.showAlerta(
        context: context,
        message:
            'Tem certeza que deseja salvar as alterações nos dados básicos deste pacote?',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value) {
            // abre progresso
            Message.showProgressoComMessagem(
                context: context, message: 'Salvando alterações');
            // executa alteracoes
            mPacote.tipo = _controleTipo;
            mPacote.identificador = _controleId.text;
            mPacote.localPredio = _controlePredio.text;
            mPacote.localNivel1 = _controleNivel1.text;
            mPacote.localNivel2 = _controleNivel2.text;
            mPacote.localNivel3 = _controleNivel3.text;
            mPacote.observacao = _controleObs.text;
            mPacote.updatedAct = UpdatedAction.SALVAR.index;
            mPacote.updatedBy = currentUser;
            mPacote.updatedAt = DateTime.now();
            await mPacote.update();
            //fecha progresso
            Navigator.pop(context);
          } else {
            dadosOriginais();
          }
          // atualiza interface pai
          widget.parentCall!();
        });
  }

  /// Elimina o pacote
  Future<void> eliminarPacote() async {
    // verifica se existem documentos vinculados
    Message.showProgressoComMessagem(
        context: context, message: 'Verificando vinculos...');
    QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento())
      ..whereEqualTo(Documento.keyPacote,
          (Pacote()..objectId = mPacote.objectId).toPointer());
    final ParseResponse apiResponse = await query.query();
    Navigator.pop(context);
    if (apiResponse.success && apiResponse.results != null) {
      Message.showErro(
          context: context,
          message:
              'Não é possível eliminar pacotes que possuem documentos vinculados');
    } else {
      // abre mensagem alerta
      Message.showAlerta(
          context: context,
          message:
              'Tem certeza que deseja ELIMINAR o pacote "${mPacote.identificador}"?\n\nEssa ação não pode ser desfeita.',
          onPressed: (value) async {
            // fecha mensagem alerta
            Navigator.pop(context);
            if (value) {
              // abre progresso
              Message.showProgressoComMessagem(
                  context: context, message: 'Eliminando pacote...');
              // executa alteracoes
              mPacote.tipo = _controleTipo;
              mPacote.identificador = _controleId.text;
              mPacote.localPredio = _controlePredio.text;
              mPacote.localNivel1 = _controleNivel1.text;
              mPacote.localNivel2 = _controleNivel2.text;
              mPacote.localNivel3 = _controleNivel3.text;
              mPacote.observacao = _controleObs.text;
              mPacote.updatedAct = UpdatedAction.ELIMINAR.index;
              mPacote.updatedBy = currentUser;
              mPacote.updatedAt = DateTime.now();
              await salvarEliminado();
              await mPacote.delete();
              //fecha progresso
              Navigator.pop(context);
              // Voltar a home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => MyApp(),
                ),
              );
            }
          });
    }
  }

  Future<void> salvarEliminado() async {
    final eliminado = ParseObject('PacoteEliminado')
      ..set(Pacote.keyId, mPacote.identificador)
      ..set(Pacote.keyTipo, mPacote.tipo)
      ..set(Pacote.keyLocPredio, mPacote.localPredio)
      ..set(Pacote.keyLocN1, mPacote.localNivel1)
      ..set(Pacote.keyLocN2, mPacote.localNivel2)
      ..set(Pacote.keyLocN2, mPacote.localNivel2)
      ..set(Pacote.keyObs, mPacote.observacao)
      ..set(Pacote.keyGeoPoint, mPacote.geoPoint)
      ..set(Pacote.keySelado, mPacote.selado)
      ..set(Pacote.keySeladoBy, mPacote.seladoBy)
      ..set(Pacote.keyUpdatedAct, mPacote.updatedAct)
      ..set(Pacote.keyUpdatedBy, mPacote.updatedBy)
      ..set(Pacote.keyUpdatedAt, mPacote.updatedAt);
    await eliminado.save();
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
  void dispose() {
    _controleId.dispose();
    _controlePredio.dispose();
    _controleNivel1.dispose();
    _controleNivel2.dispose();
    _controleNivel3.dispose();
    _controleObs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            child: editMode.value
                                ? (tecladoVisivel(context)
                                    ? Container()
                                    : eliminar)
                                : Container(),
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
                    color: Colors.grey.shade200,
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
