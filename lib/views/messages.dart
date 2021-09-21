import 'package:flutter/material.dart';
import 'package:share/share.dart';

class Message {
  static void showSucesso(
      {required BuildContext context,
      required String message,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sucesso!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showErro(
      {required BuildContext context,
      required String message,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erro!"),
          content: Text(message),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showAlerta(
      {required BuildContext context,
      required String message,
      Function(bool)? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alerta!"),
          content: Text(message),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            OutlinedButton(
              child: const Text("CANCELAR"),
              onPressed: () {
                if (onPressed != null) {
                  onPressed(false);
                }
              },
            ),
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                if (onPressed != null) {
                  onPressed(true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showNotFound(
      {required BuildContext context, VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Item não localizado!"),
          content: Text('Verifique o código informado e tente novamente.'),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showRelatorio(
      {required BuildContext context,
      required String message,
      VoidCallback? onPressed}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Relatório',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    CloseButton(),
                  ],
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(message),
                  ),
                ),
                ElevatedButton.icon(
                  label: Text("Compartilhar"),
                  icon: Icon(Icons.share_rounded),
                  onPressed: () {
                    Share.share(message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
