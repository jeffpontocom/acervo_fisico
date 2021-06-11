import 'package:flutter/foundation.dart';

@immutable
class Documento {
  final String assuntoBase;
  final String tipo;
  final String sequencial;
  final String idioma;
  final String folha;
  final String revisao;

  Documento({
    required this.assuntoBase,
    required this.tipo,
    required this.sequencial,
    required this.idioma,
    required this.folha,
    required this.revisao,
  });

  Documento.fromJson(Map<String, Object?> json)
      : this(
          assuntoBase: (json['tipo'] ?? '') as String,
          tipo: (json['locPredio'] ?? '') as String,
          sequencial: (json['locNivel1'] ?? '') as String,
          idioma: (json['locNivel2'] ?? '') as String,
          folha: (json['locNivel2'] ?? '') as String,
          revisao: (json['alterUser'] ?? '') as String,
        );

  Map<String, Object?> toJson() {
    return {
      'assuntoBase': assuntoBase,
      'tipo': tipo,
      'sequencial': sequencial,
      'idioma': idioma,
      'folha': folha,
      'revisao': revisao,
    };
  }
}
