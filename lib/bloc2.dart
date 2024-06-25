// import 'package:flutter/material.dart';
// import 'package:web_sync_lyrix/custom_textfield.dart';
// import 'package:web_sync_lyrix/err_model.dart';
// import 'package:web_sync_lyrix/extension.dart';
// import 'package:web_sync_lyrix/model.dart';
// import 'package:web_sync_lyrix/passage_model.dart';

// class Lyric {
//   List<LyricModel> listModel = []; //result
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
//       List<LyricModel> clone = List.from(listModel);
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
//         listLrcWord.add([]);
//         listLrcWord.last = sentence.split(' '); //[0]=time
//         List<String> words = listLrcWord.last.sublist(1);
//         listSentenceNoTime.add(words); //list con băt đầu từ 1
//         listTime.add(listLrcWord.last[0]); //đặt trong vòng for (=số câu lyric)
//       } else {
//         listTime.add(sentence);
//         listSentenceNoTime.add([]);
//         if (i == listLrcText.length - 1) {
//           //câu cuối
//           // listLrcWord.last = [sentence.trim()]; //lấy time
//           // listTime.add(listLrcWord.last[0]);
//           onErr(i, "Câu cuối của file lrc empty");
//         } else {
//           onErr(i, 'lrc chứa câu empty');
//         }
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
//       handlePassage();
//     }
//   }

//   handleLrcResult() {
//     for (LyricModel e in listModel) {
//       resStr += e.toString();
//       resStr += '\n';
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
//     listModel = [];
//     bool isAddToResult;
//     String pairWord;
//     int findLast = -1;
//     int demPunc;
//     String punc;
//     int end;
//     List<String> sentence;
//     String oriOfLrc = original.replaceAll('\n', ' ');
//     for (int i = 0; i < listSentenceNoTime.length; ++i) {
//       isAddToResult = true; //nếu F thì reset về T
//       sentence = listSentenceNoTime[i];
//       if (sentence.length >= 2) {
//         pairWord =
//             '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
//         findLast = oriOfLrc.toLowerCase().indexOf(pairWord.toLowerCase());
//         if (findLast > -1) {
//           end = findLast + pairWord.length;
//           String substr = oriOfLrc.substring(0, end).trim(); //sub chưa lấy punc
//           oriOfLrc = oriOfLrc.removeDoneString(end);
//           demPunc = countPunc(oriOfLrc);
//           punc = demPunc > 0 ? oriOfLrc.substring(0, demPunc) : '';
//           //substring căt ko lấy end. VD: dem=1=> chỉ lấy 1 kí tự 0, chứ ko phải lấy ký tự 0 và 1
//           sub = substr + punc;
//           oriOfLrc = oriOfLrc.removeDoneString(demPunc); //remove punc
//         } else {
//           int a = i + 1;
//           if (a >= listSentenceNoTime.length) {
//             listModel.add(LyricModel(
//                 time: listTime[listTime.length - 1], sentence: oriOfLrc)); //t
//             onErr(i, 'Câu cuối có cặp từ cuối ko trùng khớp');
//             errExit = -1;
//             break;
//           }
//           pairWord = listSentenceNoTime[a].first;
//           if (listSentenceNoTime[a].length > 1) {
//             pairWord += ' ${listSentenceNoTime[a][1]}';
//           }
//           int end = oriOfLrc.toLowerCase().indexOf(pairWord.toLowerCase());
//           if (end > -1) {
//             end = handleEndIndex(end - 1, oriOfLrc);
//             //lùi lại 1 dấu (nháy...) để nó ko lấy dấu mở của câu sau
//             sub = oriOfLrc.substring(0, end).trim();
//             oriOfLrc = oriOfLrc.removeDoneString(end);
//           } else {
//             //giữ lại time, gán time này cho câu sau (bỏ time của câu sau),
//             //not found pairWordFirst
//             isAddToResult = setNextTime(a);
//           }
//         }
//       } else {
//         //sentence has only 1word
//         //bỏ qua câu này (ko add vào res) để nhập vào câu sau, chỉ giữ time
//         isAddToResult = setNextTime(i + 1);
//       }
//       //phải check isAddToResult để tránh lặp câu (ko thỏa nó vẫn lấy sub cũ để add dô res)
//       if (isAddToResult) {
//         listModel.add(LyricModel(time: listTime[i], sentence: sub));
//       }
//     }
//   }

//   bool setNextTime(int a) {
//     if (a < listTime.length) {
//       listTime[a] = listTime[a - 1]; //t
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
//     listSentenceNoTime = [];
//     listLrcText = [];
//     listTime = [];
//     listLrcWord = [];
//     listModel = [];
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
// }
