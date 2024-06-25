// import 'package:flutter/material.dart';
// import 'package:web_sync_lyrix/custom_textfield.dart';
// import 'package:web_sync_lyrix/err_model.dart';
// import 'package:web_sync_lyrix/extension.dart';
// import 'package:web_sync_lyrix/model.dart';
// import 'package:web_sync_lyrix/passage_model.dart';
// import 'package:web_sync_lyrix/print.dart';

// class Lyric {
//   List<LyricModel> listModelOfLrcResult = []; //result
//   List<LyricModel> listModelOfLrc = []; //result
//   final textLrcCtrl = TextEditingController();
//   final textOriginalCtrl = TextEditingController();
//   final resLrcCtrl = CustomTextEditCtrl();
//   final passageResCtrl = TextEditingController();
//   List<String> listLrcText = [], listTime = []; //each row//listOriginalText,
//   List<List<String>> listLrcWord = [], listSentenceNoTime = [];
//   List<OnePassage> passage = [];
//   List<PassageModel> passageModel = []; //result
//   int errExit = 0;
//   handlePassage() {
//     if (passage.length < 2) {
//       passageModel.add(PassageModel(
//           time: '[00:00.000]', passage: passage[0].passage, index: 1));
//       onPassageErr(s: 'Only 1 passage!');
//     } else {
//       List<LyricModel> clone = List.from(listModelOfLrcResult);
//       for (int i = 0; i < passage.length; ++i) {
//         for (int j = 0; j < clone.length; ++j) {
//           if (passage[i].sentences.first.contains(clone[j].sentence.trim()) ||
//               clone[j].sentence.contains(passage[i].sentences.first.trim())) {
//             //No element
//             passageModel.add(PassageModel(
//                 time: clone[j].time,
//                 passage: passage[i].passage,
//                 index: i + 1));
//             //remove done part: từ 0->vị trí listTime đó
//             clone.removeRange(0, j);
//             break;
//           } else {}
//         }
//       }
//       hanleResPassage(passageModel);
//     }
//   }

//   hanleResPassage(List<PassageModel> passageModel) {
//     String res = '';
//     for (PassageModel model in passageModel) {
//       res += model.toString();
//       res += '\n';
//     }
//     passageResCtrl.text = res;
//   }

//   List<String> listSentenceOfLrc = [];
//   splitLrcText() {
//     List<String> listPassage = original.split('\n')
//       ..removeWhere((element) => element.isEmpty)
//       ..forEach((element) {
//         element = element.trim(); //remove \n thừa//f
//       });
//     for (int i = 0; i < listPassage.length; ++i) {
//       passage.add(OnePassage(
//           sentences: listPassage[i]
//               .split(RegExp(r'[.?!;]')) //tach passage thanh tung cau
//             ..removeWhere((element) => element.isEmpty),
//           passage: listPassage[i]));
//     }
//     listLrcText = textLrcCtrl.text.split(
//         '\n') //lrc phải xóa hêt dấu, chỉ còn chữ thì câu trong passage dễ contain hơn (nhiều khi máy tự thêm dấu sai)
//       ..removeWhere((element) => element.isEmpty)
//       ..forEach((element) {
//         element = element.trim(); //remove \n thừa//f
//       });
//     for (int i = 0; i < listLrcText.length; ++i) {
//       String sentence = listLrcText[i];
//       if (sentence.contains(' ')) {
// //split ra từng từ
//         int end = sentence.indexOf(']') + 1;
//         String time = sentence.substring(0, end); //[0]=time
//         String text = sentence.substring(end);
//         listModelOfLrc.add(LyricModel(time: time, sentence: text));
//       } else {
//         // listTime.add(sentence);
//         // listSentenceNoTime.add([]);
//         // if (i == listLrcText.length - 1) {
//         //   //câu cuối
//         //   onErr(i, "Câu cuối của file lrc empty");
//         // } else {
//         //   onErr(i, 'lrc chứa câu empty');
//         // }
//       }
//     }
//   }

