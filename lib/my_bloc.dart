import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/model.dart';
import 'package:web_sync_lyrix/passage_model.dart';
import 'package:web_sync_lyrix/print.dart';

class Lyric {
  List<LyricModel> listModel = []; //result
  final textLrcCtrl = TextEditingController();
  final textOriginalCtrl = TextEditingController();
  final resLrcCtrl = TextEditingController();
  final passageResCtrl = TextEditingController();
  List<String> listLrcText = [], listTime = []; //each row//listOriginalText,
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<OnePassage> passage = [];
  List<PassageModel> passageModel = []; //result
  int errExit = 0;
  handlePassage() {
    passageModel.add(PassageModel(
        time: '[00:00.000]', passage: passage[0].passage, index: 1));
    if (passage.length < 2) {
      onPassageErr(s: 'Only 1 passage!');
    } else {
      List<LyricModel> clone = List.from(listModel);
      p('clone', clone); //t
      p('passage trong handlePassage',
          passage); //t:[[I’m a student,  I want to tell you about my student life in English,  It’s good practice for you and me!], [], [I study at the Queen Mary University of London, ]]
      for (int i = 1; i < passage.length; ++i) {
        for (int j = 0; j < clone.length; ++j) {
          //1 passage có tối thiểu 1 câu nên file lyric cũng băt đầu từ pt 1
          if (passage[i].sentences.first.contains(clone[j].sentence.trim()) ||
              // passage[i].sentences.first.trim() == clone[j].sentence.trim() ||
              clone[j].sentence.contains(passage[i].sentences.first.trim())) {
            p('passage[i].sentences.first:${passage[i].sentences.first},clone[j].sentence:',
                clone[j].sentence); //No element
            passageModel.add(PassageModel(
                time: clone[j].time,
                passage: passage[i].passage,
                index: i + 1));
            // p('passageModel', passageModel);
            //remove done part: từ 0->vị trí listTime đó
            clone.removeRange(0, j);
            p('clone rm', clone); //t
            break;
          } else {
            p('ko contain:passage[i].sentences.first:${passage[i].sentences.first},clone[j].sentence:',
                clone[j].sentence);
          }
        }
      }
      hanleResPassage(passageModel);
    }
  }

  hanleResPassage(List<PassageModel> passageModel) {
    String res = '';
    p('passageModel trong hanleResPassage', passageModel); //[]
    for (PassageModel model in passageModel) {
      res += model.toString();
      res += '\n';
    }
    p('res passage', res);
    passageResCtrl.text = res;
  }

  checkResPassage() {
    for (int i = 0; i < passage.length; ++i) {
      //passage gốc
      if (i < passageModel.length) {
        //passage result
        int? indexOfPassage = passageModel[i].index;
        if (indexOfPassage != null) {
          if (i != indexOfPassage - 1) {
            onPassageErr(indexOfPassage: indexOfPassage, i: i);
          }
        } else {
          //indexOfPassage null
        }
      }
    }
  }

  splitLrcText() {
    // String xoaBreakLineThua =
    //     textOriginalCtrl.text.replaceAll(RegExp(r'\n+'), '\n');
    // log(xoaBreakLineThua);
    List<String> listPassage =
        textOriginalCtrl.text.replaceAll("’", "'").split('\n')
          ..removeWhere((element) => element.isEmpty)
          ..forEach((element) {
            element = element.trim(); //remove \n thừa//f
          });

    p('listPassage tach doan', listPassage);
    for (int i = 0; i < listPassage.length; ++i) {
      passage.add(OnePassage(
          sentences: listPassage[i]
              .split(RegExp(r'[.?!;]')) //tach passage thanh tung cau
            ..removeWhere((element) => element.isEmpty),
          passage: listPassage[i]));
    }
    p('passage add onepassage', passage); //t
    listLrcText = textLrcCtrl.text.replaceAll(RegExp(r'.,;"-_()!?{}'), '').split(
        '\n') //lrc phải xóa hêt dấu, chỉ còn chữ thì câu trong passage dễ contain hơn (nhiều khi máy tự thêm dấu sai)
      ..removeWhere((element) => element.isEmpty)
      ..forEach((element) {
        element = element.trim(); //remove \n thừa//f
      });
    int flag = 0;
    for (int i = 0; i < listLrcText.length; ++i) {
      String sentence = listLrcText[i];
      if (sentence.contains(' ')) {
        //câu lyric đó có chứa word
//split ra từng từ
        listLrcWord.add([]);
        listLrcWord.last = sentence.split(' '); //[0]=time
        // p('listLrcWord', listLrcWord);
        List<String> words = listLrcWord.last.sublist(1);
        // p('words', words);
        listSentenceNoTime.add(words); //list con băt đầu từ 1
        // p('listSentenceNoTime',
        //     listSentenceNoTime); //["Curiouser, and, curiouser!"]
        listTime.add(listLrcWord.last[0]); //đặt trong vòng for (=số câu lyrix)
      } else {
        //sentence empty (vẫn có time)
        // p('flag', flag);
        if (flag == 1) {
          onErr(i, 'Có hơn 1 câu null, đã merge chúng thành 1');
          listLrcText.removeAt(i); //xóa cả time và câu
          // p('listLrcText',
          //     listLrcText); //t:[[00:00.000] I'm a student, [00:01.000], [00:07.000] I study at the Queen Mary University of London.]
          // if (i > 0) {
          --i; //for tăng i lên nên nếu i=-1 thì tăn lên là 0
          // }
        } else {
          //empty lần đầu
          listSentenceNoTime.add(
              []); //sentence empty cx phải add để hồi xử lý//add duy nhât lần đầu tiên (flag=0)
          //   p('listSentenceNoTime add empy', listSentenceNoTime);
          listLrcWord.last = [sentence.trim()];
          listTime.add(listLrcWord.last[
              0]); //sentence empty vẫn add time (add duy nhât lần đầu)//add 1 time
          // p('listLrcWord trong add empty đầu tiên', listLrcWord);
          flag = 1;
        }
      }
      // p('listTime dưới cùng', listTime);
    }
  }

