import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/err_model.dart';

class CustomTextEditCtrl extends TextEditingController {
  List<ErrorModel> listErr = [];
  List<StartOfErr> starts = [];
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<TextSpan> spans = []; //cp at here to edit text
    if (listErr.isNotEmpty) {
      // p('listErr', listErr);
      for (int i = 0; i < listErr.length; ++i) {
        int s = text.indexOf(listErr[i].timeLine);
        if (s > -1) {
          final e = StartOfErr(
              color: listErr[i].type == TypeErr.warn ? Colors.blue : Colors.red,
              index: s);
          if (starts.isEmpty) {
            starts.add(e);
          } else {
            if (s < starts.first.index) {
              //add vao dau ds
              starts.insert(0, e);
            } else if (s > starts.last.index) {
              starts.add(e);
            }
            //bang thi ko add
          }
        }
      }
      // p('starts khi sort', starts);
      // p('sort', starts);
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
