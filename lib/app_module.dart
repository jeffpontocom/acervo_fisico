import 'package:flutter_modular/flutter_modular.dart';

import 'views/home.dart';
import 'views/login.dart';
import 'views/pacote_page.dart';
import 'views/perfil.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => MyHomePage()),
    ChildRoute(LoginPage.routeName, child: (_, __) => LoginPage()),
    ChildRoute(UserPage.routeName, child: (_, __) => UserPage()),
    ChildRoute(PacotePage.routeName,
        child: (_, args) => PacotePage(mPacoteId: args.queryParams['id'])),
  ];
}
