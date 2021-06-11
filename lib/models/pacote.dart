import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Pacote {
  final int tipo;
  final String locPredio;
  final String locNivel1;
  final String locNivel2;
  final String locNivel3;
  final String alterUser;
  final DateTime alterData;
  final List<DocumentReference> documentos;

  Pacote({
    required this.tipo,
    required this.locPredio,
    required this.locNivel1,
    required this.locNivel2,
    required this.locNivel3,
    required this.alterUser,
    required this.alterData,
    required this.documentos,
  });

  Pacote.fromJson(Map<String, Object?> json)
      : this(
          tipo: (json['tipo'] ?? 99) as int,
          locPredio: (json['locPredio'] ?? '') as String,
          locNivel1: (json['locNivel1'] ?? '') as String,
          locNivel2: (json['locNivel2'] ?? '') as String,
          locNivel3: (json['locNivel2'] ?? '') as String,
          alterUser: (json['alterUser'] ?? '') as String,
          alterData:
              (json['alterData'] ?? Timestamp.now().toDate()) as DateTime,
          documentos:
              ((json['documentos'] ?? []) as List).cast<DocumentReference>(),
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
      'documentos': documentos,
    };
  }
}
