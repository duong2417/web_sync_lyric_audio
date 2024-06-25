import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_sync_lyrix/bloc3.dart';

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
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height - 200,
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
                    height: MediaQuery.sizeOf(context).height - 200,
                    width: MediaQuery.sizeOf(context).width / 3 - 30,
                    child: TextField(
                      minLines: 10,
                      maxLines: null,
                      decoration:
                          const InputDecoration(label: Text('Nhập file lrc')),
                      controller: bloc.textLrcCtrl,
                    ),
                  ),
                  Expanded(
                    //cp
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 500,
                            child: TextField(
                              minLines: 10,
                              maxLines: null,
                              decoration: const InputDecoration(
                                  label: Text('Result (Lrc)')),
                              controller: bloc.resLrcCtrl,
                            ),
                          ),
                          SizedBox(
                            height: 300, //cp
                            // width: 300,
                            child: TextFormField(
                              minLines: 15,
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
              Clipboard.setData(ClipboardData(text: bloc.passageResCtrl.text));
            },
            tooltip: 'Copy passage',
            child: const Icon(Icons.copy),
          ),
          FloatingActionButton(
            onPressed: () {
              bloc.reset();
              bloc.passageResCtrl.clear();
              bloc.textLrcCtrl.clear();
              bloc.textOriginalCtrl.clear();
              setState(() {}); //rm err
            },
            tooltip: 'Reset',
            child: const Icon(Icons.restore_from_trash),
          ),
        ],
      ),
    );
  }

  void tapConvert() {
    bloc.onTapConvert();
    setState(() {});
  }
}
