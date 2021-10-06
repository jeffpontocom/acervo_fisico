import 'package:flutter/material.dart';

Widget offLineView(context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image(
          image: AssetImage('assets/icons/band-aid.png'),
          height: 128,
          width: 128,
        ),
        Container(height: 24),
        Text(
          'Sem conexão com a internet.',
          style: Theme.of(context).textTheme.subtitle1,
        )
      ],
    ),
  );
}
