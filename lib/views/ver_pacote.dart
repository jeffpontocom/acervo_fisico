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
  final DocumentReference<Pacote> reference;

  /// Tela principal dos detalhes
  Widget get details {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          foto,
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

  Widget get foto {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Image(
        image: AssetImage('assets/images/tubos_industriais.jpg'),
        height: 128,
      ),
    );
  }

  Widget get tipo {
    return Text(
      '${getTipoPacote(pacote.tipo)}',
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }

  Widget get locPredio {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Local:',
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
            child: Text('Tubo:',
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          Text('${reference.id}',
              style: const TextStyle(
                  fontSize: 24,
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
          Text('${_dateFormat.format(pacote.alterData)}.',
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

class VerPacote extends StatefulWidget {
  const VerPacote({Key? key}) : super(key: key);

  @override
  _VerPacoteState createState() => _VerPacoteState();
}

class _VerPacoteState extends State<VerPacote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Físico localizado"),
      ),
      body: StreamBuilder<DocumentSnapshot<Pacote>>(
          stream: pacoteRef.snapshots(),
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
            return Center(child: _PacoteDetalhe(data.data()!, data.reference));
          }),
    );
  }
}


// OutlinedButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: Text('Retornar!'),
//         ),