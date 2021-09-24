import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/models/relatorio.dart';
import 'package:acervo_fisico/src/common.dart';
import 'package:acervo_fisico/views/messages.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'pacote_page.dart';

class PacoteRelatorios extends StatefulWidget {
  const PacoteRelatorios({Key? key}) : super(key: key);

  @override
  _PacoteRelatoriosState createState() => _PacoteRelatoriosState();
}

class _PacoteRelatoriosState extends State<PacoteRelatorios> {
  List<Relatorio> lista = [];

  Widget get listaRelatorios {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter alertState) {
      return NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.amber,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '${lista.length} ações sobre o pacote',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ];
          },
          body: lista.isEmpty
              ? Center(
                  child: Image(
                    image: AssetImage(
                        'assets/images/ufo.png'), //todo mudar essa imagem
                    height: 128,
                    width: 128,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      isThreeLine: true,
                      title: Text('${lista[index].tipoToString}'),
                      subtitle: Text(
                          '${mDateFormat.format(lista[index].createdAt!)}' +
                              '\n' +
                              'Por ${lista[index].geradoPor!.username}'),
                      trailing: Text('${index + 1}',
                          style: TextStyle(color: Colors.grey)),
                      onTap: () {
                        Message.showRelatorio(
                            context: context, message: lista[index].mensagem);
                      },
                    );
                  }));
    });
  }

  Future<List<dynamic>> getRelatorios() async {
    QueryBuilder<Relatorio> query = QueryBuilder<Relatorio>(Relatorio())
      ..whereEqualTo(Relatorio.keyPacote,
          (Pacote()..objectId = mPacote.objectId).toPointer())
      ..orderByDescending('createdAt')
      ..includeObject([Relatorio.keyGeradoPor]);
    final apiResponse = await query.query();

    if (apiResponse.statusCode == -1) {
      return [-1];
    }
    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results ?? [];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRelatorios(),
      builder: (ctx, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occured',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              lista = [];
            } else if (snapshot.data!.first == -1) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage('assets/images/band-aid.png'),
                      height: 128,
                      width: 128,
                    ),
                    Container(height: 24),
                    Text(
                      'Sem conexão com a internet.',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  ],
                ),
              );
            } else {
              lista = snapshot.data!.cast();
            }
            return listaRelatorios;
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
