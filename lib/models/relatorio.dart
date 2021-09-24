import 'package:acervo_fisico/models/enums.dart';
import 'package:acervo_fisico/models/pacote.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Relatorio extends ParseObject implements ParseCloneable {
  Relatorio() : super(TABLE_NAME);
  Relatorio.clone() : this();

  static const String TABLE_NAME = 'Relatorio';
  static const String keyTipo = 'tipo';
  static const String keyMensagem = 'mensagem';
  static const String keyPacote = 'pacote';
  static const String keyGeradoPor = 'geradoPor';

  @override
  clone(map) => Relatorio.clone()..fromJson(map);

  int get tipo => get<int>(keyTipo) ?? 99;
  set tipo(int value) => set<int>(keyTipo, value);

  String get mensagem => get<String>(keyMensagem) ?? '';
  set mensagem(String value) => set<String>(keyMensagem, value);

  Pacote? get pacote => get<Pacote>(keyPacote);
  set pacote(Pacote? value) => set<Pacote>(keyPacote, value!);

  ParseUser? get geradoPor => get<ParseUser>(keyGeradoPor);
  set geradoPor(ParseUser? value) => set<ParseUser>(keyGeradoPor, value!);

  /// Retorna a acao realizada no pacote
  String get tipoToString {
    return getTipoRelatorioString(tipo);
  }
}
