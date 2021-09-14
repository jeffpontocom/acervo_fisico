import 'package:acervo_fisico/main.dart';
import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/app_styles.dart';
import 'package:acervo_fisico/views/editar_pacote.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

final DateFormat _dateFormat = DateFormat('d MMMM yyyy', 'pt_BR');

TextEditingController _controllerId = new TextEditingController();
TextEditingController _controllerTipo = new TextEditingController();
TextEditingController _controllerPredio = new TextEditingController();
TextEditingController _controllerNivel1 = new TextEditingController();
TextEditingController _controllerNivel2 = new TextEditingController();
TextEditingController _controllerNivel3 = new TextEditingController();
TextEditingController _controllerObs = new TextEditingController();

class _PacoteDetalhe extends StatefulWidget {
  final Pacote pacote;

  _PacoteDetalhe({Key? key, required this.pacote}) : super(key: key);

  @override
  _PacoteDetalheState createState() => _PacoteDetalheState();
}

class _PacoteDetalheState extends State<_PacoteDetalhe> {
  bool edit = false;
  //_PacoteDetalhe(this.pacote);

  //final Pacote pacote;

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
          image: widget.pacote.tipoImagem,
        ),
      ),
    );
  }

  Widget get tipo {
    _controllerTipo.text = widget.pacote.tipoToString;
    return DropdownButtonFormField<int>(
        value: widget.pacote.tipo,
        iconDisabledColor: Colors.transparent,
        decoration: mTextField.copyWith(
          labelText: 'Tipo',
          enabled: edit,
        ),
        isExpanded: true,
        items: TipoPacote.values
            .map(
              (value) => new DropdownMenuItem(
                value: value.index,
                enabled: edit,
                child: new Text(
                  getTipoPacote(value.index),
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
            widget.pacote.tipo = value!;
          });
        });
  }

  Widget get identificador {
    _controllerId.text = widget.pacote.identificador;
    return TextField(
      controller: _controllerId,
      enabled: edit,
      decoration: mTextField.copyWith(
        labelText: 'Identificador',
        hintText: 'Informe o código do pacote',
      ),
      style: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  Widget get locPredio {
    _controllerPredio.text = widget.pacote.localPredio;
    return TextField(
      controller: _controllerPredio,
      enabled: edit,
      decoration: mTextField.copyWith(
        labelText: 'Prédio',
        icon: Icon(Icons.apartment_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get locNivel1 {
    _controllerNivel1.text = widget.pacote.localNivel1;
    return TextField(
      controller: _controllerNivel1,
      enabled: edit,
      decoration: mTextField.copyWith(
        labelText: 'Estante',
        icon: Icon(Icons.apps_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get locNivel2 {
    _controllerNivel2.text = widget.pacote.localNivel2;
    return TextField(
      controller: _controllerNivel2,
      enabled: edit,
      decoration: mTextField.copyWith(
        labelText: 'Divisão',
        icon: Icon(Icons.align_vertical_bottom_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get locNivel3 {
    _controllerNivel3.text = widget.pacote.localNivel3;
    return TextField(
      controller: _controllerNivel3,
      enabled: edit,
      decoration: mTextField.copyWith(
        labelText: 'Andar',
        icon: Icon(Icons.align_horizontal_left_rounded),
      ),
      style: TextStyle(fontSize: 24),
    );
  }

  Widget get observacoes {
    _controllerObs.text = widget.pacote.observacao;
    return TextField(
      controller: _controllerObs,
      enabled: edit,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: 8,
      textAlignVertical: TextAlignVertical.top,
      decoration: mTextField.copyWith(
        labelText: 'Observações',
      ),
    );
  }

  Widget get alteracoes {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AÇÕES', style: const TextStyle(color: Colors.grey)),
          Wrap(
            children: [
              Text('• ${widget.pacote.actionToString}',
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(' em ', style: const TextStyle(color: Colors.grey)),
              Text('${_dateFormat.format(widget.pacote.updatedAt!)}.',
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
                widget.pacote.updatedBy?.username ?? 'Importação de dados',
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              widget.pacote.selado
                  ? Wrap(
                      children: [
                        Text(
                          'e selado por ',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          widget.pacote.seladoBy?.username ??
                              'Sem identificação',
                          style: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget get eliminar {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          widget.pacote.updatedAct = UpdatedAction.ELIMINAR.index;
        });
        //todo: eliminar pacote
      },
      icon: Icon(Icons.delete),
      label: Text('Eliminar Pacote'),
      //style: ButtonStyle(),
      style: OutlinedButton.styleFrom(
        primary: Colors.red,
        minimumSize: Size(150, 50),
      ),
    );
  }

  Widget get editar {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          edit ? widget.pacote.updatedAct = UpdatedAction.SALVAR.index : null;
          //_editarPacote(context);
          edit = !edit;
        });
      },
      icon: Icon(edit ? Icons.save_rounded : Icons.edit_location_alt_rounded),
      label: Text(edit ? 'Salvar' : 'Editar'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(150, 50),
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
      child: SingleChildScrollView(
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
            alteracoes,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                edit ? eliminar : Container(),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                editar,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PacoteDocumentos extends StatelessWidget {
  _PacoteDocumentos(this.pacoteId);

  final String pacoteId;

  Future<List<dynamic>> getData() async {
    QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento())
      ..whereEqualTo(
          Documento.keyPacote, (Pacote()..objectId = pacoteId).toPointer())
      ..orderByAscending('assuntBase')
      ..orderByAscending('tipo')
      ..orderByAscending('sequencial')
      ..orderByAscending('idioma')
      ..orderByAscending('revisao')
      ..orderByAscending('folha');
    final apiResponse = await query.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results ?? [];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occured',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            if ((snapshot.data as List<dynamic>).isEmpty) {
              return Center(
                child: Text('Nenhum documento vinculado a este pacote.',
                    style: TextStyle(fontSize: 18)),
              );
            } else {
              final List<Documento> data =
                  (snapshot.data as List<ParseObject>).cast();
              return NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.amber,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '${data.length} item(s) no pacote',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ];
                },
                body: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index].toString()),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
              );
            }
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class VerPacote extends StatefulWidget {
  final Pacote pacote;

  VerPacote({Key? key, required this.pacote}) : super(key: key);

  @override
  _VerPacoteState createState() => _VerPacoteState();
}

class _VerPacoteState extends State<VerPacote> {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pacote'),
          actions: [
            widget.pacote.selado
                ? TextButton.icon(
                    onPressed: () {
                      setState(() {
                        abrirPacote();
                      });
                    },
                    icon: Icon(Icons.open_in_browser_rounded),
                    label: Text('ABRIR'),
                  )
                : TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selarPacote();
                      });
                    },
                    icon: Icon(Icons.verified_rounded),
                    label: Text('SELAR'),
                  ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.place), text: "Localização"),
              Tab(icon: Icon(Icons.list_rounded), text: "Documentos"),
            ],
          ),
        ),
        body: TabBarView(children: [
          _PacoteDetalhe(pacote: widget.pacote),
          _PacoteDocumentos(widget.pacote.objectId!),
        ]),
      ),
    );
  }

  void abrirPacote() {
    widget.pacote.selado = false;
    widget.pacote.updatedAct = UpdatedAction.ABRIR.index;
  }

  void selarPacote() {
    widget.pacote.selado = true;
    widget.pacote.seladoBy = currentUser;
    widget.pacote.updatedAct = UpdatedAction.SELAR.index;
  }
}
