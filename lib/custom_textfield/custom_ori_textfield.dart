import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/model/err_model.dart';

class CustomOriTextField extends TextEditingController {
  List<SentenceHighlight> listIndex = [];
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<TextSpan> spans = []; //cp at here to edit text (reset mỗi lần gọi)
    if (listIndex.isNotEmpty) {
      int start = 0;
      int startOfHighlight, endOfHighlight;
      for (int i = 0; i < listIndex.length; ++i) {
        startOfHighlight = listIndex[i].start;
        endOfHighlight = listIndex[i].end;
        if (endOfHighlight < text.length && endOfHighlight > start) {
          spans.add(TextSpan(
            text: text.substring(start,
                startOfHighlight), //start->đầu err//Only valid value is 0: -1
            style: style,
          ));
          //errTimeLine
          spans.add(TextSpan(
            text: text.substring(startOfHighlight, endOfHighlight),
            style: style?.copyWith(
                color: Colors.blue, fontWeight: FontWeight.bold),
          ));
          start = endOfHighlight;
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
