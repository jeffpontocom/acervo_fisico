import 'package:acervo_fisico/views/home.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../main.dart';
import 'messages.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  @override
  void dispose() {
    controllerUsername.dispose();
    controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: controllerUsername,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: controllerPassword,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    controllerUsername.text.isEmpty ||
                            controllerPassword.text.isEmpty
                        ? null
                        : doUserLogin();
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    child: const Text('Login'),
                    onPressed: controllerUsername.text.isEmpty ||
                            controllerPassword.text.isEmpty
                        ? null
                        : () => doUserLogin(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 50,
                  width: 200,
                  child: OutlinedButton(
                    child: const Text('Esqueci minha senha'),
                    onPressed: () => navigateToResetPassword(),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Apenas usuários cadastrados pelo administrador tem acesso ao login.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ));
  }

  void doUserLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Message.showError(context: context, message: 'Informe usuário e senha');
      return;
    }

    final user = ParseUser(username, password, null);

    var response = await user.login();

    if (response.success) {
      currentUser = response.result as ParseUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => MyApp(),
        ),
      );
      /* Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (route) => false,
      ); */
    } else {
      Message.showError(context: context, message: response.error!.message);
    }
  }

  void navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
    );
  }
}

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void doUserLogout() async {
      var response = await currentUser!.logout();
      if (response.success) {
        currentUser = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => MyApp(),
          ),
        );
        /*Message.showSuccess(
            context: context,
            message: 'Logout realizado com sucesso!',
            onPressed: () {
              
      
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                (route) => false,
              ); 
            });*/
      } else {
        Message.showError(context: context, message: response.error!.message);
      }
    }

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
                onPressed: () => doUserLogout(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final controllerEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Redefinir senha'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: controllerEmail,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'E-mail'),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  child: const Text('Redefinir senha'),
                  onPressed: () => doUserResetPassword(),
                ),
              )
            ],
          ),
        ));
  }

  void doUserResetPassword() async {
    final ParseUser user = ParseUser(null, null, controllerEmail.text.trim());
    final ParseResponse parseResponse = await user.requestPasswordReset();
    if (parseResponse.success) {
      Message.showSuccess(
          context: context,
          message: 'As instruções para nova senha foram enviadas por e-mail!',
          onPressed: () {
            Navigator.of(context).pop();
          });
    } else {
      Message.showError(
          context: context, message: parseResponse.error!.message);
    }
  }
}