//   void onWarning(int i) {
//     String timeLine = listTime[i < listTime.length ? i : listTime.length - 1];
//     resLrcCtrl.listErr.add(ErrorModel(timeLine: timeLine));
//   }

//   String resStr = '';

//   onTapConvert() {
//     reset();
//     pretreatmentOri();
//     splitLrcText();
//     if (errExit == 0) {
//       //success
//       replaceLrcByOriginal();
//       handleLrcResult();
//       // handlePassage();
//     }
//   }

//   handleLrcResult() {
//     for (LyricModel e in listModelOfLrcResult) {
//       if (e.sentence != '') {
//         resStr += e.toString();
//         resStr += '\n';
//       }
//     }
//     resLrcCtrl.text = resStr;
//   }

//   String err = '';
//   String original = '';
//   pretreatmentOri() {
//     original = textOriginalCtrl.text
//         .replaceAll(RegExp(r'[‘’]'), "'"); //để I’m contain I'm
//     // .replaceAll(RegExp(r'[“”]'), '"');
//   }

//   replaceLrcByOriginal() {
//     String sub = '';
//     listModelOfLrcResult = [];
//     int end;
//     String oriOfLrc = original.replaceAll('\n',
//         ' '); //nếu '' thì từ đầu cuối đoạn trc và đầu đoạn sau hợp lại thành 1 từ
//     String oriNoPunc = oriOfLrc.toLowerCase().replaceAll(puncReg, '');
//     for (int i = 0; i < listModelOfLrc.length; ++i) {
//       LyricModel model = listModelOfLrc[i];
//       //.replaceAll(puncReg, '')
//       String cau = model.sentence.toLowerCase().trim();
//       end = oriNoPunc.toLowerCase().indexOf(cau);
//       if (end > -1) {
//         p('contain, end:$end, ori:$oriNoPunc,model:', model);
//         //note: tìm thấy rồi thì handle câu empty trc trc khi removeDone
//         int pre = i - 1;
//         int flag = 0;
//         while (pre >= 0 &&
//             pre < listModelOfLrcResult.length &&
//             listModelOfLrcResult[pre].sentence == '') {
//           if (flag == 0) {
//             //lan dau
//             sub = oriNoPunc.substring(0, end); //0->đầu câu sau
//             p('set sub empty lan dau', sub);
//             listModelOfLrcResult[pre].sentence = sub;
//             p('listModelOfLrcResult', listModelOfLrcResult);
//             oriNoPunc = oriNoPunc.substring(end);
//             flag = 1;
//           } else {
//             //từ lần 2 trở đi thì set time cho câu sau rồi xóa empty đó
//             p('pre', pre);
//             if (pre >= 0 && pre < listModelOfLrcResult.length - 1) {
//               listModelOfLrcResult[pre + 1].time =
//                   listModelOfLrcResult[pre].time;
//               p('listModelOfLrcResult sau set time', listModelOfLrcResult);
//               //[[00:00.000] chapter ii , [00:00.000] , [00:03.000] the..//f
//               listModelOfLrcResult.removeAt(pre);
//               p('listModelOfLrcResult sau remove at pre-1',
//                   listModelOfLrcResult);
// //[[00:00.000] , [00:03.000] the pool of tears curiouser and curiouser cried alice ]
//               //TODO: --i
//             } else {
//               //câu cuoi (ko có câu sau nó nên do nothing)
//             }
//           }
//           --pre;
//         }
//         end = oriNoPunc.toLowerCase().indexOf(cau) + model.sentence.length;
//         end = handleEndIndex(end, oriNoPunc);
//         String text = oriNoPunc.substring(0, end);
//         p('text 0->cuoi cau sau', text);
//         oriNoPunc = oriNoPunc.removeDoneString(end); //TODO:+1
//         p('oriOfLrc sau rm1', oriNoPunc);
//         // String tuConThieu = countText(oriOfLrc);
//         // p('tu con thieu', tuConThieu);
//         sub = text; //+ tuConThieu; //0..54:55
//         p('sub + từ còn thiếu', sub);
//         listModelOfLrcResult.add(LyricModel(time: model.time, sentence: sub));
//         // end = handleEndIndex(end, oriNoPunc);
//         // p('end sau handle1',end);
//         // oriNoPunc = oriNoPunc.removeDoneString(end);
//         // p('oriNoPunc',oriNoPunc);
//         // if (tuConThieu.isNotEmpty) {
//         //   end = handleEndIndex(end + tuConThieu.length, oriOfLrc);
//         //   p('end sau handle2', end);
//         //   oriOfLrc = oriOfLrc.removeDoneString(end); //TODO:+1
//         //   p('oriOfLrc sau rm2', oriOfLrc);
//         // }
//       } else {
//         // p('ko contain', model);
//         LyricModel? model2;
//         if (i >= 1) {
//           if (i == listModelOfLrc.length - 1) {
//             //cau cuoi ko co cau sau
//             model2 = LyricModel(
//                 time: listModelOfLrc[i - 1].time, sentence: oriNoPunc);
//           } else {
//             model2 = LyricModel(time: listModelOfLrc[i - 1].time, sentence: '');
//           }
//         }
//         //not match vẫn add để lấy time rồi hồi match thì handle sentence của những câu trc
//         listModelOfLrcResult.add(model2);
//       }
//     }
//   }

