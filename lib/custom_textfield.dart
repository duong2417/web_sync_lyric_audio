import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/err_model.dart';
import 'package:web_sync_lyrix/print.dart';

class CustomTextEditCtrl extends TextEditingController {
  // List<ErrorModel> get listErrTime => listErr;
  List<ErrorModel> listErr = [];
  List<TextSpan> spans = [];
  List<StartOfErr> starts = [];

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    if (listErr.isNotEmpty) {
      p('listErr', listErr);
//       for (int i = 0; i < listErr.length - 1; ++i) {
//         for (int j = i; j < listErr.length; ++j) {
//           if (listErr[i].timeLine == listErr[j].timeLine) {
// //rm j
//             listErr.removeAt(j);
//           }
//         }
//       }
      p('listerr xoa trung', listErr);
      for (int i = 0; i < listErr.length; ++i) {
        int s = text.indexOf(listErr[i].timeLine);
        if (s > -1) {
          final e = StartOfErr(
              color:
                  listErr[i].type == TypeErr.error ? Colors.red : Colors.blue,
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
      p('starts khi sort', starts);
      // starts.sort((a, b) => a.index.compareTo(b.index));
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