  String resStr = '';

  onTapConvert() {
    reset();
    splitLrcText();
    if (errExit == 0) {
      //success
      replaceLrcByOriginal();
      handleResult();
    }
    handlePassage();
    checkResPassage();
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
  String original = '';
  replaceLrcByOriginal() {
    String sub = '';
    listModel = []; //
    original = textOriginalCtrl.text.replaceAll("’", "'").replaceAll('\n', ' ');
    // .replaceAll('  ', ' ');
    for (int i = 0; i < listSentenceNoTime.length; ++i) {
      List<String> sentence = listSentenceNoTime[i];
      if (sentence.isEmpty) {
        int a = i + 1;
        if (a >= listSentenceNoTime.length) {
          onErr(i, 'Sentence empty và không có câu sau nó (maybe là câu cuối)');
          break;
        } else {
          String pair =
              '${listSentenceNoTime[i + 1].first} ${listSentenceNoTime[i + 1][1]}'; //đã merge câu ngắn nên số word luôn >= 2
          // p('pair cua cau sau', pair); //is German
          int end = original
              .indexOf(pair); //- 1space//nếu có dư space thì đã trim rồi
          // p('end cua pair cau sau', end);
          if (end > -1) {
            end = handleEndIndex(end, original);
            // p('end sau handle', end);
            sub = original.substring(0, end).trim();
            p('sub từ 0->start câu sau', sub); //t
            original = original.removeDoneString(end);
            // p('ori sau rm done', original);
          }
        }
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
          String punc = '';
          if (dem > 0) {
            punc = original.substring(0,
                dem); //căt ko lấy end. VD: dem=1=> chỉ lấy 1 kí tự 0, chứ ko phải lấy ký tự 0 và 1
          }
          p('punc (ori sau khi cat tới dem để lấy punc)', punc); //t//me!
          sub = substr + punc;
          p('sub+punc', sub); //It's good practice for you andme!
          original = original.removeDoneString(dem); //remove punc
          p('original removedone in findLast > -1',
              original); //t//empty chạy ts dây
        } else {
          // onErr(
          //     i, 'No err (just not found lastWord and I just used other way)');
          //lấy end = indexOf(firstWord of sentence[i+1]) & từ trc firstWord đó phải contain(dấu) else báo err
          int a = i + 1;
          if (a >= listSentenceNoTime.length) {
            errExit = -1;
            onErr(a, 'Câu cuối có cặp từ cuối ko trùng khớp');
            break;
          }
          String pair;
          if (listSentenceNoTime[a].length > 1) {
            pair = '${listSentenceNoTime[a].first} ${listSentenceNoTime[a][1]}';
          } else {
            pair = listSentenceNoTime[a].first;
          }
          int end = original.indexOf(pair);
          // p('end cua pair cau sau', end);
          if (end > -1) {
            end = handleEndIndex(end, original);
            // p('end sau handle', end);
            sub = original.substring(0, end).trim();
            // p('sub từ 0->start câu sau', sub); //I am eighteen years old.//t
            // result.add(sub);
            original = original.removeDoneString(end);
            // p('ori sau rm done', original); //My father is German.//t
          }
        }
      }
      //sentence empty vẫn add
      listModel.add(LyricModel(time: listTime[i], sentence: sub)); //
      p('model', listModel.toString());
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    p('ori trc khi dem punc', ori); //ko chua punc
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
    if (i != -1) {
      //-1 là ko hiện index,chỉ hiện text
      err += 'At ROW ${i + 1}:';
      if (i < listModel.length) {
        err += '$text:${listModel[i].toString()}}';
      } else {
        if (i < listTime.length) {
          //listTime là list chuẩn//lenListModel <= i < lenListTime => i là index cuối (câu cuối bị lỗi nên ko add vào listModel)
          err +=
              'đã merge tại: ${listTime[i]}'; //original bị căt hêt chỉ còn câu cuối
        }
        // err += text;
      }
    }
    err += text;
    err += '\n';
  }

  RegExp regex = RegExp(r'[?!.,:;"-_(){}]');
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
    //reset passage
    passage = [];
    passageModel = [];
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

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start).trim();
  }
}
