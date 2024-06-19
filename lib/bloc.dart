import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/print.dart';

class BaseBloc {
  final textLrcCtrl = TextEditingController();
  final textOriginalCtrl = TextEditingController();
  List<String>? listLrcText = []; //each row//listOriginalText,
  List<List<String>> //listOriginalWord = [],
      listLrcWord = [],
      listSentenceNoTime = [],
      wordPair = [];
  // List<List<dynamic>> listSentenceNoTime = [];
  // String? originalText, lrcText;
  List<String> result = [],
      listTime = []; //là những câu có đầy đủ dấu (original)
  // splitOriginalText() {
    // RegExp regex = RegExp(r'[!.,:;?]');
  //   listOriginalText = textOriginalCtrl.text.split(regex);
  //   for (var sentence in listOriginalText!) {
  //     listOriginalWord.add([]);
  //     listOriginalWord.last = sentence.split(' ');
  //     p('listOriginalWord',
  //         listOriginalWord.first); //[“Curiouser, and, curiouser]
  //   }
  // }

  splitLrcText() {
    listLrcText = textLrcCtrl.text.split('\n');
    for (int i = 0; i < listLrcText!.length; ++i) {
      String sentence = listLrcText![i].trim();
      if (sentence.isEmpty) {
        //remove all empty, chỉ giữ lại empty đầu để lấy time
        // int a = i +
        //     1; //tạo biến a để giữ nguyên i (nếu tăng i thì hồi bị overRange vì list đã remove 1 số pt)
        // while (sentence[a].isEmpty) {
        //   listLrcText!.removeAt(a);
        // }
        listSentenceNoTime.add([]); //sentence empty cx phải add để hồi xử lý
      } else {
        //split ra từng từ
        listLrcWord.add([]);
        listLrcWord.last = sentence.split(' '); //[0]=time
        // listLrcWord.last = listLrcWord.last.sublist(1);
        listSentenceNoTime
            .add(listLrcWord.last.sublist(1)); //list con băt đầu từ 1
        wordPair = List.generate(
            (listSentenceNoTime.length).ceil(),
            (index) => listLrcWord.last.sublist(
                index * 2,
                ((listLrcWord.last.length - 1) - 2)
                    .clamp(0, listLrcWord.last.length)));
        // listSentenceNoTime.add(wordPair);
        listTime.add(listLrcWord.last[0]);
        p('found word, wordair', wordPair);
        // p('listLrcWord',
        //     listLrcWord.last); //[[00:03.000], "Curiouser, and, curiouser!"]
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
      p('bang, time:$lenListTime,res', lenListSentence);
      for (int i = 0; i < lenListTime; ++i) {
        resStr += '${listTime[i]} ${result[i]}\n';
      }
    } else {
      p('ko bang, time:$lenListTime,res', lenListSentence);
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
      if (sentence.isEmpty) {
        //
        // int start = original.indexOf(listSentenceNoTime[i - 1].last) +
        //     listSentenceNoTime[i - 1].last.length +
        //     1;
        // p('sentence empty, start cua ori:$start', original[start]);
        //tăng i tới khi nào gặp câu notEmpty
        // do {
        //   ++i;
        // } while (listSentenceNoTime[i].isEmpty);
        // String substr = original.substring(start);
        // p('empty, substr', substr);
        String word = '${listSentenceNoTime[i + 1].first} ';
        p('word', word); //t: I
        int end = original.indexOf(word) - 1;
        // p('sentence empty, end cua original:$end', original[end]);
        // listSentenceNoTime[i] =
        //     original.substring(start, end).trim().split(' '); //split word
        end = handleEndIndex(end, original);
        String sub = original.substring(0, end);
        result.add(sub);
        original = original.substring(end).trim();
        p('substr replace emty', result.last); //empty
        p('original sau handle empty',
            original); //It's good practice for you and me! I study at the Queen Mary University of London.
      } else {
        //notEmpty
// while (original.contains(sentence))
        String pairWordLast =
            '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
        p('pairWordLast', pairWordLast);
        // int end = original.indexOf(pairWordLast);
        //  String lastWord = sentence.last;
        // int start = original.indexOf(firstWord);
        // if (start > -1) {
        // p('contain firstWord: $start', firstWord);
        // String substr = original
        //     .substring(0)
        //     // .substring(start > 0 ? start - 1 : 0)
        //     .trim(); //-1 = lấy dấu trc nó (or space)
        var findLast = original.indexOf(pairWordLast);
        // p('findLast', findLast); //t
        if (findLast == -1) {
          //lấy end = indexOf(firstWord of sentence[i+1]) & từ trc firstWord đó phải contain(dấu) else báo err
           err += 'Err at ${listTime[i]}';
          //lùi tới khi gặp từ trùng khớp
          int a = sentence.length - 2; //start từ word kế cuối
          int delta = 0;
          while (a >= 0 && !original.contains(sentence[a])) {
            --a;
            ++delta; //=số space
          }
          if (a == -1) {
            //not found
            err += 'Not found word at ${listTime[i]}';
          } else {
            // int delta = sentence.length-1 - a;//=last-a
            //từ 0 -> từ đc tìm thấy
            int end = original.indexOf(sentence[a]) + sentence[a].length;
            p('found word: end', end);
            String sub = original.substring(0, end);
            //căt bơt phần đã handle
            p('found word: sub từ 0 -> từ đc tìm thấy', sub);
            original = original.removeDoneString(end);
            p('found word: ori removeDoneString1', original);
            int countSpace = 0;
            int indexOfSpace; //space ngay trước lastWord
            for (indexOfSpace = 0;
                indexOfSpace < original.length;
                ++indexOfSpace) {
              if (original[i] == ' ') {
                ++countSpace;
                if (countSpace == delta) break;
              }
            }
            end = indexOfSpace + pairWordLast.length; //0..51:55
            p('found word: end=indexOfSpace + lastWord.length', end);
            sub += original.substring(0, end); //0..297:299
            p('found word: sub từ 0 -> lastWord', sub);
            result.add(sub);
            original = original.removeDoneString(end);
            p('original.removeDoneString', original);
            //remove done
          }
        } else {
          int end = findLast +
              pairWordLast.length +
              1; //cộng thêm 2 dấu phía sau nó (or space).VD: ..bye!"
          // if (end > -1) {
          end = handleEndIndex(end, original);
          String substr = original.substring(0, end).trim();
          // substr = original.substring(0, original.indexOf(lastWord));
          result.add(substr);
          end = handleEndIndex(end, original);
          original = original.substring(end).trim();
        }
      }
    }
    // original = original.substring(handleEndIndex(end, original)).trim();
  }

  int handleEndIndex(int end, String original) =>
      end < original.length ? (end > -1 ? end : 0) : original.length - 1;
  // replaceLrcByOriginal() {
  //   for (int i = 0; i < listSentenceNoTime.length; ++i) {
  //     //make sure indexes of them are the same
  //     for (int j = 0; j < listOriginalWord.length; ++j) {
  //       if (listSentenceNoTime[i].isEqualSentence(listOriginalWord[j])) {
  //         //replace lrc by original
  //         listSentenceNoTime[i] = listOriginalWord[j];
  //         p('equal', listSentenceNoTime[i]);
  //       }
  //     }
  //   }
  // }
  mergeSentence() {}

  void reset() {
    // result = [];
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
