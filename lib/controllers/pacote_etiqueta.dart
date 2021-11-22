import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pacote.dart';

class GerarEtiqueta {
  final Pacote pacote;
  var _fonte;

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
        pw.SizedBox(
          width: 188,
          child: pw.Text(
            '${pacote.identificador}',
            maxLines: 1,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColor.fromHex('1565C0'), // Azul escuro
              font: _fonte,
              fontSize: 20,
              //fontWeight: pw.FontWeight.bold,
            ),
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
    final font = await rootBundle.load('assets/fonts/MavenPro-Bold.ttf');
    _fonte = pw.Font.ttf(font);
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
