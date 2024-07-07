import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/model/err_model.dart';
import 'package:web_sync_lyrix/print.dart';

class CustomTextEditCtrl extends TextEditingController {
  List<ErrorModel> listErr = [];
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<StartOfErr> modelTimeIndexes = [];
    List<TextSpan> spans = []; //cp at here to edit text (reset mỗi lần gọi)
    if (listErr.isNotEmpty) {
      for (int i = 0; i < listErr.length; ++i) {
        List<int> timeIndexes = getAllIndices(text, listErr[i].timeLine);
        if (timeIndexes.isNotEmpty){
        final Color color =
            listErr[i].type == TypeErr.warn ? Colors.blue : Colors.red;
        List<StartOfErr> listModel =
            timeIndexes.map((e) => StartOfErr(color: color, index: e)).toList();
        if (modelTimeIndexes.isEmpty) {
          modelTimeIndexes.addAll(listModel);
        } else {
          //modelTimeIndexes hasData
          p('timeIndexes.last',timeIndexes.last);
          if (timeIndexes.last < modelTimeIndexes.first.index) {//Bad state: No element
            //add vao dau ds
            modelTimeIndexes.insertAll(0, listModel);
          } else if (timeIndexes.first > modelTimeIndexes.last.index) {
            modelTimeIndexes.addAll(listModel);
          }
          //bang thi ko add
        }
        }
      }
      int start = 0;
      for (int i = 0; i < modelTimeIndexes.length; ++i) {
        int end = modelTimeIndexes[i].index + 11;
        if (end < text.length && modelTimeIndexes[i].index > start) {
          spans.add(TextSpan(
            text: text.substring(start, modelTimeIndexes[i].index), //start->đầu err
            style: style,
          ));
          //errTimeLine
          spans.add(TextSpan(
            text: text.substring(modelTimeIndexes[i].index, end),
            style: style?.copyWith(
                color: modelTimeIndexes[i].color, fontWeight: FontWeight.bold),
          ));
          start = end;
        }
      }
      if (start < text.length) {
        spans.add(TextSpan(
          text: text.substring(start), //err->hêt
          style: style,
        ));
      }
      return TextSpan(children: spans, style: style);
    }
    return super.buildTextSpan(
        style: style, withComposing: withComposing, context: context);
  }
}
//lấy all index của timeLine
List<int> getAllIndices(String str, String timeLine) {
  List<int> indices = [];
  int index = str.indexOf(timeLine);
  while (index != -1 && index < str.length - 1) {
    // if (index < str.length - 1) {
    indices.add(index);
    index = str.indexOf(timeLine, index + 1); //0..10685: 10686
    // }
  }
  return indices;
}
