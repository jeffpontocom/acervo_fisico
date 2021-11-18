import 'package:flutter/material.dart';

enum TipoPacote {
  INDEFINIDO,
  TUBO,
  CAIXA_A4,
  PASTA_A3,
  CAIXA_A3,
  GAVETA,
}

String getTipoPacoteString(TipoPacote index) {
  switch (index) {
    case TipoPacote.TUBO:
      return 'Tubo';
    case TipoPacote.CAIXA_A4:
      return 'Caixa A4';
    case TipoPacote.PASTA_A3:
      return 'Pasta A3';
    case TipoPacote.CAIXA_A3:
      return 'Caixa A3';
    case TipoPacote.GAVETA:
      return 'Gaveta';
    default:
      return 'Pacote indefinido';
  }
}

AssetImage getTipoPacoteImagem(TipoPacote tipo) {
  String assetName;
  switch (tipo) {
    case TipoPacote.TUBO:
      assetName = 'assets/images/tubo.png';
      break;
    case TipoPacote.CAIXA_A4:
      assetName = 'assets/images/caixaA4.png';
      break;
    case TipoPacote.PASTA_A3:
      assetName = 'assets/images/pastaA3.png';
      break;
    case TipoPacote.CAIXA_A3:
      assetName = 'assets/images/caixaA3.png';
      break;
    case TipoPacote.GAVETA:
      assetName = 'assets/images/gaveta.png';
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
  MIGRADO,
}

String getPacoteActionString(int index) {
  switch (index) {
    case 0:
      return 'Criação';
    case 1:
      return 'Abertura';
    case 2:
      return 'Selamento';
    case 3:
      return 'Em edição';
    case 4:
      return 'Edição realizada';
    case 5:
      return 'Documentos adicionados';
    case 6:
      return 'Documentos excluidos';
    case 7:
      return 'Eliminação';
    case 8:
      return 'Transferência';
    case 9:
      return 'Migração';
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
    case 9:
      return 'Migração de dados';
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
    case 9:
      return Icon(Icons.import_export_rounded); //'Migração de dados';
    default:
      return Icon(Icons.device_unknown_rounded); //'[Ação indefinida]';
  }
}
