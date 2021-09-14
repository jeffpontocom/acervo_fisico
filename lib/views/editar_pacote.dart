import 'package:acervo_fisico/models/pacote.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class _PacoteEditores extends StatelessWidget {
  _PacoteEditores(this.pacote);

  final Pacote pacote;

  Widget get identificador {
    return Text(
      '${pacote.identificador}',
    );
  }

  Widget get tipo {
    return Text(
      '${pacote.tipoToString}',
    );
  }

  Widget get locPredio {
    return Text(
      '${pacote.localPredio}',
    );
  }

  Widget get locNivel1 {
    return Text(
      '${pacote.localNivel1}',
    );
  }

  Widget get locNivel2 {
    return Text(
      '${pacote.localNivel2}',
    );
  }

  Widget get locNivel3 {
    return Text(
      '${pacote.localNivel3}',
    );
  }

  Widget get observacoes {
    return Text(
      pacote.observacao,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          identificador,
          tipo,
          locPredio,
          locNivel1,
          locNivel2,
          locNivel3,
          observacoes,
          Padding(padding: EdgeInsets.all(16.0)),
          ElevatedButton.icon(
              onPressed: () {
                _salvarPacote();
              },
              icon: Icon(Icons.edit),
              label: Text('Salvar')),
        ],
      ),
    );
  }

  void _salvarPacote() {
    // todo Salvar Pacote
  }
}

class EditarPacote extends StatefulWidget {
  final Pacote pacote;

  EditarPacote({Key? key, required this.pacote}) : super(key: key);

  @override
  _EditarPacoteState createState() => _EditarPacoteState();
}

class _EditarPacoteState extends State<EditarPacote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar pacote'),
      ),
      body: _PacoteEditores(widget.pacote),
    );
  }
}
