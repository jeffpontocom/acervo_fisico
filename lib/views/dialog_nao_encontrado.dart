import 'package:flutter/material.dart';

class ItemNaoEcontrado {
  ItemNaoEcontrado(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Item não localizado!"),
          content: new Text("Verifique o código informado e tente novamente."),
          actions: <Widget>[
            // define os botões na base do dialogo
            new MaterialButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return AlertDialog(
  //     content: Text('Item não encontrado'),
  //   );
  // }
}
