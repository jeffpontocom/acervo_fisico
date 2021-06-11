import 'package:cloud_firestore/cloud_firestore.dart';

/* Baseado em: https://medium.com/flutterando/seu-primeiro-crud-com-flutter-e-firestore-parte-1-be3e9392a301 */

abstract class BaseModel {
  BaseModel();

  BaseModel.fromMap(DocumentSnapshot document);
  toMap();
  String documentId();
}
