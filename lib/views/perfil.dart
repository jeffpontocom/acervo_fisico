import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../app_data.dart';
import 'messages.dart';

class UserPage extends StatelessWidget {
  static const routeName = '/perfil';

  @override
  Widget build(BuildContext context) {
    /* METODOS */

    /// Executa o logout do usuario
    void fazerLogout() async {
      Message.showAguarde(
        context: context,
        mensagem: 'Efetuando logout...',
      );
      var response = await AppData.currentUser!.logout();

      Modular.to.pop();
      if (response.success) {
        AppData.currentUser = null;
        Modular.to.maybePop(true);
      } else {
        Message.showMensagem(
            context: context,
            titulo: 'Erro!',
            mensagem:
                response.error?.message ?? 'Não foi possível executar a ação.');
      }
    }

    /* STATELESS WIDGET */
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_pin,
              size: 128,
            ),
            Text(
              '${AppData.currentUser!.username}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${AppData.currentUser!.emailAddress}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 128,
            ),
            Container(
              //height: 50,
              width: 200,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout_rounded),
                label: const Text('SAIR'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () => fazerLogout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
