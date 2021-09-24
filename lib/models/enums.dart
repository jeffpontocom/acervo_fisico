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

enum PacoteAction {
  CRIAR,
  ABRIR,
  SELAR,
  EDITAR, // não utilizar
  SALVAR,
  ADD_DOC,
  DEL_DOC,
  ELIMINAR,
}

String getPacoteActionString(int index) {
  switch (index) {
    case 0:
      return 'Criado';
    case 1:
      return 'Aberto';
    case 2:
      return 'Selado';
    case 3:
      return 'Em edição';
    case 4:
      return 'Editado';
    case 5:
      return 'Documentos adicionados';
    case 6:
      return 'Documentos excluidos';
    case 7:
      return 'Eliminado';
    default:
      return '[Ação indefinida]';
  }
}

String getTipoRelatorioString(int index) {
  switch (index) {
    case 0:
      return 'Criação do pacote';
    case 1:
      return 'Abertura do pacote';
    case 2:
      return 'Selamento do pacote';
    case 3:
      return 'Cadastro posto em edição';
    case 4:
      return 'Alteração de dados cadastrais';
    case 5:
      return 'Inclusão de documentos';
    case 6:
      return 'Exclusão de documentos';
    case 7:
      return 'Eliminação do pacote';
    default:
      return '[Ação indefinida]';
  }
}
