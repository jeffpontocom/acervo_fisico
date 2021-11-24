import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import 'mensagens.dart';

GlobalKey<FormState> _formPass = GlobalKey<FormState>();

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /* VARIAVEIS */
  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();

  /* METODOS */

  /// Executa o login do usuario
  void fazerLogin() async {
    final username = controllerUsername.text.trim();
    final password = controllerPassword.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Mensagem.simples(
          context: context,
          titulo: 'Atenção!',
          mensagem: 'Informe usuário e senha');
      return;
    }

    Mensagem.aguardar(
      context: context,
      mensagem: 'Efetuando login...',
    );
    var response = await ParseUser(username, password, null).login();

    Modular.to.pop();
    if (response.success) {
      AppData.currentUser = response.result as ParseUser;
      //Navigator.pop(context, true);
      Modular.to.maybePop(true);
    } else {
      Mensagem.simples(
          context: context,
          titulo: 'Erro!',
          mensagem:
              response.error?.message ?? 'Não foi possível executar a ação.');
    }
  }

  /// Abre dialogo para confirmar e-mail e solicitar redefinicao de senha
  void redefinirSenhaDialog() {
    Mensagem.bottomDialog(
      context: context,
      titulo: 'Redefinir senha',
      conteudo: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              editUser,
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.send_rounded),
                label: Text('SOLICITAR'),
                onPressed: () => redefinirSenha(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Executa solicitacao de redefinicao de senha
  void redefinirSenha() async {
    // Abre a tela de progresso
    Mensagem.aguardar(
      context: context,
      mensagem: 'Verificando e-mail...',
    );
    QueryBuilder<ParseUser> queryUsers =
        QueryBuilder<ParseUser>(ParseUser.forQuery());
    queryUsers
      ..whereEqualTo(ParseUser.keyEmailAddress, controllerUsername.text.trim());
    final ParseResponse parseResponse = await queryUsers.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        ParseUser user = parseResponse.results!.first;
        if (user.emailAddress == null) {
          user.emailAddress = controllerUsername.text.toLowerCase().trim();
        }
        await user.requestPasswordReset();
        Navigator.pop(context); // Fecha a tela de progresso
        Mensagem.simples(
            context: context,
            titulo: 'Sucesso!',
            mensagem:
                'As instruções para redefinir a senha foram enviadas por e-mail.',
            onPressed: () {
              Navigator.of(context).pop(); // Fecha a caixa de dialogo
            });
      } else {
        Navigator.pop(context); // Fecha a tela de progresso
        Mensagem.simples(
            context: context,
            titulo: 'Erro!',
            mensagem: 'Nenhum usuário encontrado com esse e-mail.');
      }
    } else {
      Navigator.pop(context); // Fecha a tela de progresso
      Mensagem.simples(
        context: context,
        titulo: 'Erro!',
        mensagem:
            parseResponse.error?.message ?? 'Não foi possível executar a ação.',
      );
    }
  }

  /* WIDGETS */

  Widget get editUser {
    return TextFormField(
      //key: _formUser,
      controller: controllerUsername,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'E-mail',
        border: OutlineInputBorder(),
        constraints: BoxConstraints(maxWidth: 600),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget get editSenha {
    return TextFormField(
      key: _formPass,
      controller: controllerPassword,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Senha',
        border: OutlineInputBorder(),
        constraints: BoxConstraints(maxWidth: 600),
      ),
      onChanged: (value) {
        setState(() {});
      },
      onFieldSubmitted:
          controllerUsername.text.isEmpty || controllerPassword.text.isEmpty
              ? null
              : (value) {
                  fazerLogin();
                },
    );
  }

  /* METODOS DO SISTEMA */

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
                editUser,
                const SizedBox(
                  height: 8,
                ),
                editSenha,
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    child: const Text(
                      'LOGIN',
                      softWrap: false,
                    ),
                    onPressed: controllerUsername.text.isEmpty ||
                            controllerPassword.text.isEmpty
                        ? null
                        : () => fazerLogin(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: 200,
                  height: 48,
                  child: TextButton(
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(color: Colors.red),
                      softWrap: false,
                    ),
                    onPressed: () => redefinirSenhaDialog(),
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
}
