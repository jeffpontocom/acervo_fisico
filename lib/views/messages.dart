import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          title: Text("Sucesso!"),
          content: Text(message),
          actions: <Widget>[
            MaterialButton(
              child: Text("OK"),
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
          title: Text("Erro!"),
          content: Text(message),
          actions: <Widget>[
            MaterialButton(
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

  static void showSemConexao({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sem conexão"),
          content: Text(
              'Impossível conectar ao banco de dados. Verifique sua internet!'),
          actions: <Widget>[
            MaterialButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alerta!"),
          content: Text(message),
          buttonPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            MaterialButton(
              child: const Text("CANCELAR"),
              textColor: Colors.grey,
              onPressed: () {
                if (onPressed != null) {
                  onPressed(false);
                }
              },
            ),
            MaterialButton(
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

  static void showAlerta3Opcoes(
      {required BuildContext context,
      required String message,
      required Function(bool?) onPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alerta!"),
          content: Text(message),
          buttonPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            MaterialButton(
              child: const Text("DESFAZER"),
              textColor: Colors.red,
              onPressed: () {
                onPressed(false);
              },
            ),
            SizedBox(
              width: 16,
            ),
            MaterialButton(
              child: const Text("CANCELAR"),
              textColor: Colors.grey,
              onPressed: () {
                onPressed(null);
              },
            ),
            MaterialButton(
              child: const Text("OK"),
              minWidth: 24,
              onPressed: () {
                onPressed(true);
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
            MaterialButton(
              child: Text("OK"),
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
            padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
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
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: SelectableText(message),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  label: Text(kIsWeb ? 'Copiar' : 'Compartilhar'),
                  icon: Icon(kIsWeb ? Icons.copy_rounded : Icons.share_rounded),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                    maximumSize: Size(500, 50),
                  ),
                  onPressed: () {
                    kIsWeb
                        ? Clipboard.setData(new ClipboardData(text: message))
                            .then((_) {
                            Message.showSucesso(
                                context: context,
                                message:
                                    'Relatório copiado para área de transferência');
                          })
                        : Share.share(message);
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (onPressed != null) onPressed();
    });
  }

  static void showProgressoComMessagem(
      {required BuildContext context, required String message}) {
    showDialog(
        barrierLabel: 'Teste',
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(24),
            children: [
              Center(
                child: Wrap(
                  spacing: 32,
                  runSpacing: 32,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(message),
                  ],
                ),
              ),
            ],
          );
        });
  }

  static void showProgressoComMedidor(
      {required BuildContext context,
      required String message,
      required LinearProgressIndicator progress}) {
    showDialog(
        barrierLabel: 'Teste',
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(24),
            children: [
              Center(
                child: Wrap(
                  spacing: 32,
                  runSpacing: 32,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(message),
                  ],
                ),
              ),
            ],
          );
        });
  }

  static void showBottomDialog(
      {required BuildContext context,
      required String titulo,
      Widget? conteudo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.3,
          maxHeight: MediaQuery.of(context).size.height * 0.8),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            top: 12,
            right: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.grey,
                ),
              ),
              Row(
                children: [
                  const CloseButton(),
                  Expanded(
                    child: Text(
                      '$titulo',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    width: 48,
                  )
                ],
              ),
              Flexible(
                child: conteudo ?? Container(),
              ),
            ],
          ),
        );
      },
    );
  }
}
