import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/documento.dart';
import '../models/pacote.dart';
import '../util/utils.dart';

class GerarPdfPage {
  final Pacote pacote;
  final List<Documento> documentos;
  var _fonte;
  var _logo;

  GerarPdfPage({required this.pacote, required this.documentos});

  pw.Widget get _basicInfo {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        // Identificador
        pw.Text(
          'Pacote',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          '${pacote.identificador}',
          style: pw.TextStyle(fontSize: 20),
        ),
        pw.Text('Tipo: ${pacote.tipoToString}'),
        // Localização
        pw.Text('\n\n'),
        pw.Text(
          'Localização',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Bloco: ${pacote.localNivel1}'),
        pw.Text('Estante: ${pacote.localNivel2}'),
        pw.Text('Andar: ${pacote.localNivel3}'),
        // Observações
        pw.Text('\n\n'),
        pw.Text(
          'Observações',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('${pacote.observacao}'),
        pw.Text('\n\n'),
      ],
    );
  }

  List<pw.Widget> get listaDocs {
    List<pw.Widget> lista = [];
    for (var doc in documentos) {
      var item = pw.Text('${doc.toString()}');
      lista.add(item);
    }
    return lista;
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Acervo físico',
                  style: pw.TextStyle(
                    font: _fonte,
                    color: PdfColors.blueGrey,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                pw.Text(
                  'Arquivo Técnico',
                  style: pw.TextStyle(
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
            pw.Container(
              height: 70,
              width: 70,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data:
                    'https://encadt.itaipu.gov.br/acervo/pacote?id=${pacote.objectId}',
                drawText: true,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              //padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
              height: 20,
              child: _logo != null
                  ? pw.Image(_logo)
                  : pw.Text('ITAIPU Binacional'),
            ),
            pw.Text(
              '''Impresso em ${Util.mDateFormat.format(DateTime.now())}
          Página ${context.pageNumber}/${context.pagesCount}''',
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<Uint8List> criarPaginas(PdfPageFormat format) async {
    final pdf = pw.Document();
    final font = await rootBundle.load('assets/fonts/Baumans-Regular.ttf');
    _fonte = pw.Font.ttf(font);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: pw.EdgeInsets.symmetric(vertical: 25, horizontal: 40),
        header: _buildHeader,
        footer: _buildFooter,
        build: (pw.Context context) => [
          _basicInfo,
          // Lista de documentos
          pw.Text(
            'Documentos (${documentos.length})',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('\n\n'),
          pw.Wrap(spacing: 24, runSpacing: 4, children: listaDocs),
        ],
      ),
    );
    return await pdf.save();
  }
}
