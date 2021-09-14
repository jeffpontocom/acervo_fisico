enum TipoPacote {
  INDEFINIDO,
  TUBO,
  CAIXA_A4,
  PASTA_A3,
  GAVETA,
}

String getTipoPacote(int index) {
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
