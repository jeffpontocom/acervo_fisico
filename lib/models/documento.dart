import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import '../models/pacote.dart';

class Documento extends ParseObject implements ParseCloneable {
  Documento() : super(TABLE_NAME);
  Documento.clone() : this();

  static const String TABLE_NAME = 'TesteDocumento';

  static const String keyAssuntoBase = 'assuntoBase';
  static const String keyTipo = 'tipo';
  static const String keySequencial = 'sequencial';
  static const String keyIdioma = 'idioma';
  static const String keyFolha = 'folha';
  static const String keyRevisao = 'revisao';
  static const String keyPacote = 'pacote';

  /// Simula a funcao clone devido ao Flutter nao utilizar reflexao
  @override
  clone(map) => Documento.clone()..fromJson(map);

  String get assuntoBase => get<String>(keyAssuntoBase) ?? '';
  set assuntoBase(String value) => set<String>(keyAssuntoBase, value);

  String get tipo => get<String>(keyTipo) ?? '';
  set tipo(String value) => set<String>(keyTipo, value);

  String get sequencial => get<String>(keySequencial) ?? '';
  set sequencial(String value) => set<String>(keySequencial, value);

  String get idioma => get<String>(keyIdioma) ?? '';
  set idioma(String value) => set<String>(keyIdioma, value);

  String get folha => get<String>(keyFolha) ?? '';
  set folha(String value) => set<String>(keyFolha, value);

  String get revisao => get<String>(keyRevisao) ?? '';
  set revisao(String value) => set<String>(keyRevisao, value);

  Pacote? get pacote => get<Pacote>(keyPacote);
  set pacote(Pacote? value) => set<Pacote>(keyPacote, value!);

  @override
  String toString() =>
      assuntoBase + tipo + sequencial + idioma + '(' + folha + ')' + revisao;
}
