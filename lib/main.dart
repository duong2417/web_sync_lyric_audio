import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_sync_lyrix/my_bloc.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SelectionArea(
                child: Text(
                  bloc.err,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height - 100,
                    width: MediaQuery.sizeOf(context).width / 3 - 30,
                    child: TextField(
                      minLines: 10,
                      maxLines: null,
                      controller: bloc.textOriginalCtrl,
                      decoration: const InputDecoration(
                          label: Text('Nhập văn bản gốc')),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height - 50,
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            minLines: 7,
                            maxLines: null,
                            decoration: const InputDecoration(
                                label: Text('Result (Lrc)')),
                            controller: bloc.resLrcCtrl,
                          ),
                          SizedBox(
                            height: 200, //cp
                            // width: 300,
                            child: TextField(
                              minLines: 7,
                              maxLines: null,
                              decoration: const InputDecoration(
                                  label: Text('Result (Passage)')),
                              controller: bloc.passageResCtrl,
                            ),
                          ),
                        ],
                      ),
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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => tapConvert(),
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
                  ClipboardData(text: bloc.passageResCtrl.text)); //TODO:
            },
            tooltip: 'Copy passage',
            child: const Icon(Icons.copy),
          ),
          FloatingActionButton(
            onPressed: () {
              bloc.reset();
              bloc.resLrcCtrl.clear();
              bloc.textLrcCtrl.clear();
              bloc.textOriginalCtrl.clear();
              bloc.err = '';
            },
            tooltip: 'Reset',
            child: const Icon(Icons.restore_from_trash),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void tapConvert() {
    // bloc.count();
    bloc.onTapConvert();
    // passage.findMatch();
    setState(() {});
  }
}
