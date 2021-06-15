import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/views/dialog_nao_encontrado.dart';
import 'package:acervo_fisico/views/ver_pacote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocalizarPacote {
  final BuildContext context;
  final String query;

  LocalizarPacote(this.context, this.query) {
    // var pacote = FirebaseFirestore.instance
    //     .collection('teste_pacotes')
    //     .doc(query)
    //     .withConverter<Pacote>(
    //         fromFirestore: (snapshot, _) => Pacote.fromJson(snapshot.data()!),
    //         toFirestore: (pacote, _) => pacote.toJson())
    //     .get();

    // FutureBuilder<DocumentSnapshot>(
    //   future: pacote,
    //   builder:
    //       (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    //     if (snapshot.hasError) {
    //       return Text("Something went wrong");
    //     }

    //     if (snapshot.hasData && !snapshot.data!.exists) {
    //       //return Text("Document does not exist");
    //       return ItemNaoEcontrado(context);
    //     }

    //     if (snapshot.connectionState == ConnectionState.done) {
    //       return Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => VerPacote(
    //                   pacote: documentSnapshot.data()!,
    //                   reference: documentSnapshot.reference,
    //                 )),
    //       );
    //     }

    //     return showDialog(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return const Center(child: CircularProgressIndicator());
    //         });
    //   },
    // );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });

    FirebaseFirestore.instance
        .collection('teste_pacotes')
        .doc(query)
        .withConverter<Pacote>(
            fromFirestore: (snapshot, _) => Pacote.fromJson(snapshot.data()!),
            toFirestore: (pacote, _) => pacote.toJson())
        .get()
        .then((DocumentSnapshot<Pacote> documentSnapshot) {
      Navigator.pop(context); // Finaliza indicador de progresso.
      if (documentSnapshot.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerPacote(
                    pacote: documentSnapshot.data()!,
                    reference: documentSnapshot.reference,
                  )),
        );
      } else {
        ItemNaoEcontrado(context);
      }
    });
  }

  // Se não encontrar, mostrar dialogo de alerta

  // Se encontrar mais de uma opção, mostrar dialogo de seleção

  // Se encontrar termo exato, ir para Widget VerPacote()
}
