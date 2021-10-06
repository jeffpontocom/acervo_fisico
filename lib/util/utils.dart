import 'package:universal_internet_checker/universal_internet_checker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Util {
  Util();

  /// Verifica se o teclado virtual está presente na tela
  static bool tecladoVisivel(context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  /// Verifica se existe conexão a internet
  static Future<bool> hasNetwork() async {
    final ConnectionStatus status =
        await UniversalInternetChecker.checkInternet();
    return status == ConnectionStatus.online;
  }

  /// Formato de data padrão "1 de janeiro de 2020 23:59:59."
  static final DateFormat mDateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();
}
