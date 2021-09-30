import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../main.dart';
import '../models/pacote.dart';
import '../models/relatorio.dart';

Future<ParseResponse> salvarRelatorio(
    int tipo, String mensagem, Pacote pacote) async {
  final registration = Relatorio()
    ..set(Relatorio.keyTipo, tipo)
    ..set(Relatorio.keyMensagem, mensagem)
    ..set(Relatorio.keyPacote, pacote)
    ..set(Relatorio.keyGeradoPor, currentUser);
  return registration.save();
}
