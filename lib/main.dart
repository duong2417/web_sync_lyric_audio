import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:web_sync_lyrix/my_bloc.dart';
import 'package:web_sync_lyrix/passage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bloc = Lyric();
  final Passage passage = Passage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              bloc.err,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  height: 500,
                  width: MediaQuery.sizeOf(context).width / 3 - 30,
                  child: TextField(
                    minLines: 10,
                    maxLines: null,
                    controller: bloc.textOriginalCtrl,
                    decoration:
                        const InputDecoration(label: Text('Nhập văn bản gốc')),
                  ),
                ),
                SizedBox(
                  height: 500,
                  width: MediaQuery.sizeOf(context).width / 3 - 30,
                  child: TextField(
                    minLines: 10,
                    maxLines: null,
                    decoration:
                        const InputDecoration(label: Text('Nhập file lrc')),
                    controller: bloc.textLrcCtrl,
                  ),
                ),
                SizedBox(
                  height: 400, //cp
                  width: 300, //cp
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        minLines: 5,
                        maxLines: 10,
                        decoration:
                            const InputDecoration(label: Text('Result (Lrc)')),
                        controller: bloc.textLrcCtrl,
                      ),
                      TextField(
                        minLines: 5,
                        maxLines: 10,
                        decoration: const InputDecoration(
                            label: Text('Result (Passage)')),
                        controller: passage.passageTextCtrl,
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   child: SingleChildScrollView(child: Text(bloc.resStr)),
                // )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed:()=> tapConvert(),
            tooltip: 'Convert',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: bloc.resLrcCtrl.text));
            },
            tooltip: 'Copy lyric',
            child: const Icon(Icons.copy),
          ),
          FloatingActionButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: passage.passageTextCtrl.text));
            },
            tooltip: 'Copy passage',
            child: const Icon(Icons.copy),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void tapConvert() {
    bloc.onTapConvert();
    // passage.findMatch();
    setState(() {});
  }
}
