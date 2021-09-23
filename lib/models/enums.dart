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
      assetName = 'assets/images/tubo.png';
      break;
    case 2:
      assetName = 'assets/images/caixaA4.png';
      break;
    case 3:
      assetName = 'assets/images/pastaA3.png';
      break;
    case 4:
      assetName = 'assets/images/gaveta.jpg';
      break;
    default:
      assetName = 'assets/images/indefinido.png';
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
      return 'Aberto';
    case 1:
      return 'Selado';
    case 2:
      return 'Editado';
    case 3:
      return 'Eliminado';
    default:
      return '[Ação indefinida]';
  }
}
