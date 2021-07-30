import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Pacote {
  final int tipo;
  final String locPredio; //bloco
  final String locNivel1; //e
  final String locNivel2; //d
  final String locNivel3; //a
  final String alterUser;
  final Timestamp alterData;
  //GeoPoint

  Pacote({
    required this.tipo,
    required this.locPredio,
    required this.locNivel1,
    required this.locNivel2,
    required this.locNivel3,
    required this.alterUser,
    required this.alterData,
  });

  Pacote.fromJson(Map<String, Object?> json)
      : this(
          tipo: (json['tipo'] ?? 99) as int,
          locPredio: (json['locPredio'] ?? '') as String,
          locNivel1: (json['locNivel1'] ?? '') as String,
          locNivel2: (json['locNivel2'] ?? '') as String,
          locNivel3: (json['locNivel3'] ?? '') as String,
          alterUser: (json['alterUser'] ?? 'Importação de dados') as String,
          alterData: (json['alterData'] ??
              Timestamp.fromDate(DateTime.parse('2021-06-01'))) as Timestamp,
        );

  Map<String, Object?> toJson() {
    return {
      'tipo': tipo,
      'locPredio': locPredio,
      'locNivel1': locNivel1,
      'locNivel2': locNivel2,
      'locNivel3': locNivel3,
      'alterUser': alterUser,
      'alterData': alterData,
    };
  }
}
