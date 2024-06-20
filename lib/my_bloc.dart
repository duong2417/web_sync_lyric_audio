import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/base_bloc.dart';
import 'package:web_sync_lyrix/model.dart';
import 'package:web_sync_lyrix/passage.dart';
import 'package:web_sync_lyrix/print.dart';

class Lyric extends BaseBloc {
  List<LyricModel> listModel = [];
  final textLrcCtrl = TextEditingController();
  final resLrcCtrl = TextEditingController();
  final textOriginalCtrl = TextEditingController();
  List<String> listLrcText = [], listTime = []; //each row//listOriginalText,
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<String> result = []; //là những câu có đầy đủ dấu (original)
  final passage = Passage();
  int errExit = 0;
  splitLrcText() {
    listLrcText = textLrcCtrl.text.split('\n');
    int flag = 0;
    for (int i = 0; i < listLrcText.length; ++i) {
      String sentence = listLrcText[i];
      if (sentence.isEmpty) {
        onErr(i, 'Sentence empty (ko có cả time)');
        errExit = -1;
        break;
      }
      if (sentence.contains(' ')) {
//split ra từng từ
        listLrcWord.add([]); //
        listLrcWord.last = sentence.split(' '); //[0]=time
        p('listLrcWord.last', listLrcWord.last);
        List<String> words = listLrcWord.last.sublist(1);
        p('words', words);
        listSentenceNoTime.add(words); //list con băt đầu từ 1
        p('listSentenceNoTime',
            listSentenceNoTime); //["Curiouser, and, curiouser!"]
      } else {
        //sentence empty (vẫn có time)
        p('flag', flag);
        if (flag == 1) {
          onErr(i,
              'Có hơn 1 câu null, hãy xóa và chừa lại time của câu null đầu tiên rồi thử lại!');
          errExit = -1;
          return;
        } else {
          listSentenceNoTime.add(
              []); //sentence empty cx phải add để hồi xử lý//add duy nhât lần đầu tiên (flag=0)
          //   p('listSentenceNoTime add empy', listSentenceNoTime);
          flag = 1;
        }
      }
      listTime.add(listLrcWord.last[
          0]); //sentence empty vẫn add time (add duy nhât lần đầu)//add 1 time
      p('listTime dưới cùng', listTime);
    }
    // replaceLrcByOriginal();
  }

  String resStr = '';
  // matchTimeWithSentence() {
  //   resStr = ''; //reset
  //   int lenListTime = listTime.length;
  //   int lenListSentence = result.length; //
  //   if (lenListSentence == lenListTime) {
  //     // p('EQUAL, time:$lenListTime,res', lenListSentence);
  //     for (int i = 0; i < lenListSentence; ++i) {
  //       resStr +=
  //           '${listTime[i]} ${result[i]}\n'; //Index out of range: index must not be negative: -2
  //     }
  //     resLrcCtrl.text =
  //         resStr; // Index out of range: index should be less than 3: 3
  //     // p('resStr', resStr);
  //   } else {
  //     onErr(0,
  //         'No equal betwen time and sentence: lenTime: $lenListTime lenSetence:$lenListSentence');
  //     // p('NO EQUAL, time:$lenListTime,res', lenListSentence);
  //   }
  // }

  onTapConvert() {
    reset();
    splitLrcText();
    if (errExit == 0) {
      //success
      replaceLrcByOriginal();
      handleResult();
    }
    // matchTimeWithSentence();
    // checkResult();
  }

  handleResult() {
    for (LyricModel e in listModel) {
      resStr += e.toString();
      resStr += '\n';
    }
    resLrcCtrl.text = resStr;
    checkResult(); //only show err if has null sentence
  }

