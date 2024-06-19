import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/print.dart';

class BaseBloc {
  final textLrcCtrl = TextEditingController();
  final textOriginalCtrl = TextEditingController();
  List<String> listLrcText = []; //each row//listOriginalText,
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<String> result = [],
      listTime = []; //là những câu có đầy đủ dấu (original)

  splitLrcText() {
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
        listLrcWord.add([]); //
        listLrcWord.last = sentence.split(' '); //[0]=time
        listSentenceNoTime
            .add(listLrcWord.last.sublist(1)); //list con băt đầu từ 1
        listTime.add(listLrcWord.last[0]);
        p('listSentenceNoTime',
            listSentenceNoTime); //["Curiouser, and, curiouser!"]
      }
    }
  }

  String resStr = '';
  matchTimeWithSentence() {
    resStr = ''; //reset
    int lenListTime = listTime.length;
    int lenListSentence = result.length;
    if (lenListSentence == lenListSentence) {
      p('EQUAL, time:$lenListTime,res', lenListSentence);
      for (int i = 0; i < lenListTime; ++i) {
        resStr += '${listTime[i]} ${result[i]}\n';
      }
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
        if (sentence.length > 2) {
          //min=3
          String pairWordLast =
              '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
          p('pairWordLast', pairWordLast); //t
          var findLast = original.indexOf(pairWordLast);
          p('findLast', findLast); //t
          if (findLast > -1) {
            int end = findLast +
                pairWordLast.length +
                2; //cộng thêm 2 dấu phía sau nó (or space).VD: ..bye!"
            p('end trc handle', end);
            end = handleEndIndex(end, original);
            p('end ssau handle', end);
            String substr =
                original.substring(0, end).trim(); //0..47:48//tới pairWord
            p('sub', substr);
            // original = original.removeDoneString(end);
            // p('ori trong findLast > -1', original);
            // int dem = countPunc(original);
            // String punc = original.substring(0, dem);
            // p('punc2', punc);
            result.add(substr);
            // end = handleEndIndex(end, original);
            // original = original.substring(end).trim();
            original = original.removeDoneString(end);
            p('original removedone in findLast > -1', original); //t
          } else {
            onErr(i);
            return;
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
                onErr(i);
              }
            }
          }
        } else {
          //TODO:merge (len<3)
        }
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
          onErr(i);
        }
      }
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy wordword)
    //đếm số dấu ngay sau word
    int dem = 0;
    while (ori.contains(regex)) {
      //gặp ký tự thì dừng lại
      ++dem;
    }
    p('count punc', dem);
    return dem;
  }

  onErr(int i) {
    err += 'Err at ${listTime[i]}';
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

extension ListStringExtension on List<String> {
  bool isEqualSentence(List<String> otherSentence) {
    return this[0] == otherSentence[0] && last == otherSentence.last;
  }
}

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start).trim();
  }
}
