import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../app_data.dart';
import 'mensagens.dart';

class UserPage extends StatelessWidget {
  static const routeName = '/perfil';

  @override
  Widget build(BuildContext context) {
    /* METODOS */

    /// Executa o logout do usuario
    void fazerLogout() async {
      Mensagem.aguardar(
        context: context,
        mensagem: 'Efetuando logout...',
      );
      var response = await AppData.currentUser!.logout();

      Modular.to.pop();
      if (response.success) {
        AppData.currentUser = null;
        Modular.to.maybePop(true);
      } else {
        Mensagem.simples(
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
        child: Scrollbar(
          isAlwaysShown: true,
          showTrackOnHover: true,
          hoverThickness: 18,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Hero(
                  tag: 'perfil',
                  child: Image(
                    height: 128,
                    width: 128,
                    fit: BoxFit.contain,
                    image: AssetImage('assets/icons/data-management.png'),
                  ),
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
                const SizedBox(
                  height: 64,
                  width: double.infinity,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.logout_rounded),
                  label: const Text('SAIR'),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () => fazerLogout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
