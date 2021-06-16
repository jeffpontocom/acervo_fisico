import 'package:acervo_fisico/models/documento.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'editar_pacote.dart';

String _pacoteId = '0001';
final DateFormat _dateFormat = DateFormat("dd MMM yyyy");

final pacoteRef = FirebaseFirestore.instance
    .collection('teste_pacotes')
    .doc(_pacoteId)
    .withConverter<Pacote>(
      fromFirestore: (snapshot, _) => Pacote.fromJson(snapshot.data()!),
      toFirestore: (pacote, _) => pacote.toJson(),
    );

class _PacoteDetalhe extends StatelessWidget {
  _PacoteDetalhe(this.pacote, this.reference);

  final Pacote pacote;
  final DocumentReference reference;

  /// Tela principal dos detalhes
  Widget get details {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 64),
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
      '${getTipoPacote(pacote.tipo)}',
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
          Text('${pacote.locPredio}',
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
          Text('${pacote.locNivel1}',
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
            child: Text('Prateleira:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${pacote.locNivel2}',
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
          Text('${pacote.locNivel3}',
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
          Text('${reference.id}',
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
          Text('${pacote.alterUser}',
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          Text(', em ',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('${_dateFormat.format(pacote.alterData.toDate())}.',
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
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

class _PacoteDocumentos extends StatelessWidget {
  _PacoteDocumentos(this.pacoteReferencia);
  final String pacoteReferencia;

  /// Tela principal dos detalhes
  Widget get details {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot<Documento>>(
              stream: FirebaseFirestore.instance
                  .collection('teste_documentos')
                  .where('pacote', isEqualTo: pacoteReferencia)
                  .orderBy(FieldPath.documentId, descending: false)
                  .withConverter<Documento>(
                    fromFirestore: (snapshots, _) =>
                        Documento.fromJson(snapshots.data()!),
                    toFirestore: (documento, _) => documento.toJson(),
                  )
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.hasError) {
                  return Center(
                    child: Text(snapshots.error.toString()),
                  );
                }
                if (!snapshots.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshots.data;
                return Center(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: data!.size,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(data.docs[index].id),
                        );
                      }),
                );
              }),
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
  final DocumentReference<Pacote> reference;

  VerPacote({Key? key, required this.pacote, required this.reference})
      : super(key: key);

  @override
  _VerPacoteState createState() => _VerPacoteState();
}

class _VerPacoteState extends State<VerPacote> {
  @override
  Widget build(BuildContext context) {
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
                      Tab(icon: Icon(Icons.business_rounded), text: "Local"),
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
              _PacoteDetalhe(widget.pacote, widget.reference),
              _PacoteDocumentos(widget.reference.id),
            ],
          ),
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       toolbarHeight: 196,
  //       // Mudar para SliverAppbar
  //       flexibleSpace: Container(
  //         decoration: BoxDecoration(
  //           image: DecorationImage(
  //             image: AssetImage('assets/images/tubos_industriais.jpg'),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       backgroundColor: Colors.transparent,
  //       title: Text("Físico localizado"),
  //     ),
  //     body: Center(child: _PacoteDetalhe(widget.pacote, widget.reference)),

  // body: StreamBuilder<DocumentSnapshot<Pacote>>(
  //     stream: pacoteRef.snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Center(
  //           child: Text(snapshot.error.toString()),
  //         );
  //       }
  //       if (!snapshot.hasData) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       final data = snapshot.requireData;
  //       return Center(child: _PacoteDetalhe(data.data()!, data.reference));
  //     }),

  //   );
  // }
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
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// OutlinedButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: Text('Retornar!'),
//         ),