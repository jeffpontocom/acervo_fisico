import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class Message {
  /// Apresenta popup com uma mensagem simples
  static void showMensagem(
      {required BuildContext context,
      required String titulo,
      required String mensagem,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360),
            child: Text(mensagem),
          ),
          actions: [
            MaterialButton(
              child: Text('OK'),
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

  /// Apresenta popup com informação de erro na conexão com a internet
  static void showSemConexao({required BuildContext context}) {
    showMensagem(
        context: context,
        titulo: 'Sem conexão!',
        mensagem:
            'Impossível conectar ao banco de dados. Verifique sua internet!');
  }

  /// Apresenta popup com a informação "Não localizado"
  static void showNotFound(
      {required BuildContext context, VoidCallback? onPressed}) {
    showMensagem(
        context: context,
        titulo: 'Item não localizado!',
        mensagem: 'Verifique o código informado e tente novamente.',
        onPressed: onPressed);
  }

  /// Apresenta popup com indicador de execução
  static void showAguarde(
      {required BuildContext context,
      String? titulo,
      required String mensagem}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(24),
            title: Text(titulo ?? 'Aguarde'),
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 360),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text(mensagem),
                  ],
                ),
              ),
            ],
          );
        });
  }

  /// Apresenta popup de alerta
  static void showExecutar(
      {required BuildContext context,
      required String titulo,
      required String mensagem,
      Widget? extra,
      Function(bool)? onPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mensagem),
                extra ?? SizedBox(),
              ],
            ),
          ),
          buttonPadding: EdgeInsets.all(0),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            MaterialButton(
              child: const Text('CANCELAR'),
              textColor: Colors.grey,
              onPressed: () {
                if (onPressed != null) {
                  onPressed(false);
                }
              },
            ),
            MaterialButton(
              child: const Text('OK'),
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

  /// Apresenta popup no padrão bottom dialog
  static void showBottomDialog({
    required BuildContext context,
    required String titulo,
    required Widget conteudo,
    ScrollController? scrollController,
    VoidCallback? onPressed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.3,
          maxHeight: MediaQuery.of(context).size.height * 0.9),
      builder: (context) {
        var bordas = (MediaQuery.of(context).size.width - 640) / 2;
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewInsets.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: bordas > 0 ? bordas : 0,
            right: bordas > 0 ? bordas : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 4,
                margin: EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  color: Colors.black38,
                ),
              ),
              Row(
                children: [
                  const CloseButton(),
                  Expanded(
                    child: Text(
                      '$titulo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: kIsWeb ? 40 : 48,
                  )
                ],
              ),
              Flexible(
                child: Scrollbar(
                  isAlwaysShown: true,
                  showTrackOnHover: true,
                  hoverThickness: 18,
                  controller: scrollController,
                  child: conteudo,
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (onPressed != null) onPressed();
    });
  }

  /// Apresenta popup de relatório (com texto selecionável)
  static void showRelatorio({
    required BuildContext context,
    required String message,
    VoidCallback? onPressed,
  }) {
    ScrollController _scrollControler = ScrollController();
    // Conteudo
    Widget conteudo = SingleChildScrollView(
      controller: _scrollControler,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SelectableText(
                  message,
                  toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              label: Text(kIsWeb ? 'COPIAR' : 'COMPARTILHAR'),
              icon: Icon(kIsWeb ? Icons.copy_rounded : Icons.share_rounded),
              onPressed: () {
                kIsWeb
                    ? Clipboard.setData(new ClipboardData(text: message))
                        .then((_) {
                        Message.showMensagem(
                          context: context,
                          titulo: 'Sucesso!',
                          mensagem:
                              'Relatório copiado para área de transferência.',
                        );
                      })
                    : Share.share(message);
              },
            ),
          ],
        ),
      ),
    );
    // Bottom Dialog padrão
    showBottomDialog(
      context: context,
      titulo: 'Relatório',
      conteudo: conteudo,
      scrollController: _scrollControler,
      onPressed: onPressed,
    );
  }

  /// Apresenta popup no padrão bottom dialog
  static void showPdf(
      {required BuildContext context,
      required String titulo,
      required Widget conteudo}) {
    ScrollController _scrollControler = ScrollController();
    showBottomDialog(
      context: context,
      titulo: titulo,
      conteudo: SingleChildScrollView(
        controller: _scrollControler,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: conteudo,
        ),
      ),
      scrollController: _scrollControler,
    );
  }
}
