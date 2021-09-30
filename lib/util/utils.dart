import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Util {
  Util();

  /// Verifica se o teclado virtual esta presente na tela
  static bool tecladoVisivel(context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  /// Formato de data
  static final DateFormat mDateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();
}
