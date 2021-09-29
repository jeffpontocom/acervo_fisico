import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'messages.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /* METODOS */

    /// Executa o logout do usuario
    void fazerLogout() async {
      var response = await currentUser!.logout();
      if (response.success) {
        currentUser = null;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        Message.showErro(context: context, message: response.error!.message);
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
              '${currentUser!.username}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${currentUser!.emailAddress}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 128,
            ),
            Container(
              height: 50,
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
