import 'package:acervo_fisico/models/pacote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';

//final DateFormat _dateFormat = DateFormat("dd/MM/yyyy");

String getTipoPacote(int tipo) {
  switch (tipo) {
    case 0:
      return 'Tubo';
    case 1:
      return 'Pasta';
    case 2:
      return 'Caixa';
    case 3:
      return 'Mapoteca';
    default:
      return 'Pacote indefinido';
  }
}

final pacotesRef = FirebaseFirestore.instance
    .collection('teste_pacotes')
    .withConverter<Pacote>(
      fromFirestore: (snapshots, _) => Pacote.fromJson(snapshots.data()!),
      toFirestore: (pacote, _) => pacote.toJson(),
    );

/// Item da lista.
class _PacoteItem extends StatelessWidget {
  _PacoteItem(this.pacote, this.reference);

  final Pacote pacote;
  final DocumentReference<Pacote> reference;

  /// Returns the movie poster.
  // Widget get poster {
  //   return SizedBox(
  //     width: 100,
  //     child: Center(
  //       child: Image.network(pacote.poster),
  //     ),
  //   );
  // }

  /// Returns movie details.
  Widget get details {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          locPredio,
        ],
      ),
    );
  }

  /// Return the movie title.
  Widget get title {
    return Text(
      '${reference.id} (${getTipoPacote(pacote.tipo)})',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// Returns metadata about the movie.
  Widget get locPredio {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Predio: ${pacote.locPredio}'),
          ),
          Text('Estante: ${pacote.locNivel1}'),
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
          //poster,
          Flexible(child: details),
        ],
      ),
    );
  }
}

class EditarPacote extends StatefulWidget {
  const EditarPacote({Key? key}) : super(key: key);

  @override
  _EditarPacoteState createState() => _EditarPacoteState();
}

class _EditarPacoteState extends State<EditarPacote> {
  late Query<Pacote> _pacotesQuery;
  late Stream<QuerySnapshot<Pacote>> _pacotes;

  @override
  void initState() {
    super.initState();
    _updatePacotesQuery();
  }

  void _updatePacotesQuery() {
    setState(() {
      _pacotesQuery = pacotesRef;
      _pacotes = _pacotesQuery.snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar pacote"),
      ),
      body: StreamBuilder<QuerySnapshot<Pacote>>(
          stream: _pacotes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.requireData;

            return ListView.builder(
                itemCount: data.size,
                padding: const EdgeInsets.all(25.0),
                itemBuilder: (context, index) {
                  return _PacoteItem(
                    data.docs[index].data(),
                    data.docs[index].reference,
                  );
                });
          }),

      // body: StreamBuilder(
      //     stream: FirebaseFirestore.instance
      //         .collection('teste_pacotes')
      //         .snapshots(),
      //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      //       if (snapshot.hasError) {
      //         return Center(
      //           child: Text(snapshot.error.toString()),
      //         );
      //       }
      //       if (!snapshot.hasData) {
      //         return Center(
      //           child: CircularProgressIndicator(
      //             valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      //           ),
      //         );
      //       }
      //       List<Pacote> pacotes = snapshot.data!.docs
      //           .map((document) => Pacote.fromMap(document))
      //           .toList();
      //       return ListView.builder(
      //           itemCount: snapshot.data!.docs.length,
      //           padding: const EdgeInsets.all(25.0),
      //           itemBuilder: (context, index) {
      //             Pacote pacote = pacotes[index];
      //             //DocumentSnapshot ds = snapshot.data!.docs[index];
      //             return ListTile(
      //               title: Text(pacote.tipo),
      //               subtitle: Text(_dateFormat.format(pacote.changeDate)),
      //               trailing: Icon(Icons.keyboard_arrow_right),
      //             );
      //             //Text(
      //             //  '${ds['titulo']}:\n${ds['conteudo']}\n---',
      //             //  style: TextStyle(fontSize: 14.0),
      //             //);
      //           });
      //     }),
    );

    // Container(
    //     child: StreamBuilder<List<Pacote>>(
    //         stream: getPacotes(),
    //         builder: (context, snapshot) {
    //           if (!snapshot.hasData) {
    //             return Center(
    //               child: CircularProgressIndicator(
    //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
    //               ),
    //             );
    //           }
    //           return Container(
    //             child: ListView(
    //               children: snapshot.data!.map((pacote) {
    //                 return Dismissible(
    //                   key: Key(pacote.documentId()),
    //                   // onDismissed: (direction) {
    //                   //   _bloc.delete(person.documentId());
    //                   // },
    //                   child: ListTile(
    //                     title: Text(pacote.tipo),
    //                     subtitle:
    //                         Text(_dateFormat.format(pacote.changeDate)),
    //                     trailing: Icon(Icons.keyboard_arrow_right),
    //                     // onTap: () {
    //                     //   Navigator.push(
    //                     //     context,
    //                     //     MaterialPageRoute(
    //                     //         builder: (context) => PersonPage(person)),
    //                     //   );
    //                     // },
    //                   ),
    //                 );
    //               }).toList(),
    //             ),
    //           );
    //         })));
  }
}
