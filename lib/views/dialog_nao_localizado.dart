import 'package:flutter/material.dart';

class ItemNaoLocalizado {
  ItemNaoLocalizado(context) {
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
}

class ItemSemVinculo {
  ItemSemVinculo(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Item sem vínculos!"),
          content: new Text(
              "O item atual não está vinculado a nenhum pacote.\nVerificar cadastro e realizar buscas no físico."),
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
}
