// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:web_sync_lyrix/bloc3.dart';
// import 'package:web_sync_lyrix/print.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final bloc = Lyric();
//   List<String> lines = [];
//   int _hoveredLineIndex = -1;

//   @override
//   void initState() {
//     super.initState();
//     bloc.resLrcCtrl.addListener(() {
//       // print('nhay do adlistener'); //when onTap (hover thì ko nhảy dô)
//       setState(() {
//         lines = bloc.resLrcCtrl.text.split('\n');
//       });
//     });
//   }

//   TextSelection _getSelectionForHoveredLine() {
//     final text = bloc.resLrcCtrl.text;
//     final lines = text.split('\n');
//     int start = 0;
//     for (int i = 0; i < _hoveredLineIndex; i++) {
//       start += lines[i].length + 1; // +1 for the newline character
//     }
//     final end = start + lines[_hoveredLineIndex].length;
//     return TextSelection(baseOffset: start, extentOffset: end);
//   }

//   void _onHover(PointerHoverEvent event) {
//     final RenderBox renderBox = context.findRenderObject() as RenderBox;
//     final Offset localPosition = renderBox.globalToLocal(event.position);
//     final textPainter = TextPainter(
//       text: TextSpan(text: bloc.resLrcCtrl.text),
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout(maxWidth: renderBox.size.width);
//     final lineHeight = textPainter
//         .preferredLineHeight; // p('localPosition trong _onHover', localPosition);
//     // final double lineHeight = renderBox.size.height / lines.length;
//     p('lines.length',
//         lines.length); //tính lun cả dấu xuống hàng khi thu nhỏ tab
//     p('lineHeight trong _onHover', lineHeight);
//     setState(() {
//       _hoveredLineIndex = (localPosition.dy / lineHeight).floor();
//       p('_hoveredLineIndex trong _onHover', _hoveredLineIndex);
//       if (_hoveredLineIndex >= lines.length) {
//         p('_hoveredLineIndex trong _onHover >= lines.length',
//             _hoveredLineIndex);
//         _hoveredLineIndex = -1;
//       }
//     });
//      if (_hoveredLineIndex >= 0 && _hoveredLineIndex < bloc.resLrcCtrl.text.split('\n').length) {
//       final selection = _getSelectionForHoveredLine();
//       bloc.resLrcCtrl.value = bloc.resLrcCtrl.value.copyWith(selection: selection);
//     } else {
//       bloc.resLrcCtrl.value = bloc.resLrcCtrl.value.copyWith(
//         selection: const TextSelection.collapsed(offset: -1),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SelectionArea(
//                 child: Text(
//                   bloc.err,
//                   style: const TextStyle(
//                       color: Colors.red, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 // mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: <Widget>[
//                   SizedBox(
//                     height: MediaQuery.sizeOf(context).height - 300,
//                     width: MediaQuery.sizeOf(context).width / 3 - 30,
//                     // width: 200,
//                     child: TextField(
//                       minLines: 10,
//                       maxLines: null,
//                       controller: bloc.textOriginalCtrl,
//                       decoration: const InputDecoration(
//                           label: Text('Nhập văn bản gốc')),
//                     ),
//                   ),
//                   SizedBox(
//                     height: MediaQuery.sizeOf(context).height - 200,
//                     width: MediaQuery.sizeOf(context).width / 3 - 30,
//                     // width: 300,
//                     // height: 500,
//                     child: TextField(
//                       minLines: 10,
//                       maxLines: null,
//                       decoration:
//                           const InputDecoration(label: Text('Nhập file lrc')),
//                       controller: bloc.textLrcCtrl,
//                     ),
//                   ),
//                   Expanded(
//                     //cp
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             height: 500,
//                             child: MouseRegion(
//                               onHover: (event) {
//                                 p('hover localPosition', event.localPosition);
//                                 p('hover localPosition', event.localPosition);
//                                 // This can be improved to detect specific line based on cursor position
//                                 // For simplicity, we'll just highlight the first line
//                                 _onHover(event);
//                               },
//                               onExit: (_) {
//                                 print('exit');
//                                 setState(() {
//                                   _hoveredLineIndex = -1;
//                                   bloc.resLrcCtrl.value =
//                                       bloc.resLrcCtrl.value.copyWith(
//                                     selection: const TextSelection.collapsed(
//                                         offset: -1),
//                                   );
//                                 });
//                               },
//                               child: TextField(
//                                 minLines: 10,
//                                 maxLines: null,
//                                 decoration: const InputDecoration(
//                                     label: Text('Result (Lrc)')),
//                                 controller: bloc.resLrcCtrl,
//                                 selectionControls:
//                                     MaterialTextSelectionControls(),
//                                 // selection: _hoveredLineIndex != -1
//                                 //     ? _getSelectionForHoveredLine()
//                                 //     : const TextSelection.collapsed(offset: -1),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 350, //300 //cp
//                             // width: 300,
//                             child: TextFormField(
//                               minLines: 15,
//                               maxLines: null,
//                               decoration: const InputDecoration(
//                                   label: Text('Result (Passage)')),
//                               controller: bloc.resPassageCtrl,
//                             ),
//                           ),
//                           // SizedBox(
//                           //   height: 300, //cp
//                           //   // width: 300,
//                           //   child: TextFormField(
//                           //     minLines: 15,
//                           //     maxLines: null,
//                           //     decoration: const InputDecoration(
//                           //         label: Text('Result (Passage) 2')),
//                           //     controller: bloc.resPassageCtrl2,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () => tapConvert(),
//             tooltip: 'Convert',
//             child: const Icon(Icons.add),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: bloc.resLrcCtrl.text));
//             },
//             tooltip: 'Copy lyric',
//             child: const Icon(Icons.copy),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: bloc.resPassageCtrl.text));
//             },
//             tooltip: 'Copy passage',
//             child: const Icon(Icons.copy),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               bloc.reset();
//               bloc.resPassageCtrl.clear();
//               bloc.textLrcCtrl.clear();
//               bloc.textOriginalCtrl.clear();
//               setState(() {}); //rm err
//             },
//             tooltip: 'Reset',
//             child: const Icon(Icons.restore_from_trash),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               bloc.reHandlePassage();
//               setState(() {}); //rm err
//             },
//             tooltip: 'Reconvert passage',
//             child: const Icon(Icons.currency_exchange),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               bloc.removeBreaklineOfPassage();
//             },
//             tooltip: "Remove passage's breakline",
//             child: const Icon(Icons.arrow_circle_down_sharp),
//           ),
//         ],
//       ),
//     );
//   }

//   void tapConvert() {
//     bloc.onTapConvert();
//     setState(() {});
//   }
// }
