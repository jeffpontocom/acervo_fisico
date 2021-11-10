import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../app_data.dart';
import '../models/pacote.dart';
import '../models/relatorio.dart';

Future<ParseResponse> salvarRelatorio(
    int tipo, String mensagem, Pacote pacote) async {
  final registration = Relatorio()
    ..set(Relatorio.keyTipo, tipo)
    ..set(Relatorio.keyMensagem, mensagem)
    ..set(Relatorio.keyPacote, pacote)
    ..set(Relatorio.keyGeradoPor, AppData.currentUser);
  return registration.save();
}
