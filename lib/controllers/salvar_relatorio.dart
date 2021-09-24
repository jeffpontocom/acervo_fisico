import 'package:acervo_fisico/models/pacote.dart';
import 'package:acervo_fisico/models/relatorio.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../main.dart';

Future<ParseResponse?> salvarRelatorio(
    int tipo, String mensagem, Pacote pacote) async {
  final registration = Relatorio()
    ..set(Relatorio.keyTipo, tipo)
    ..set(Relatorio.keyMensagem, mensagem)
    ..set(Relatorio.keyPacote, pacote)
    ..set(Relatorio.keyGeradoPor, currentUser);
  return await registration.save();
}