//   bool setNextTime(int a) {
//     if (a < listTime.length) {
//       listModelOfLrc[a].time = listModelOfLrc[a - 1].time; //t
//     } else {
//       //câu cuối:listTime giữ nguyên (vẫn là time của câu sau (thay vì câu đầu))
//     }
//     onWarning(a); //not found pairWordFirst
//     return false;
//   }

//   int countPunc(String ori) {
//     //ori lấy từ word đó trở về sau (ko lấy word)
//     //đếm số dấu ngay sau word
//     int dem = 0;
//     // ori = ori
//     //     .trim(); //and "how" => trim là lấy dấu câu khác//and ! => ko trim là ko lấy đc dấu !//đa số punc để sát word
//     for (int i = 0; i < ori.length; ++i) {
//       if (!ori[i].contains(closePunc)) {
//         break;
//       }
//       ++dem;
//     }
//     return dem;
//   }

//   onErr(int i, String text) {
//     err += text;
//     if (i > -1) {
//       int a = i < listTime.length ? i : listTime.length - 1;
//       resLrcCtrl.listErr
//           .add(ErrorModel(type: TypeErr.error, timeLine: listTime[a]));
//       //i=-1 là ko hiện index,chỉ hiện text
//       err += ' (at ${listTime[a]})';
//     }
//     err += '\n';
//   }

//   void reset() {
//     listModelOfLrc = [];
//     listModelOfLrcResult = [];
//     listSentenceNoTime = [];
//     listLrcText = [];
//     listTime = [];
//     listLrcWord = [];
//     listModelOfLrcResult = [];
//     resStr = '';
//     err = '';
//     errExit = 0;
//     passage = [];
//     passageModel = [];
//     resLrcCtrl.clear();
//     resLrcCtrl.text = '';
//     resLrcCtrl.listErr = [];
//   }

//   void onPassageErr({int i = -1, int indexOfPassage = -1, String? s}) {
//     if (s != null) {
//       err += s;
//     }
//     err += ' At PASSAGE $indexOfPassage:';
//     if (i > -1) {
//       err += 'Passage bị thiếu:\n$i\n${passage[i].passage}';
//     }
//     err += '\n';
//   }

//   String countText(String text) {
//     String kyTuConThieu = '';
//     for (int i = 0; i < text.length; ++i) {
//       if (text[i] == ' ') {
//         break;
//       }
//       kyTuConThieu += text[i];
//     }
//     return kyTuConThieu;
//   }
// }
