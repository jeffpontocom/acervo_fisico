import 'package:flutter/material.dart';

enum TipoPacote {
  INDEFINIDO,
  TUBO,
  CAIXA_A4,
  PASTA_A3,
  GAVETA,
}

String getTipoPacoteString(int index) {
  switch (index) {
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

AssetImage getTipoPacoteImagem(int index) {
  String assetName;
  switch (index) {
    case 1:
      assetName = 'assets/images/tubo.jpg';
      break;
    case 2:
      assetName = 'assets/images/caixaA4.jpg';
      break;
    case 3:
      assetName = 'assets/images/pastaA3.jpg';
      break;
    case 4:
      assetName = 'assets/images/gaveta.jpg';
      break;
    default:
      assetName = 'assets/images/indefinido.jpg';
      break;
  }
  return AssetImage(assetName);
}

enum UpdatedAction {
  ABRIR,
  SELAR,
  SALVAR,
  ELIMINAR,
}

String getUpdatedAction(int index) {
  switch (index) {
    case 0:
      return 'Pacote aberto';
    case 1:
      return 'Pacote selado';
    case 2:
      return 'Pacote editado';
    case 3:
      return 'Pacote eliminado';
    default:
      return '[Ação indefinida]';
  }
}
