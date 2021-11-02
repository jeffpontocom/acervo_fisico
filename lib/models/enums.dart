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
  TRANSFERIR,
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
    case 8:
      return 'Transferência';
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
    case 8:
      return 'Transferência de documentos';
    default:
      return '[Ação indefinida]';
  }
}

Icon getTipoRelatorioIcon(int index) {
  switch (index) {
    case 0:
      return Icon(Icons.new_label_rounded); //'Criação do pacote';
    case 1:
      return Icon(Icons.unarchive_rounded); //'Abertura do pacote';
    case 2:
      return Icon(Icons.verified_rounded); //'Selamento do pacote';
    case 3:
      return Icon(
          Icons.edit_location_alt_rounded); //'Cadastro posto em edição';
    case 4:
      return Icon(
          Icons.edit_location_alt_rounded); //'Alteração de dados cadastrais';
    case 5:
      return Icon(Icons.post_add_rounded); //'Inclusão de documentos';
    case 6:
      return Icon(Icons.delete_sweep_rounded); //'Exclusão de documentos';
    case 7:
      return Icon(Icons.delete_forever_rounded); //'Eliminação do pacote';
    case 8:
      return Icon(Icons.transform_rounded); //'Transferência de documentos';
    default:
      return Icon(Icons.device_unknown_rounded); //'[Ação indefinida]';
  }
}
