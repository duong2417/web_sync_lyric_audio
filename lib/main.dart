import 'package:flutter/material.dart';
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
  BaseBloc bloc = BaseBloc();
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  height: 500,
                  width: MediaQuery.sizeOf(context).width / 3 - 30,
                  child: TextField(
                    minLines: 10,
                    maxLines: null,
                    controller: bloc.textOriginalCtrl,
                    decoration: const InputDecoration(label: Text('original')),
                  ),
                ),
                SizedBox(
                  height: 500,
                  width: MediaQuery.sizeOf(context).width / 3 - 30,
                  child: TextField(
                    minLines: 10,
                    maxLines: null,
                    decoration: const InputDecoration(label: Text('lrc')),
                    controller: bloc.textLrcCtrl,
                  ),
                ),
                Expanded(
                  child: Text(bloc.resStr),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: tapConvert,
        tooltip: 'Convert',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void tapConvert() {
    bloc.onTapConvert();
    setState(() {});
  }
}
