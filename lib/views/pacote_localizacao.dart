import 'package:acervo_fisico/controllers/gerar_pdf.dart';
import 'package:acervo_fisico/views/pacote_documentos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../controllers/salvar_relatorio.dart';
import '../main.dart';
import '../models/documento.dart';
import '../models/enums.dart';
import '../models/pacote.dart';
import '../util/utils.dart';
import '../styles/app_styles.dart';
import '../views/messages.dart';
import 'pacote_page.dart';

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
    return Hero(
      tag: 'imgPacote',
      child: Container(
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
              constraints: BoxConstraints(maxWidth: 480),
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
      textInputAction: TextInputAction.next,
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Informe o código do pacote',
      ),
      style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  Widget get locPredio {
    return TextFormField(
      controller: _controlePredio,
      enabled: editMode.value,
      textInputAction: TextInputAction.next,
      decoration: mTextField.copyWith(
        labelText: 'Prédio',
        icon: Icon(Icons.apartment_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get locNivel1 {
    return TextFormField(
      controller: _controleNivel1,
      enabled: editMode.value,
      textInputAction: TextInputAction.next,
      decoration: mTextField.copyWith(
        labelText: 'Estante',
        icon: Icon(Icons.apps_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get locNivel2 {
    return TextFormField(
      controller: _controleNivel2,
      enabled: editMode.value,
      textInputAction: TextInputAction.next,
      decoration: mTextField.copyWith(
        labelText: 'Divisão',
        icon: Icon(Icons.align_vertical_bottom_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get locNivel3 {
    return TextFormField(
      controller: _controleNivel3,
      enabled: editMode.value,
      textInputAction: TextInputAction.next,
      decoration: mTextField.copyWith(
        labelText: 'Andar',
        icon: Icon(Icons.align_horizontal_left_rounded),
      ),
      style: TextStyle(fontSize: 24),
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
        constraints: BoxConstraints(maxWidth: 1200),
      ),
    );
  }

  Widget get alteracoes {
    var textColor = Colors.blueGrey.shade400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            Text('Situação atual: ',
                style: TextStyle(color: textColor, fontSize: 15)),
          ],
        ),
        Wrap(
          children: [
            Text('• ', style: TextStyle(color: textColor)),
            Text('${mPacote.actionToString}',
                style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.bold)),
            Text(' em ', style: TextStyle(color: textColor)),
            Text('${Util.mDateFormat.format(mPacote.updatedAt.toLocal())}.',
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        Wrap(
          children: [
            Text(
              '• Editado por ',
              style: TextStyle(color: textColor),
            ),
            Text(
              mPacote.updatedBy?.username ?? 'Importação de dados',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Wrap(
          children: [
            Text(
              mPacote.selado ? '• Selado por ' : '• Aberto por ',
              style: TextStyle(color: textColor),
            ),
            Text(
              mPacote.seladoBy?.username ?? '[Sem identificação]',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget get eliminar {
    return TextButton.icon(
      label: Text('Eliminar pacote'),
      icon: Icon(Icons.delete_forever_rounded),
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        minimumSize: Size(150, 50),
      ),
      onPressed: () {
        eliminarPacote();
      },
    );
  }

  Widget get gerarPdf {
    return ElevatedButton.icon(
      label: Text('Gerar PDF'),
      icon: Icon(Icons.picture_as_pdf_rounded),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(150, 50),
      ),
      onPressed: () {
        gerarPdfPacote();
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
        } else {
          setState(() {
            editMode.value = !editMode.value;
          });
        }
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
    Message.showAlerta3Opcoes(
        context: context,
        message:
            'Tem certeza que deseja salvar as alterações nos dados básicos deste pacote?',
        onPressed: (value) async {
          // fecha mensagem alerta
          Navigator.pop(context);
          if (value == null) {
            // Nao executa nada
            return;
          } else if (value == false) {
            // Desfaz alteracoes
            dadosOriginais();
          } else if (value == true) {
            // Abre progresso
            Message.showProgressoComMessagem(
                context: context, message: 'Salvando alterações...');
            // Relatorio
            String relatorio = '''
*APP Acervo Físico*
Relatório de EDIÇÃO do pacote: "${_controleId.text}"

Dados anteriores a modificação:
IDENTIFICADOR: ${mPacote.identificador != _controleId.text ? mPacote.identificador : "[sem alteração]"}
TIPO: ${mPacote.tipo != _controleTipo ? mPacote.tipoToString : "[sem alteração]"}
PRÉDIO: ${mPacote.localPredio != _controlePredio.text ? mPacote.localPredio : "[sem alteração]"}
ESTANTE: ${mPacote.localNivel1 != _controleNivel1.text ? mPacote.localNivel1 : "[sem alteração]"}
DIVISÃO: ${mPacote.localNivel2 != _controleNivel2.text ? mPacote.localNivel2 : "[sem alteração]"}
ANDAR: ${mPacote.localNivel3 != _controleNivel3.text ? mPacote.localNivel3 : "[sem alteração]"}
Observações: ${mPacote.observacao != _controleObs.text ? mPacote.observacao : "[sem alteração]"}

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
''';
            // executa alteracoes
            mPacote.tipo = _controleTipo;
            mPacote.identificador = _controleId.text;
            mPacote.localPredio = _controlePredio.text;
            mPacote.localNivel1 = _controleNivel1.text;
            mPacote.localNivel2 = _controleNivel2.text;
            mPacote.localNivel3 = _controleNivel3.text;
            mPacote.observacao = _controleObs.text;
            mPacote.updatedAct = PacoteAction.SALVAR.index;
            mPacote.updatedBy = currentUser;
            mPacote.updatedAt = DateTime.now();
            await mPacote.update();
            await salvarRelatorio(
              PacoteAction.SALVAR.index,
              relatorio,
              mPacote,
            );
            //fecha progresso
            Navigator.pop(context);
          }
          // fecha modo de edicao
          setState(() {
            editMode.value = false;
          });
          // atualiza interface pai
          widget.parentCall!();
        });
  }

  //// Gerar PDF com informações do pacote
  gerarPdfPacote() async {
    var lista = await getDocumentos();
    List<Documento> documentos = lista.cast();
    GerarPdfPage(pacote: mPacote, documentos: documentos).criarPaginas();
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
              // Relatorio
              String relatorio = '''
*APP Acervo Físico*
Relatório de ELIMINAÇÃO do pacote: "${mPacote.identificador}"

Dados do pacote:
IDENTIFICADOR: ${mPacote.identificador}
TIPO: ${mPacote.tipoToString}
PRÉDIO: ${mPacote.localPredio}
ESTANTE: ${mPacote.localNivel1}
DIVISÃO: ${mPacote.localNivel2}
ANDAR: ${mPacote.localNivel3}

Observações (anteriores): ${mPacote.observacao}
Observações (novas): ${_controleObs.text}

Executado em ${DateFormat("dd/MM/yyyy - HH:mm", "pt_BR").format(DateTime.now())}
Por ${currentUser!.username}
''';
              // NAO executar alteracoes
              // Apenas campos de updated
              mPacote.updatedAct = PacoteAction.ELIMINAR.index;
              mPacote.updatedBy = currentUser;
              mPacote.updatedAt = DateTime.now();
              await salvarEliminado();
              await salvarRelatorio(
                PacoteAction.ELIMINAR.index,
                relatorio,
                mPacote,
              );
              await mPacote.delete();
              //fecha progresso
              Navigator.pop(context);
              // Voltar a home page
              Navigator.pop(context);
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
            Expanded(
              child: Scrollbar(
                isAlwaysShown: true,
                showTrackOnHover: true,
                hoverThickness: 18,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
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
                            Flexible(
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
                        editMode.value
                            ? Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: (Util.tecladoVisivel(context)
                                    ? Container()
                                    : eliminar),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            editMode.value
                ? Container()
                : Container(
                    width: double.infinity,
                    color: Colors.blueGrey.shade100,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [alteracoes, gerarPdf],
                      ),
                    ),
                  ),
          ],
        ));
  }
}
