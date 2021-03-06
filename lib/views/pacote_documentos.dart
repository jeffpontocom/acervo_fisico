import 'package:acervo_fisico/controllers/docs_transf.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../controllers/docs_add.dart';
import '../controllers/docs_del.dart';
import '../models/documento.dart';
import '../models/pacote.dart';
import '../styles/customs.dart';
import 'pacote_page.dart';

class PacoteDocumentos extends StatefulWidget {
  const PacoteDocumentos({Key? key}) : super(key: key);

  @override
  _PacoteDocumentosState createState() => _PacoteDocumentosState();
}

class _PacoteDocumentosState extends State<PacoteDocumentos>
    with TickerProviderStateMixin {
  List<Documento> lista = [];
  List<Documento> docsSelected = [];
  List<bool> itemTapped = [];
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
              visible: !mPacote.selado && AppData.currentUser != null,
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: MySliverAppBarDelegate(
                  minHeight: 56,
                  maxHeight: 56,
                  child: Container(
                    color: Colors.blueGrey,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton.icon(
                          onPressed: lista.isEmpty
                              ? null
                              : () {
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
                          label: Text('Sele????o'),
                        ),
                        allSelected == false
                            ? TextButton.icon(
                                icon: Icon(Icons.add_circle_rounded),
                                label: Text('ADICIONAR'),
                                onPressed: () {
                                  adicionarDocs();
                                },
                              )
                            : Row(
                                children: [
                                  TextButton.icon(
                                    icon: Icon(Icons.transform_rounded),
                                    label: Text('TRANSFERIR'),
                                    onPressed: () {
                                      transferirDocs();
                                    },
                                  ),
                                  TextButton.icon(
                                    icon: Icon(Icons.delete_sweep_rounded),
                                    label: Text('EXCLUIR'),
                                    onPressed: () {
                                      eliminarDocs();
                                    },
                                  ),
                                ],
                              )
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
                      ? '${lista.length} documento(s) no pacote'
                      : '${docsSelected.length} selecionado(s)',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ];
        },
        body: lista.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage('assets/icons/ufo.png'),
                      height: 128,
                      width: 128,
                    ),
                    Container(height: 24),
                    Text(
                      'Nenhum documento no pacote.',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  ],
                ),
              )
            : Scrollbar(
                isAlwaysShown: true,
                showTrackOnHover: true,
                hoverThickness: 18,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: mPacote.selado || AppData.currentUser == null
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
                          style: TextStyle(
                              color: itemTapped[index]
                                  ? Colors.red
                                  : Colors.grey)),
                      onTap: () {
                        alertState(() {
                          itemTapped[index] = !itemTapped[index];
                        });
                      },
                      //dense: true,
                    );
                  },
                ),
              ),
      );
    });
  }

  void resetSelection() {
    docsSelected.clear();
    itemTapped = [];
    allSelected = false;
  }

  void adicionarDocs() {
    if (mPacote.objectId == null) return;
    AddDocumentos(
        context: context,
        pacoteId: mPacote.objectId!,
        provider: this,
        callback: () {
          setState(() {});
        });
  }

  void eliminarDocs() {
    DelDocumentos(
        context: context,
        documentosEliminar: docsSelected,
        provider: this,
        callback: () {
          setState(() {});
        });
  }

  void transferirDocs() {
    TransfDocumentos(
        context: context,
        docsParaTransferir: docsSelected,
        provider: this,
        callback: () {
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    resetSelection();
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
            } else if (snapshot.data!.first == -1) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage('assets/icons/band-aid.png'),
                      height: 128,
                      width: 128,
                    ),
                    Container(height: 24),
                    Text(
                      'Sem conex??o com a internet.',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  ],
                ),
              );
            } else {
              lista = snapshot.data!.cast();
            }
            itemTapped = List.filled(lista.length, false);
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

Future<List<dynamic>> getDocumentos() async {
  QueryBuilder<Documento> query = QueryBuilder<Documento>(Documento())
    ..whereEqualTo(Documento.keyPacote,
        (Pacote()..objectId = mPacote.objectId).toPointer())
    ..setLimit(500) // O padrao e 100
    ..orderByAscending(Documento.keyAssuntoBase)
    ..orderByAscending(Documento.keyTipo)
    ..orderByAscending(Documento.keySequencial)
    ..orderByAscending(Documento.keyIdioma)
    ..orderByAscending(Documento.keyRevisao)
    ..orderByAscending(Documento.keyFolha);
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
