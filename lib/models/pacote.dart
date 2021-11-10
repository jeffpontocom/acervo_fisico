import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import '../models/enums.dart';

class Pacote extends ParseObject implements ParseCloneable {
  Pacote() : super(className);
  Pacote.clone() : this();

  static final String className = kReleaseMode ? 'Pacote' : 'TestePacote';

  static const String keyId = 'identificador';
  static const String keyTipo = 'tipo';
  static const String keyLocPredio = 'localPredio';
  static const String keyLocN1 = 'localNivel1'; // Estante
  static const String keyLocN2 = 'localNivel2'; // Divisao
  static const String keyLocN3 = 'localNivel3'; // Andar
  static const String keyObs = 'observacao';
  static const String keyUpdatedAt = 'updatedAt';
  static const String keyUpdatedBy = 'updatedBy';
  static const String keyUpdatedAct = 'updatedAct';
  static const String keySelado = 'selado';
  static const String keySeladoBy = 'seladoBy';
  static const String keyGeoPoint = 'geoPoint';

  /// Simula a funcao clone devido ao Flutter nao utilizar reflexao
  @override
  clone(map) => Pacote.clone()..fromJson(map);

  String get identificador => get<String>(keyId) ?? '';
  set identificador(String value) => set<String>(keyId, value);

  int get tipo => get<int>(keyTipo) ?? TipoPacote.INDEFINIDO.index;
  set tipo(int value) => set<int>(keyTipo, value);

  String get localPredio => get<String>(keyLocPredio) ?? '';
  set localPredio(String value) => set<String>(keyLocPredio, value);

  String get localNivel1 => get<String>(keyLocN1) ?? '';
  set localNivel1(String value) => set<String>(keyLocN1, value);

  String get localNivel2 => get<String>(keyLocN2) ?? '';
  set localNivel2(String value) => set<String>(keyLocN2, value);

  String get localNivel3 => get<String>(keyLocN3) ?? '';
  set localNivel3(String value) => set<String>(keyLocN3, value);

  String get observacao => get<String>(keyObs) ?? '';
  set observacao(String value) => set<String>(keyObs, value);

  bool get selado => get<bool>(keySelado) ?? true;
  set selado(bool value) => set<bool>(keySelado, value);

  ParseUser? get seladoBy => get<ParseUser>(keySeladoBy);
  set seladoBy(ParseUser? value) => set<ParseUser>(keySeladoBy, value!);

  DateTime get updatedAt => get<DateTime>(keyUpdatedAt) ?? DateTime.now();
  set updatedAt(DateTime? value) => set<DateTime>(keyUpdatedAt, value!);

  ParseUser? get updatedBy => get<ParseUser>(keyUpdatedBy);
  set updatedBy(ParseUser? value) => set<ParseUser>(keyUpdatedBy, value!);

  int get updatedAct => get<int>(keyUpdatedAct) ?? PacoteAction.SELAR.index;
  set updatedAct(int value) => set<int>(keyUpdatedAct, value);

  ParseGeoPoint? get geoPoint => get<ParseGeoPoint>(keyGeoPoint);
  set geoPoint(ParseGeoPoint? value) => set<ParseGeoPoint>(keyGeoPoint, value!);

  /// Retorna a ultima acao realizada no pacote
  String get actionToString {
    return getPacoteActionString(updatedAct);
  }

  /// Retorna o tipo de pacote
  String get tipoToString {
    return getTipoPacoteString(tipo);
  }

  /// Retorna a imagem referente ao tipo de pacote
  get tipoImagem {
    return getTipoPacoteImagem(tipo);
  }
}
