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
    // int flag = 0;
    for (int i = 0; i < listLrcText.length; ++i) {
      String sentence = listLrcText[i];
      if (sentence.isNotEmpty) {
        //split ra từng từ
        // String str = sentence;
        // str.replaceFirst(' ', ';;');
        // p('str replace', str);
        // List list = str.split(';;');
        // listNoTime.add(list[1]); //passage
////////////////////////////////////////////
        listLrcWord.add([]); //
        listLrcWord.last = sentence.split(' '); //[0]=time
        listSentenceNoTime
            .add(listLrcWord.last.sublist(1)); //list con băt đầu từ 1
        // listTime.add(listLrcWord.last[0]);
        // listTimeOfPassage = List.from(listTime);////////////
        p('listSentenceNoTime',
            listSentenceNoTime); //["Curiouser, and, curiouser!"]
      } else {
        //TODO:remove all empty, chỉ giữ lại empty đầu để lấy time ỏr báo err
        // int a = i +
        //     1; //tạo biến a để giữ nguyên i (nếu tăng i thì hồi bị overRange vì list đã remove 1 số pt)
        // while (sentence[a].isEmpty) {
        //xóa hêt mấy cái sau i
        // p('flag', flag);
        // if (flag == 1) {
        //   listLrcText.removeAt(i); //xóa lun time
        //   listSentenceNoTime.removeAt(i);
        //   listTime.removeAt(i);//[00:00:00, 00:00:31, 00:00:48, 00:01:02]
        //   p('listtime after remove', listTime); //t//[00:00:00, 00:00:31, 00:01:02]
        //   p('listLrcText after remove', listLrcText); //t
        //   p('listSentenceNoTime after remove', listSentenceNoTime); //t
        //   // }
        //   return; //để đừng chạy xuống add time
        // } else {
        //   listSentenceNoTime.add(
        //       []); //sentence empty cx phải add để hồi xử lý//add duy nhât lần đầu tiên (flag=0)
        //   p('listSentenceNoTime add empy', listSentenceNoTime);
        //   flag = 1;
        // }
      }
      listTime.add(listLrcWord.last[
          0]); //sentence empty vẫn add time (add duy nhât lần đầu)//add 1 time
      p('listTime dưới cùng', listTime);
    }
  }

  String resStr = '';
  matchTimeWithSentence() {
    resStr = ''; //reset
    int lenListTime = listTime.length;
    int lenListSentence = result.length; //
    if (lenListSentence == lenListTime) {
      // p('EQUAL, time:$lenListTime,res', lenListSentence);
      for (int i = 0; i < lenListSentence; ++i) {
        resStr +=
            '${listTime[i]} ${result[i]}\n'; //Index out of range: index must not be negative: -2
      }
      resLrcCtrl.text =
          resStr; // Index out of range: index should be less than 3: 3
      // p('resStr', resStr);
    } else {
      onErr(0,
          'No equal betwen time and sentence: lenTime: $lenListTime lenSetence:$lenListSentence');
      // p('NO EQUAL, time:$lenListTime,res', lenListSentence);
    }
  }

  onTapConvert() {
    splitLrcText();
    replaceLrcByOriginal();
    matchTimeWithSentence();
    checkResult();
    reset();
  }

  String err = '';
  replaceLrcByOriginal() {
    result = []; //reset
    String original = textOriginalCtrl.text
        .replaceAll(
            "’", "'") //Index out of range: index must not be negative: -2
        .replaceAll('\n', ' ')
        .replaceAll('  ', ' ');
    for (int i = 0; i < listSentenceNoTime.length; ++i) {
      //each sentence
      List<String> sentence = listSentenceNoTime[i];
      // if (sentence.isNotEmpty) {
      if (sentence.isEmpty) {
        String pair =
            '${listSentenceNoTime[i + 1].first} ${listSentenceNoTime[i + 1][1]}';
        p('pair cua cau sau', pair); //is German
        int end = original.indexOf(pair); //- 1;//- space
        p('end cua pair cau sau', end);
        if (end > -1) {
          end = handleEndIndex(end, original);
          p('end sau handle', end);
          String sub = original.substring(0, end).trim();
          p('sub từ 0->start câu sau', sub); //I am eighteen years old.//t
          result.add(sub);
          p('result', result);
          original = original.removeDoneString(end);
          p('ori sau rm done', original); //My father is German.//t
        }
        // return;
      } else {
        if (sentence.length < 3) {
          //sentence.isNotEmpty &&
          //merge (len<3)
          // String s = ' ${listSentenceNoTime[i + 1]}';
          listSentenceNoTime[i].addAll(listSentenceNoTime[i + 1]);
          // p('sentence after merge', listSentenceNoTime[i]); //t
          listSentenceNoTime.removeAt(i + 1);
          // p('listSentenceNoTime after merge', listSentenceNoTime); //t
          //remove time
          listTime.removeAt(i + 1);
          // p('listtime after remove',
          //     listTime); //[00:00:00, 00:00:31, 00:01:02]//t
          /*
00:00:00 My name is Robinson
00:00:31
00:00:48 I am eighteen years old
00:01:02 My father is German
=> merge câu 2 với câu 3
            */
        }
        //min=3. Lưu ý: phải handle câu có len < 2 rồi mới xuống đây đc (vì index-2=>index>-2)
        String pairWordLast =
            '${sentence[sentence.length - 2]} ${sentence.last}'; //cặp từ cuối câu
        p('pairWordLast', pairWordLast); //t
        var findLast = original.indexOf(pairWordLast);
        // p('findLast', findLast); //t
        if (findLast > -1) {
          int end = findLast +
              pairWordLast.length; //+2 dấu phía sau nó (or space).VD: ..bye!"
          end = handleEndIndex(end, original);
          p('end ssau handle', end); //handle err:0..48:49
          String substr =
              original.substring(0, end).trim(); //0..47:48//tới pairWord
          // p('sub tới pairword (no punc)', substr); //t
          original = original.removeDoneString(end);
          // p('ori sau removeDone(lấy từ punc đến hết)',original);//t
          int dem = countPunc(
              original); // Index out of range: index should be less than 4: 4
          String punc = original.substring(0, dem);
          // p('punc (ori sau khi cat tới dem để lấy punc)', punc);//t
          result.add(substr + punc);
          original = original.removeDoneString(dem); //remove punc
          p('original removedone in findLast > -1',
              original); //t//empty chạy ts dây
        } else {
          err += 'not found pairWord at ${listTime[i]}';
          //lấy end = indexOf(firstWord of sentence[i+1]) & từ trc firstWord đó phải contain(dấu) else báo err
          // String pair =
          //     '${listSentenceNoTime[i + 1][listSentenceNoTime[i + 1].length - 2]} ${listSentenceNoTime[i + 1].last}';
          String pair =
              '${listSentenceNoTime[i + 1].first} ${listSentenceNoTime[i + 1][1]}';
          p('pair cua cau sau', pair); //is German
          int end = original.indexOf(pair); //- 1;//- space
          p('end cua pair cau sau', end);
          if (end > -1) {
            end = handleEndIndex(end, original);
            p('end sau handle', end);
            String sub = original.substring(0, end).trim();
            p('sub từ 0->start câu sau', sub); //I am eighteen years old.//t
            result.add(sub);
            p('result', result);
            original = original.removeDoneString(end);
            p('ori sau rm done', original); //My father is German.//t
          }
        }
      }
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    // p('ori trc khi dem punc', ori);
    // ori = ori.trim();//and "how" => trim là lấy dấu câu khác//and ! => ko trim là ko lấy đc dấu !//đa số punc để sát word
    p('ori trc khi dem punc, sau trim', ori);
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
    for (int i = 0; i < result.length; ++i) {
      if (result[i].isEmpty) {
        onErr(i, 'Sentence empty'); //t
      }
    }
  }

  onErr(int i, String text) {
    err += '$text: Err at ${listTime[i]}, sentence:${result[i]}';
    p('my err', err);
  }

  RegExp regex = RegExp(r'[?!.,:;"\/()]');
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
    // err = '';
  }
}

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start).trim();
  }
}
