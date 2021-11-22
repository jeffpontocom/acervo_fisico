import 'package:flutter/material.dart';

// Margens padrao
const double margemHcelular = 0.0;
const double margemHweb = 400.0;

// INTERFACE PADRÃO para caixas de texto
const mTextField = InputDecoration(
  isDense: false,
  hintStyle: TextStyle(color: Colors.grey),
  //constraints: BoxConstraints(maxWidth: 600),
  labelStyle: TextStyle(
    color: Colors.grey,
    fontSize: 18,
    fontWeight: FontWeight.normal,
  ),
  border: UnderlineInputBorder(
      //borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black26,
      width: 1.0,
    ),
    //borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.lightBlue,
      width: 2.0,
    ),
    //borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  disabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.transparent,
      width: 1.0,
    ),
    //borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
);

// INTERFACE PADRÃO para caixas de texto
const mTextFieldOutlined = InputDecoration(
  isDense: false,
  hintStyle: TextStyle(color: Colors.grey),
  //constraints: BoxConstraints(maxWidth: 600),
  labelStyle: TextStyle(
    color: Colors.grey,
    fontSize: 18,
    fontWeight: FontWeight.normal,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black26,
      width: 1.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.lightBlue,
      width: 2.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black12,
      width: 1.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
);
