import 'package:flutter/material.dart';

bool tecladoVisivel(context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}
