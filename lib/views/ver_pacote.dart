import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'pt_BR');

class _PacoteDetalhe extends StatelessWidget {
  _PacoteDetalhe(this.pacote);

  final Pacote pacote;

  Widget get details {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [imagem, tipo, identificador],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            locPredio,
            locNivel1,
            locNivel2,
            locNivel3,
            observacoes,
            alteracoes,
          ],
        ),
        Padding(padding: EdgeInsets.all(16.0)),
        ElevatedButton.icon(
            onPressed: _editarPacote(),
            icon: Icon(Icons.edit),
            label: Text('Editar')),
      ],
    );
  }

  Widget get imagem {
    return Container(
      width: 64.0,
      height: 64.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        image: new DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/tubos_industriais.jpg')),
      ),
    );
  }

  Widget get tipo {
    return Text(
      '${pacote.tipoToString}',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Baumans',
      ),
    );
  }

  Widget get identificador {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${pacote.identificador}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }

  Widget get locPredio {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Prédio:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${pacote.localPredio}',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget get locNivel1 {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Estante:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${pacote.localNivel1}',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget get locNivel2 {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Divisão:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${pacote.localNivel2}',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget get locNivel3 {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Andar:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${pacote.localNivel3}',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget get observacoes {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4.0, // gap between lines
        //direction: Axis.horizontal, // main axis (rows or columns)
        children: [
          Text('Observações: ', style: const TextStyle(color: Colors.grey)),
          Text(pacote.observacao,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget get alteracoes {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Atualizado por: ', style: const TextStyle(color: Colors.grey)),
          Text(pacote.updatedBy?.username ?? 'Importação de dados',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(', em ', style: const TextStyle(color: Colors.grey)),
          Text('${_dateFormat.format(pacote.updatedAt!)}.',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      child: Flexible(child: details),
    );
  }
}

_editarPacote() {
  //ItemNaoLocalizado();
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
          title: Text('Pacote: ${widget.pacote.identificador}'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.business_rounded), text: "Localização"),
              Tab(icon: Icon(Icons.list_rounded), text: "Documentos"),
            ],
          ),
        ),
        body: TabBarView(children: [
          _PacoteDetalhe(widget.pacote),
          _PacoteDocumentos(widget.pacote.objectId!),
        ]),
      ),
    );
  }
}
