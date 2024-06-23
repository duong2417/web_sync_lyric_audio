import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/custom_textfield.dart';
import 'package:web_sync_lyrix/err_model.dart';
import 'package:web_sync_lyrix/extension.dart';
import 'package:web_sync_lyrix/model.dart';
import 'package:web_sync_lyrix/passage_model.dart';
import 'package:web_sync_lyrix/print.dart';

class Lyric {
  List<LyricModel> listModel = []; //result
  final textLrcCtrl = TextEditingController();
  final textOriginalCtrl = TextEditingController();
  final resLrcCtrl = CustomTextEditCtrl();
  final passageResCtrl = TextEditingController();
  List<String> listLrcText = [], listTime = []; //each row//listOriginalText,
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<OnePassage> passage = [];
  List<PassageModel> passageModel = []; //result
  int errExit = 0;
  handlePassage() {
    if (passage.length < 2) {
      passageModel.add(PassageModel(
          time: '[00:00.000]', passage: passage[0].passage, index: 1));
      onPassageErr(s: 'Only 1 passage!');
    } else {
      List<LyricModel> clone = List.from(listModel);
      // p('clone', clone); //t
      // p('passage trong handlePassage', passage); //t
      for (int i = 0; i < passage.length; ++i) {
        for (int j = 0; j < clone.length; ++j) {
          //1 passage có tối thiểu 1 câu nên file lyric cũng băt đầu từ pt 1
          if (passage[i].sentences.first.contains(clone[j].sentence.trim()) ||
              clone[j].sentence.contains(passage[i].sentences.first.trim())) {
            // p('passage[i].sentences.first:${passage[i].sentences.first},clone[j].sentence:',
            //     clone[j].sentence); //No element
            passageModel.add(PassageModel(
                time: clone[j].time,
                passage: passage[i].passage,
                index: i + 1));
            // p('passageModel', passageModel);
            //remove done part: từ 0->vị trí listTime đó
            clone.removeRange(0, j);
            // p('clone rm', clone); //t
            break;
          } else {
            // p('ko contain:passage[i].sentences.first:${passage[i].sentences.first},clone[j].sentence:',
            //     clone[j].sentence);
          }
        }
      }
      hanleResPassage(passageModel);
    }
  }

  hanleResPassage(List<PassageModel> passageModel) {
    String res = '';
    // p('passageModel trong hanleResPassage', passageModel); //[]
    for (PassageModel model in passageModel) {
      res += model.toString();
      res += '\n';
    }
    passageResCtrl.text = res;
  }

  checkLrcResult(String res) {
    // int start = 0;
    for (int i = 0; i < listModel.length; ++i) {
      if (i > 0) {
        if (listModel[i].sentence == listModel[i - 1].sentence) {
          // start = res.indexOf(listModel[i].sentence);
          // resLrcCtrl.selection =
          //     TextSelection(baseOffset: start, extentOffset: start + 20); //11
          onErr(i, 'trùng câu'); //xóa câu sau
        } else {
          // if (listModel[i].sentence.isEmpty) {
          //   start = res.indexOf(listModel[i].sentence);
          //   resLrcCtrl.selection =
          //       TextSelection(baseOffset: start, extentOffset: start + 30);
          // }
        }
      }
      if (listModel[i].sentence.isEmpty) {
        onErr(i, 'Sentence empty'); //t
      }
    }
  }

  splitLrcText() {
    List<String> listPassage = original.split('\n')
      ..removeWhere((element) => element.isEmpty)
      ..forEach((element) {
        element = element.trim(); //remove \n thừa//f
      });
    for (int i = 0; i < listPassage.length; ++i) {
      passage.add(OnePassage(
          sentences: listPassage[i]
              .split(RegExp(r'[.?!;]')) //tach passage thanh tung cau
            ..removeWhere((element) => element.isEmpty),
          passage: listPassage[i]));
    }
    // p('passage add onepassage', passage); //t
    listLrcText = textLrcCtrl.text.split(
        '\n') //lrc phải xóa hêt dấu, chỉ còn chữ thì câu trong passage dễ contain hơn (nhiều khi máy tự thêm dấu sai)
      ..removeWhere((element) => element.isEmpty)
      ..forEach((element) {
        element = element.trim(); //remove \n thừa//f
      });
    for (int i = 0; i < listLrcText.length; ++i) {
      String sentence = listLrcText[i];
      if (sentence.contains(' ')) {
//split ra từng từ
        listLrcWord.add([]);
        listLrcWord.last = sentence.split(' '); //[0]=time
        // p('listLrcWord', listLrcWord);
        List<String> words = listLrcWord.last.sublist(1);
        // p('words', words);
        listSentenceNoTime.add(words); //list con băt đầu từ 1
        // p('listSentenceNoTime',
        //     listSentenceNoTime);
        listTime.add(listLrcWord.last[0]); //đặt trong vòng for (=số câu lyric)
      } else {
        if (i == listLrcText.length - 1) {
          //câu cuối
          listSentenceNoTime.add([]);
          listLrcWord.last = [sentence.trim()]; //lấy time
          listTime.add(listLrcWord.last[0]);
        }
        onWarning(i + 1); //empty
      }
    }
  }

  void onWarning(int i) {
    String timeLine = listTime[i < listTime.length ? i : listTime.length - 1];
    resLrcCtrl.listErr.add(ErrorModel(timeLine: timeLine));
  }

  String resStr = '';

  onTapConvert() {
    reset();
    pretreatmentOri();
    splitLrcText();
    if (errExit == 0) {
      //success
      replaceLrcByOriginal();
      handleLrcResult();
      handlePassage();
      // checkResPassage();
    }
  }

