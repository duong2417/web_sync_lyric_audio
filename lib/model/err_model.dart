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

class SentenceHighlight {
  SentenceHighlight({required this.start, required this.end});
  int start, end;
  @override
  String toString() {
    return 'start:$start,end:$end';
  }
}

enum TypeErr { warn, error }
