import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/views/dialog_nao_localizado.dart';
import 'package:acervo_fisico/views/ver_pacote.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class LocalizarPacote {
  final BuildContext context;
  final String query;

  LocalizarPacote(this.context, this.query) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        });
    savePerson().then((value) {
      print('Person: ${value.toString()}');
      Navigator.pop(context);
    });
    //final person = await getPerson(objectId!);
    //print('Person: ${person.toString()}');

    /*
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
        ItemNaoLocalizado(context);
      }
    }).onError((error, stackTrace) {
      print('Deu erro!');
    });
    */
  }

  // Se não encontrar, mostrar dialogo de alerta

  // Se encontrar mais de uma opção, mostrar dialogo de seleção

  // Se encontrar termo exato, ir para Widget VerPacote()
}

Future<String?> savePerson() async {
  final person = ParseObject('TestePacote')
    ..set('name', "John Snow")
    ..set('age', 27);
  await person.save();
  return person.objectId;
}
