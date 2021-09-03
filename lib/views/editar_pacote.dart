import 'package:acervo_fisico/models/pacote.dart';
import 'package:flutter/material.dart';

/// Item da lista.
class _PacoteItem extends StatelessWidget {
  _PacoteItem(this.pacote);

  final Pacote pacote;

  /// Returns details.
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
      '${pacote.identificador} (${pacote.tipoToString})',
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
            child: Text(
              'Predio: ${pacote.localPredio}',
            ),
          ),
          Text(
            'Estante: ${pacote.localNivel1}',
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Editar pacote"),
        ),
        body: ListView.builder(
            itemCount: 0,
            padding: const EdgeInsets.all(25.0),
            itemBuilder: (context, index) {
              return Text('teste');
            }));
  }
}
