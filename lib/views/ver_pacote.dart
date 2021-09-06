import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'pt_BR');

class _PacoteDetalhe extends StatelessWidget {
  _PacoteDetalhe(this.pacote);

  final Pacote pacote;

  /// Tela principal dos detalhes
  Widget get details {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tipo,
          locPredio,
          locNivel1,
          locNivel2,
          locNivel3,
          identificador,
          alteracoes,
        ],
      ),
    );
  }

  Widget get tipo {
    return Text(
      '${pacote.tipoToString}',
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        fontFamily: 'Baumans',
      ),
    );
  }

  Widget get locPredio {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Row(
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
      child: Row(
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
      child: Row(
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
      child: Row(
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

  Widget get identificador {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Identificador:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${pacote.identificador}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }

  Widget get alteracoes {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Row(
        children: [
          Text('Atualizado por: ',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(pacote.updatedBy?.username ?? 'Importação de dados',
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          Text(', em ',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('${_dateFormat.format(pacote.updatedAt!)}.',
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<String> getUpdateByName() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Row(
        children: [
          Flexible(child: details),
        ],
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
      ..orderByAscending('folha')
      ..orderByAscending('revisao');
    final apiResponse = await query.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results ?? [];
    } else {
      return [];
    }
  }

  /// Tela principal dos detalhes
  Widget get details {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
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
                  final List<Documento> data =
                      (snapshot.data as List<ParseObject>).cast();
                  return Container(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data[index].toString()),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 48),
                          );
                        }),
                  );
                }
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Row(
        children: [
          Flexible(child: details),
        ],
      ),
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
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      EdgeInsetsDirectional.only(start: 64, bottom: 18),
                  //centerTitle: true,
                  title: Text("Físico localizado",
                      style: TextStyle(
                          //color: Colors.white,
                          //fontSize: 16.0,
                          )),
                  background: Image(
                    image: AssetImage('assets/images/tubos_industriais.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                          icon: Icon(Icons.business_rounded),
                          text: "Localização"),
                      Tab(icon: Icon(Icons.list_rounded), text: "Documentos"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _PacoteDetalhe(widget.pacote),
              _PacoteDocumentos(widget.pacote.objectId!),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
      color: Colors.white,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
