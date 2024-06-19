import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/base_bloc.dart';
import 'package:web_sync_lyrix/passage.dart';
import 'package:web_sync_lyrix/print.dart';

class Lyric extends BaseBloc {
  final textLrcCtrl = TextEditingController();
  final resLrcCtrl = TextEditingController();
  final textOriginalCtrl = TextEditingController();
  List<String> listLrcText = [], listTime = []; //each row//listOriginalText,
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<String> result = []; //là những câu có đầy đủ dấu (original)
  final passage = Passage();
  splitLrcText() {
    // passage.splitOriToPassage(textLrcCtrl.text);//'List<String>' is not a subtype of type 'String'
    listLrcText = textLrcCtrl.text.split('\n');
    for (int i = 0; i < listLrcText.length; ++i) {
      String sentence = listLrcText[i].trim();
      if (sentence.isEmpty) {
        //TODO:remove all empty, chỉ giữ lại empty đầu để lấy time ỏr báo err
        // int a = i +
        //     1; //tạo biến a để giữ nguyên i (nếu tăng i thì hồi bị overRange vì list đã remove 1 số pt)
        // while (sentence[a].isEmpty) {
        //   listLrcText!.removeAt(a);
        // }
        listSentenceNoTime.add([]); //sentence empty cx phải add để hồi xử lý
      } else {
        //split ra từng từ
        String str = sentence;
        str.replaceFirst(' ', ';;');
        p('str replace', str);
        List list = str.split(';;');
        listNoTime.add(list[1]); //passage
////////////////////////////////////////////
        listLrcWord.add([]); //
        listLrcWord.last = sentence.split(' '); //[0]=time
        listSentenceNoTime
            .add(listLrcWord.last.sublist(1)); //list con băt đầu từ 1
        listTime.add(listLrcWord.last[0]);
        listTimeOfPassage = List.from(listTime);
        p('listSentenceNoTime',
            listSentenceNoTime); //["Curiouser, and, curiouser!"]
      }
    }
  }

  matchTimeWithSentence() {
    String resStr = ''; //reset
    int lenListTime = listTime.length;
    int lenListSentence = result.length;
    if (lenListSentence == lenListSentence) {
      p('EQUAL, time:$lenListTime,res', lenListSentence);
      for (int i = 0; i < lenListTime; ++i) {
        resStr += '${listTime[i]} ${result[i]}\n';
      }
      resLrcCtrl.text = resStr;
      p('resStr', resStr);
    } else {
      p('NO EQUAL, time:$lenListTime,res', lenListSentence);
    }
  }

  onTapConvert() {
    splitLrcText();
    replaceLrcByOriginal();
    if (err == '') {
      //no err
      matchTimeWithSentence();
    }
    reset();
  }

  String err = '';
  replaceLrcByOriginal() {
    result = []; //reset
    String original = textOriginalCtrl.text
        .replaceAll("’", "'")
        .replaceAll('\n', ' ')
        .replaceAll('  ', ' ');
    for (int i = 0; i < listSentenceNoTime.length; ++i) {
      //each sentence
      List<String> sentence = listSentenceNoTime[i];
      if (sentence.isNotEmpty) {
        if (sentence.length < 3) {
          //merge (len<3)
          listSentenceNoTime[i] += listSentenceNoTime[i + 1];
          listSentenceNoTime.removeAt(i + 1);
          p('listSentenceNoTime after merge', listSentenceNoTime);
          //remove time
          listTime.removeAt(i + 1);
          p('listtime after remove', listTime);
        }
        //min=3
        String pairWordLast =
            '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
        p('pairWordLast', pairWordLast); //t
        var findLast = original.indexOf(pairWordLast);
        p('findLast', findLast); //t
        if (findLast > -1) {
          int end = findLast +
              pairWordLast.length+2; //+2 dấu phía sau nó (or space).VD: ..bye!"
          end = handleEndIndex(end, original);
          p('end ssau handle', end); //handle err:0..48:49
          String substr =
              original.substring(0, end).trim(); //0..47:48//tới pairWord
          p('sub', substr); //t
          original = original.removeDoneString(end);
          int dem = countPunc(original);
          p('dem punc', dem);
          String punc = original.substring(0, dem);
          p('punc2', punc);
          result.add(substr);
          // result.add(substr + punc);
          original = original.removeDoneString(dem); //remove punc
          p('original removedone in findLast > -1', original); //t
        } else {
          //not found pairWord
          //lấy end = indexOf(firstWord of sentence[i+1]) & từ trc firstWord đó phải contain(dấu) else báo err
          String pair =
              '${listSentenceNoTime[i + 1][listSentenceNoTime[i + 1].length - 2]} ${listSentenceNoTime[i + 1].last}';
          p('pair cua cau sau', pair);
          int end = original.indexOf(pair) - 1;
          p('end cua pair cau sau', end);
          if (end > -1) {
            String sub = original.substring(0, end);
            List<String> split = sub.split(' '); //tach word
            if (containPunc(split.last)) {
              result.add(sub);
              original = original.removeDoneString(end);
            } else {
              onErr(i, 'Not found pairwordLast');
            }
          }
        }
        /////////
      } else {
        //handle empty
        String word = '${listSentenceNoTime[i + 1].first} ';
        p('word', word); //t: I
        int end = original.indexOf(word) - 1;
        if (end > -1) {
          end = handleEndIndex(end, original);
          String sub = original.substring(0, end);
          result.add(sub);
          original = original.substring(end).trim();
          // p('substr replace emty', result.last); //empty
          p('original sau handle empty', original);
        } else {
          onErr(i, 'Handle empty err');
        }
      }
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    for (int i = 0; i < ori.length; ++i) {
      if (!ori[i].contains(regex)) {
        break;
      }
      ++dem;
    }
    // while (ori.contains('.')) {
    //   //gặp ký tự thì dừng lại
    //   ++dem;
    // }
    p('count punc', dem);
    return dem;
  }

  onErr(int i, String text) {
    err += '$text: Err at ${listTime[i]}';
  }

  RegExp regex = RegExp(r'[!.,:;?]');
  bool containPunc(String str) {
    return str.contains(regex);
  }

  int handleEndIndex(int end, String original) =>
      end < original.length ? (end > -1 ? end : 0) : original.length - 1;
  mergeSentence() {}

  void reset() {
    listSentenceNoTime = [];
    listLrcText = [];
    listTime = [];
    listLrcWord = [];
    err = '';
  }
}

// extension ListStringExtension on List<String> {
//   bool isEqualSentence(List<String> otherSentence) {
//     return this[0] == otherSentence[0] && last == otherSentence.last;
//   }
// }

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start).trim();
  }
}
