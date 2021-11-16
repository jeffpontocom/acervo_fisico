import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pacote.dart';

class GerarEtiqueta {
  final Pacote pacote;

  GerarEtiqueta({required this.pacote});

  pw.Widget get _etiqueta {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        //Barcode
        pw.Container(
          height: 64,
          width: 64,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data:
                'https://encadt.itaipu.gov.br/acervo/pacote?id=${pacote.objectId}',
            drawText: false,
          ),
        ),
        // Espaço entre linhas
        pw.SizedBox(height: 16),
        // Identificador
        pw.Text(
          '${pacote.identificador}',
          style: pw.TextStyle(
            color: PdfColor.fromHex('1565C0'), // Azul escuro
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        // Espaço inferior
        pw.SizedBox(height: 45),
      ],
    );
  }

  Future<Uint8List> criarEtiqueta() async {
    print('1. Criando etiqueta');
    final pdf = pw.Document();
    print('2. Carrengando fundo');
    final background = await rootBundle.loadString('assets/etiqueta.svg');
    print('3. Criando pagina');
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a6,
          margin: pw.EdgeInsets.all(0),
          buildBackground: (context) {
            return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(child: pw.SvgImage(svg: background)));
          },
        ),
        build: (pw.Context context) => pw.Center(
          child: _etiqueta,
        ),
      ),
    );
    print('4. Salvando PDF');
    return await pdf.save();
  }
}
