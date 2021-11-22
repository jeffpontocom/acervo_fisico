import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Util {
  Util();

  /// Verifica se o teclado virtual está presente na tela
  static bool tecladoVisivel(context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  /// Formato de data e hora padrão completo "1 de janeiro de 2020 23:59:59."
  static final DateFormat mDateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();

  /// Formato de data e hora padrão curto "01/01/2020 23:59:59"
  static final DateFormat mShortDateFormat = DateFormat.yMd('pt_BR').add_Hms();

  /// Formato de numeros com separador de milhar
  static final NumberFormat mNumFormat = NumberFormat.decimalPattern('pt_BR');
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
