import 'package:flutter/material.dart';

class ErrorModel {
  ErrorModel({this.type = TypeErr.warn, required this.timeLine});
  TypeErr type;
  String timeLine;
  @override
  String toString() {
    return 'timeLine:$timeLine,type:$type';
  }
}

class StartOfErr {
  StartOfErr({required this.color, required this.index});
  Color color;
  int index;
  @override
  String toString() {
    return 'index:$index';
  }
}

enum TypeErr { warn, error }