  handleLrcResult() {
    for (LyricModel e in listModel) {
      resStr += e.toString();
      resStr += '\n';
    }
    resLrcCtrl.text = resStr;
    // checkLrcResult(resStr); //only show err if has null sentence
  }

  String err = '';
  String original = '';
  pretreatmentOri() {
    original = textOriginalCtrl.text
        .replaceAll(RegExp(r'[‘’]'), "'"); //để I’m contain I'm
    // .replaceAll(RegExp(r'[“”]'), '"');
  }

  replaceLrcByOriginal() {
    String sub = '';
    listModel = [];
    bool isAddToResult;
    String oriOfLrc = original.replaceAll('\n', ' ');
    for (int i = 0; i < listSentenceNoTime.length; ++i) {
      isAddToResult = true;
      List<String> sentence = listSentenceNoTime[i];
      if (sentence.isEmpty) {
        //câu cuối
        listModel.add(LyricModel(time: listTime[i], sentence: oriOfLrc));
        p('sub cau cuoi2', sub);
        p('ori cau cuoi2', oriOfLrc);
        break;
      }
      //sentence not empty
      String pairWord;
      if (sentence.length < 2) {
        pairWord = sentence.last;
      } else {
        pairWord =
            '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
      }
      var findLast = oriOfLrc.toLowerCase().indexOf(pairWord.toLowerCase());
      if (findLast > -1) {
        int end = findLast +
            pairWord.length; //+2 dấu phía sau nó (or space).VD: ..bye!"
        end = handleEndIndex(end, oriOfLrc);
        String substr = oriOfLrc.substring(0, end).trim(); //cp
        oriOfLrc = oriOfLrc.removeDoneString(end);
        int dem = countPunc(oriOfLrc);
        String punc = dem > 0 ? oriOfLrc.substring(0, dem) : '';
        p('punc', punc);
        //substring căt ko lấy end. VD: dem=1=> chỉ lấy 1 kí tự 0, chứ ko phải lấy ký tự 0 và 1
        sub = substr + punc;
        oriOfLrc = oriOfLrc.removeDoneString(dem); //remove punc
      } else {
        //not found pairWordLast
        int a = i + 1;
        if (a >= listSentenceNoTime.length) {
          listModel.add(LyricModel(
              time: listTime[listTime.length - 1], sentence: oriOfLrc));
          // p('sub cau cuoi1', sub);
          // p('ori cau cuoi1', oriOfLrc);
          onErr(i, 'Câu cuối có cặp từ cuối ko trùng khớp');
          errExit = -1;
          break;
        }
        String pair;
        if (listSentenceNoTime[a].length > 1) {
          pair = '${listSentenceNoTime[a].first} ${listSentenceNoTime[a][1]}';
        } else {
          pair = listSentenceNoTime[a].first;
        }
        int end = oriOfLrc.toLowerCase().indexOf(pair.toLowerCase());
        if (end > -1) {
          end = handleEndIndex(end - 1, oriOfLrc);
          //lùi lại 1 dấu (nháy...) để nó ko lấy dấu mở của câu sau
          sub = oriOfLrc.substring(0, end).trim();
          oriOfLrc = oriOfLrc.removeDoneString(end);
        } else {
          //giữ lại time, gán time này cho câu sau (bỏ time của câu sau)
          if (i < listTime.length - 1) {
            listTime[i + 1] = listTime[i]; //t
          } else {
            //listTime giữ nguyên => vẫn là time của câu sau (thay vì câu đầu)
          }
          isAddToResult = false;
          onWarning(i + 1); //not found pairWordFirst
        }
      }
      //sentence empty vẫn add
      if (isAddToResult) {
        listModel.add(LyricModel(
            time: listTime[i],
            sentence:
                sub)); //bị lặp câu vì ko có nào match nó vẫn add (lấy câu trc)
      }
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    ori = ori
        .trim(); //and "how" => trim là lấy dấu câu khác//and ! => ko trim là ko lấy đc dấu !//đa số punc để sát word
    for (int i = 0; i < ori.length; ++i) {
      if (!ori[i].contains(closePunc)) {
        // || ori[i].contains(openPunc)
        break;
      }
      ++dem;
    }
    return dem;
  }

  onErr(int i, String text) {
    err += text;
    if (i > -1) {
      resLrcCtrl.listErr.add(ErrorModel(
          type: TypeErr.error,
          timeLine: listTime[i < listTime.length ? i : listTime.length - 1]));
      //i=-1 là ko hiện index,chỉ hiện text
      err += ' (at ROW ${i + 1})';
      // if (i < listModel.length) {
      //   err += '${listModel[i].toString()}}';
      // }
    }
    err += '\n';
  }

  void reset() {
    listSentenceNoTime = [];
    listLrcText = [];
    listTime = [];
    listLrcWord = [];
    listModel = [];
    resStr = '';
    err = '';
    errExit = 0;
    //reset passage
    passage = [];
    passageModel = [];
    resLrcCtrl.clear();
    resLrcCtrl.text = '';
    resLrcCtrl.listErr = [];
    // resLrcCtrl.spans = [];
    resLrcCtrl.starts = [];
  }

  void onPassageErr({int i = -1, int indexOfPassage = -1, String? s}) {
    if (s != null) {
      err += s;
    }
    err += ' At PASSAGE $indexOfPassage:';
    if (i > -1) {
      err += 'Passage bị thiếu:\n$i\n${passage[i].passage}';
    }
    err += '\n';
  }
}
