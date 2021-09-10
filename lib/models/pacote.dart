import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Pacote extends ParseObject implements ParseCloneable {
  Pacote() : super(TABLE_NAME);
  Pacote.clone() : this();

  static const String TABLE_NAME = 'TestePacote';
  static const String keyId = 'identificador';
  static const String keyTipo = 'tipo';
  static const String keyLocPredio = 'localPredio';
  static const String keyLocN1 = 'localNivel1'; // Estante
  static const String keyLocN2 = 'localNivel2'; // Divisao
  static const String keyLocN3 = 'localNivel3'; // Andar
  static const String keyObs = 'observacao';
  static const String keyUpdatedBy = 'updatedBy';
  static const String keyGeoPoint = 'geoPoint';

  /// Looks strangely hacky but due to Flutter not using reflection, we have to
  /// mimic a clone
  @override
  clone(map) => Pacote.clone()..fromJson(map);

  String get identificador => get<String>(keyId) ?? '';
  set identificador(String value) => set<String>(keyId, value);

  int get tipo => get<int>(keyTipo) ?? 0;
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

  ParseUser? get updatedBy => get<ParseUser>(keyUpdatedBy);
  set updatedBy(ParseUser? value) => set<ParseUser>(keyUpdatedBy, value!);

  ParseGeoPoint? get geoPoint => get<ParseGeoPoint>(keyGeoPoint);
  set geoPoint(ParseGeoPoint? value) => set<ParseGeoPoint>(keyGeoPoint, value!);

  String get tipoToString {
    switch (tipo) {
      case 1:
        return 'Tubo';
      case 2:
        return 'Caixa A4';
      case 3:
        return 'Pasta A3';
      case 4:
        return 'Gaveta';
      default:
        return 'Pacote indefinido';
    }
  }
}
