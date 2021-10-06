import 'package:acervo_fisico/views/offline_view.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Carregando interface...",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}

class OffLineScreen extends StatelessWidget {
  const OffLineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(child: offLineView(context));
  }
}
