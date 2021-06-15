import 'package:flutter/foundation.dart';

@immutable
class Documento {
  final String assuntoBase;
  final String tipo;
  final String sequencial;
  final String idioma;
  final String folha;
  final String revisao;
  final String pacote;

  Documento({
    required this.assuntoBase,
    required this.tipo,
    required this.sequencial,
    required this.idioma,
    required this.folha,
    required this.revisao,
    required this.pacote,
  });

  Documento.fromJson(Map<String, Object?> json)
      : this(
          assuntoBase: (json['assuntoBase'] ?? '') as String,
          tipo: (json['tipo'] ?? '') as String,
          sequencial: (json['sequencial'] ?? '') as String,
          idioma: (json['idioma'] ?? '') as String,
          folha: (json['folha'] ?? '') as String,
          revisao: (json['revisao'] ?? '') as String,
          pacote: (json['pacote'] ?? '') as String,
        );

  Map<String, Object?> toJson() {
    return {
      'assuntoBase': assuntoBase,
      'tipo': tipo,
      'sequencial': sequencial,
      'idioma': idioma,
      'folha': folha,
      'revisao': revisao,
      'pacote': pacote,
    };
  }
}
