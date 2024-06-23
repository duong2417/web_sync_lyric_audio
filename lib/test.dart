import 'package:flutter/material.dart';

class ErrorModel {
  final String timeLine;
  final TypeErr type;

  ErrorModel({required this.timeLine, required this.type});
}

enum TypeErr { warn, error }

class StartOfErr {
  final Color color;
  final int index;

  StartOfErr({required this.color, required this.index});
}

class CustomTextEditCtrl extends TextEditingController {
  List<ErrorModel> listErr = [];

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<TextSpan> spans = [];
    List<StartOfErr> starts = [];

    if (listErr.isNotEmpty) {
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
              starts.insert(0, e);
            } else if (s > starts.last.index) {
              starts.add(e);
            }
          }
        }
      }

      int start = 0;
      for (int i = 0; i < starts.length; ++i) {
        int end = starts[i].index + 11;
        if (end < text.length && starts[i].index > start) {
          spans.add(TextSpan(
            text: text.substring(start, starts[i].index),
            style: style,
          ));
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
          text: text.substring(start),
          style: style,
        ));
      }
    } else {
      spans.add(TextSpan(text: text, style: style));
    }
    return TextSpan(children: spans, style: style);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HighlightTextField(),
    );
  }
}

class HighlightTextField extends StatefulWidget {
  @override
  _HighlightTextFieldState createState() => _HighlightTextFieldState();
}

class _HighlightTextFieldState extends State<HighlightTextField> {
  final CustomTextEditCtrl _controller = CustomTextEditCtrl();

  @override
  void initState() {
    super.initState();
    _controller.listErr = [
      ErrorModel(timeLine: "test", type: TypeErr.warn),
      ErrorModel(timeLine: "error", type: TypeErr.error),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Highlight TextField'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter text',
          ),
        ),
      ),
    );
  }
}