  String err = '';
  replaceLrcByOriginal() {
    String sub = '';
    listModel = []; //
    String original = textOriginalCtrl.text
        .replaceAll("’", "'")
        .replaceAll('\n', ' ')
        .replaceAll('  ', ' ');
    for (int i = 0; i < listSentenceNoTime.length; ++i) {
      List<String> sentence = listSentenceNoTime[i];
      if (sentence.isEmpty) {
        int a = i + 1;
        if (a >= listSentenceNoTime.length) {
          onErr(i,
              'Sentence empty và không có câu sau nó (vì nó là câu cuối cùng)');
          return;
        }
        String pair =
            '${listSentenceNoTime[i + 1].first} ${listSentenceNoTime[i + 1][1]}'; //
        p('pair cua cau sau', pair); //is German
        int end = original.indexOf(pair); //- 1;//- space
        p('end cua pair cau sau', end);
        if (end > -1) {
          end = handleEndIndex(end, original);
          p('end sau handle', end);
          sub = original.substring(0, end).trim();
          p('sub từ 0->start câu sau', sub);
          // result.add(sub);
          p('result', result);
          original = original.removeDoneString(end);
          p('ori sau rm done', original);
        }
        // return;
      } else {
        if (sentence.length < 3) {
          int a = i + 1;
          if (a < listSentenceNoTime.length) {
            //>= thì do nothing (nó là câu cuối cùng, ko cần merge)
            listSentenceNoTime[i].addAll(listSentenceNoTime[a]);
            // p('sentence after merge', listSentenceNoTime[i]); //t
            listSentenceNoTime.removeAt(a);
            // p('listSentenceNoTime after merge', listSentenceNoTime); //t
            //remove time
            listTime.removeAt(a);
            /*
00:00:00 My name is Robinson
00:00:31
00:00:48 I am eighteen years old
00:01:02 My father is German
=> merge câu 2 với câu 3
            */
          }
        }
        //min=3. Lưu ý: phải handle câu có len < 2 rồi mới xuống đây đc (vì index-2=>index>-2)
        String pairWordLast =
            '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
        p('pairWordLast', pairWordLast); //t
        var findLast = original.indexOf(pairWordLast);
        p('findLast', findLast);
        if (findLast > -1) {
          int end = findLast +
              pairWordLast.length; //+2 dấu phía sau nó (or space).VD: ..bye!"
          end = handleEndIndex(end, original);
          p('end ssau handle', end); //handle err:0..48:49
          String substr =
              original.substring(0, end).trim(); //0..47:48//tới pairWord
          p('sub tới pairword (no punc)', substr); //t
          original = original.removeDoneString(end);
          p('ori sau removeDone(lấy từ punc đến hết)', original); //t
          int dem = countPunc(
              original); // Index out of range: index should be less than 4: 4
          String punc = original.substring(0, dem);
          p('punc (ori sau khi cat tới dem để lấy punc)', punc); //t//me!
          sub = substr + punc;
          p('sub+punc', sub); //It's good practice for you andme!
          original = original.removeDoneString(dem); //remove punc
          p('original removedone in findLast > -1',
              original); //t//empty chạy ts dây
        } else {
          onErr(
              i, 'No err (just not found lastWord and I just used other way)');
          //lấy end = indexOf(firstWord of sentence[i+1]) & từ trc firstWord đó phải contain(dấu) else báo err
          int a = i + 1;
          if (a >= listSentenceNoTime.length) {
            errExit = -1;
            onErr(i, 'Câu cuối có cặp từ cuối ko trùng khớp');
            break;
          }
          String pair =
              '${listSentenceNoTime[a].first} ${listSentenceNoTime[a][1]}';
          int end = original.indexOf(pair);
          // p('end cua pair cau sau', end);
          if (end > -1) {
            end = handleEndIndex(end, original);
            p('end sau handle', end);
            sub = original.substring(0, end).trim();
            p('sub từ 0->start câu sau', sub); //I am eighteen years old.//t
            // result.add(sub);
            original = original.removeDoneString(end);
            p('ori sau rm done', original); //My father is German.//t
          }
        }
      }
      //sentence empty vẫn add
      listModel.add(LyricModel(time: listTime[i], sentence: sub));
      p('model', listModel.toString());
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    p('ori trc khi dem punc', ori);
    ori = ori
        .trim(); //and "how" => trim là lấy dấu câu khác//and ! => ko trim là ko lấy đc dấu !//đa số punc để sát word
    p('ori trc khi dem punc, sau trim',
        ori); //me! I study at the Queen Mary University of London.
    for (int i = 0; i < ori.length; ++i) {
      if (!ori[i].contains(regex)) {
        break;
      }
      ++dem;
    }
    p('count punc', dem);
    return dem;
  }

  checkResult() {
    for (int i = 0; i < listModel.length; ++i) {
      if (listModel[i].sentence.isEmpty) {
        onErr(i, 'Sentence empty'); //t
      }
    }
  }

  onErr(int i, String text) {
    if (i < listModel.length) {
      err += '$text:${listModel[i].toString()}';
    } else {
      err += '$text (at row ${i + 1})';
    }
    // p('my err', err);
  }

  RegExp regex = RegExp(r'[?!.,:;"-_})]');
  bool containPunc(String str) {
    return str.contains(regex);
  }

  int handleEndIndex(int end, String original) =>
      end < original.length ? (end > -1 ? end : 0) : original.length - 1;

  void reset() {
    listSentenceNoTime = [];
    listLrcText = [];
    listTime = [];
    listLrcWord = [];
    listModel = [];
    resStr = '';
    err = '';
    errExit = 0;
  }
}

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start).trim();
  }
}
