import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool tecladoVisivel(context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}

final DateFormat mDateFormat = DateFormat.yMMMMd('pt_BR').add_Hms();
