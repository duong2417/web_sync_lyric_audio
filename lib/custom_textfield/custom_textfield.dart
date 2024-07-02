import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/model/err_model.dart';

class CustomTextEditCtrl extends TextEditingController {
  List<ErrorModel> listErr = [];
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<StartOfErr> starts = [];
    List<TextSpan> spans = []; //cp at here to edit text (reset mỗi lần gọi)
    if (listErr.isNotEmpty) {
      //TODO: remove trung
      for (int i = 0; i < listErr.length; ++i) {
        List<int> listIndex = getAllIndices(text, listErr[i].timeLine);
        // int s = textClone.indexOf(listErr[i].timeLine);
        // if (s > -1) {
        // textClone = textClone.substring(
        //     s); //avoid timeLine trùng nhau thì nó vẫn lấy index của time đầu tiên//mà index = nhau cx ko sao vì = nhau thì ko add vào list (chỉ add cái đầu)
        // s += oldIndex;
        // oldIndex = s;
        // final e = StartOfErr(
        //     color: listErr[i].type == TypeErr.warn ? Colors.blue : Colors.red,
        //     index: s);
        final Color color =
            listErr[i].type == TypeErr.warn ? Colors.blue : Colors.red;
        List<StartOfErr> listModel =
            listIndex.map((e) => StartOfErr(color: color, index: e)).toList();
        if (starts.isEmpty) {
          starts.addAll(listModel);
        } else {
          if (listIndex.last < starts.first.index) {
            //add vao dau ds
            starts.insertAll(0, listModel);
          } else if (listIndex.first > starts.last.index) {
            starts.addAll(listModel);
          }
          //bang thi ko add
        }
        // }
      }
      int start = 0;
      for (int i = 0; i < starts.length; ++i) {
        int end = starts[i].index + 11;
        if (end < text.length && starts[i].index > start) {
          spans.add(TextSpan(
            text: text.substring(start,
                starts[i].index), //start->đầu err//Only valid value is 0: -1
            style: style,
          ));
          //errTimeLine
          spans.add(TextSpan(
            text: text.substring(starts[i].index, end),
            style: style?.copyWith(
                color: starts[i].color, fontWeight: FontWeight.bold),
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

List<int> getAllIndices(String str, String char) {
  List<int> indices = [];
  int index = str.indexOf(char);
  while (index != -1) {
    indices.add(index);
    index = str.indexOf(char, index + 1);
  }
  return indices;
}
