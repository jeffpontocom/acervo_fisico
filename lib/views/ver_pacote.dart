import 'package:flutter/material.dart';

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
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Retornar!'),
        ),
      ),
    );
  }
}
