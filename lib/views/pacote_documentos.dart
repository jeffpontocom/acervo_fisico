import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/styles/customs.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'pacote_page.dart';

class PacoteDocumentos extends StatefulWidget {
  const PacoteDocumentos({Key? key}) : super(key: key);

  @override
  _PacoteDocumentosState createState() => _PacoteDocumentosState();
}

class _PacoteDocumentosState extends State<PacoteDocumentos> {
  late List<Documento> lista;
  List<Documento> docsSelected = [];
  bool? allSelected = false;

  IconData get checkbox {
    if (allSelected == null) {
      return Icons.indeterminate_check_box;
    } else {
      return allSelected! ? Icons.check_box : Icons.check_box_outline_blank;
    }
  }

  Widget get listaDocumentos {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter alertState) {
      return NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverVisibility(
                visible: !mPacote.selado,
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: MySliverAppBarDelegate(
                    minHeight: 56,
                    maxHeight: 56,
                    child: Container(
                      color: Colors.blueGrey,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              alertState(() {
                                if (allSelected == null) {
                                  allSelected = true;
                                } else {
                                  allSelected = !allSelected!;
                                }
                                if (allSelected == true) {
                                  docsSelected.clear();
                                  docsSelected.addAll(lista);
                                } else if (allSelected == false) {
                                  docsSelected.clear();
                                }
                              });
                            },
                            icon: Icon(checkbox),
                            label: Text('Selecionar tudo'),
                          ),
                          allSelected == false
                              ? TextButton.icon(
                                  icon: Icon(Icons.add_circle_rounded),
                                  label: Text('ADICIONAR'),
                                  onPressed: () {
                                    //todo adicionar documentos
                                  },
                                )
                              : TextButton.icon(
                                  icon: Icon(Icons.delete_forever_rounded),
                                  label: Text('EXCLUIR'),
                                  onPressed: () {
                                    //todo excluir documentos (avisar sobre)
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.amber,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    docsSelected.isEmpty
                        ? '${lista.length} item(s) no pacote'
                        : '${docsSelected.length} item(s) selecionados',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ];
          },
          body: lista.isEmpty
              ? Center(
                  child: Image(
                    image: AssetImage('assets/images/ufo.png'),
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
                      leading: mPacote.selado
                          ? null
                          : Checkbox(
                              value: docsSelected.contains(lista[index]),
                              onChanged: (bool? value) {
                                alertState(() {
                                  value!
                                      ? docsSelected.add(lista[index])
                                      : docsSelected.remove(lista[index]);
                                  if (docsSelected.length == 0) {
                                    allSelected = false;
                                  } else if (docsSelected.length ==
                                      lista.length) {
                                    allSelected = true;
                                  } else {
                                    allSelected = null;
                                  }
                                });
                              },
                            ),
                      title: Text('${lista[index].toString()}'),
                      trailing: Text('${index + 1}',
                          style: TextStyle(color: Colors.grey)),
                      //dense: true,
                    );
                  }));
    });
  }

  Future<List<dynamic>> getDocumentos() async {
    QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento())
      ..whereEqualTo(Documento.keyPacote,
          (Pacote()..objectId = mPacote.objectId).toPointer())
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
      future: getDocumentos(),
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
            } else {
              lista = snapshot.data!.cast();
            }
            return listaDocumentos;
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}