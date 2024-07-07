import 'package:web_sync_lyrix/custom_textfield/custom_ori_textfield.dart';
import 'package:web_sync_lyrix/custom_textfield/custom_textfield.dart';
import 'package:web_sync_lyrix/model/err_model.dart';
import 'package:web_sync_lyrix/extension.dart';
import 'package:web_sync_lyrix/model/model.dart';
import 'package:web_sync_lyrix/passage_model.dart';

class Lyric {
  List<LyricModel> listModelOfLrcResult = [];
  List<LyricModel> listModelOfLrc = [];
  final textOriginalCtrl = CustomOriTextField();
  final textLrcCtrl = CustomTextEditCtrl();
  final resLrcCtrl = CustomTextEditCtrl();
  final resPassageCtrl = CustomTextEditCtrl();
  List<String> listLrcText = [], listTime = [];
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<OnePassage> passage = [];
  List<PassageModel> passageModelResult = [];
  reHandlePassage() {
    passageModelResult = [];
    List<String> listLine = resLrcCtrl.text.split('\n');
    String time, text;
    int end;
    List<LyricModel> models = [];
    for (int i = 0; i < listLine.length; ++i) {
      end = listLine[i].indexOf(']');
      time = listLine[i].substring(0, end + 1); //+1 vi end ko cat kytu cuoi
      text = listLine[i].substring(end + 1).trim();
      models.add(LyricModel(time: time, sentence: text));
    }
    handlePassage(models);
  }

  List<String> listPassage = [];
  handlePassage(List<LyricModel> listResult) {
    // p('listResult', listResult);//T
    listPassage = original.split('\n')
      ..removeWhere(
          (element) => element.isEmpty || !charactor.hasMatch(element))
      ..forEach((element) {
        element = element.trim(); //remove \n thừa//f
      });
    if (listPassage.length < 2) {
      passageModelResult.add(PassageModel(
          time: listResult[0].time, passage: listPassage[0])); // index: 1
      onPassageErr(s: 'Only 1 passage!');
    } else {
      List<LyricModel> clone = List.from(listResult); //to remove done element
      String lrcSentence, firstWordsOfPassage;
      for (int i = 0; i < listPassage.length; ++i) {
        bool isFound = false; //ktao&reset
        for (int j = 0; j < clone.length; ++j) {
          lrcSentence = clone[j].sentence.trim();
          if (lrcSentence.isEmpty) {
            //result đã handle rồi nên empty là ở câu cuối lun chứ ko ở giữa chừng
            onPassageErr(timeLine: clone[j].time);
            // return;
            break;
          }
          if (listPassage[i].length > 100) {
            firstWordsOfPassage =
                listPassage[i].substring(0, 100); //100 ky tu dau
          } else {
            firstWordsOfPassage = listPassage[i];
          }
          // if (listPassage[i].contains(lrcSentence)) {
          if (firstWordsOfPassage.contains(lrcSentence) ||
              (lrcSentence.indexOf(firstWordsOfPassage) == 0)) {
            //lrcSentence it nhat 2 word: lrcResult đã handle
            passageModelResult.add(
                PassageModel(time: clone[j].time, passage: listPassage[i]));
            //lrc remove done part: từ 0->vị trí listTime đó
            clone.removeRange(0, j);
            isFound = true;
            break;
          } else {}
        }
        if (isFound == false) {
          passageModelResult
              .add(PassageModel(time: timeErr, passage: listPassage[i]));
        }
      }
      resPassageCtrl.text = handlePassageRes(passageModelResult);
      // p('resPassageCtrl.text', resPassageCtrl.text);
    }
  }

  String handlePassageRes(List<PassageModel> passageModelResult) {
    String res = '';
    List<String> sameTime = [];
    for (int i = 0; i < passageModelResult.length; ++i) {
      res += passageModelResult[i].toString();
      // if (passageModelResult[i].time == '[00:00:**]') {
      //   onPassageErr(timeLine: passageModelResult[i].time);
      // }
      //check cau trung
      if (i >= 1) {
        if (passageModelResult[i].time == passageModelResult[i - 1].time &&
            !sameTime.contains(passageModelResult[i].time)) {
          onPassageErr(timeLine: passageModelResult[i].time);
          sameTime.add(passageModelResult[i].time);
        }
      }
    }
    if (res.contains(timeErr) && !sameTime.contains(timeErr)) {
      onPassageErr(timeLine: timeErr);
    }
    return res;
  }

  List<String> listSentenceOfLrc = [];
  splitLrcText() {
    listLrcText = textLrcCtrl.text.split(
        '\n') //lrc phải xóa hêt dấu, chỉ còn chữ thì câu trong passage dễ contain hơn (nhiều khi máy tự thêm dấu sai)
      ..removeWhere((element) => element.isEmpty || element == ' ')
      ..forEach((element) {
        element = element.trim();
      });
    for (int i = 0; i < listLrcText.length; ++i) {
      String sentence = listLrcText[i];
//split ra từng từ
      int end = sentence.indexOf(']') + 1;
      String time = sentence.substring(0, end); //[0]=time
      String text = sentence.substring(end).trim(); //bỏ space between time&text
      listModelOfLrc.add(LyricModel(time: time, sentence: text));
    }
  }

  void resLrcWarning(int i) {
    if (i <= -1) {
      i = 0;
    } else if (i >= listModelOfLrcResult.length) {
      i = listModelOfLrcResult.length - 1;
    }
    //phải là leng result vì có mấy cái time có trong listModelOfLrc thì ko có result(đã xóa)
    String timeLine = listModelOfLrcResult[i].time;
    resLrcCtrl.listErr.add(ErrorModel(timeLine: timeLine));
  }

  String resStr = '';

  onTapConvert() {
    reset();
    pretreatmentOri();
    splitLrcText();
    //success
    replaceLrcByOriginal();
    handleLrcResult();
    handlePassage(listModelOfLrcResult);
  }

  handleLrcResult() {
    int flag = 0;
    for (int i = 0; i < listModelOfLrcResult.length; ++i) {
      final e = listModelOfLrcResult[i]; //-1
      if (e.sentence != '' && e.sentence.isNotEmpty) {
        e.sentence = e.sentence.replaceAll(khoangTrangAtFirstAndLast, '');
        resStr += e.toString();
      } else {
        if (flag == 0) {
          resStr +=
              '${e.time} ${oriOfLrc.replaceAll(khoangTrangAtFirstAndLast, '')}';
          flag = 1;
        }
        resLrcErr(i, 'Result chứa câu empty, đã handle');
      }
      resStr += '\n';
    }
    resLrcCtrl.text = resStr;
    if (resStr.isEmpty) {
      resLrcErr(-1, 'Ko có câu nào trùng khơp');
    }
  }

  String err = '';
  String original = '';
  pretreatmentOri() {
    textOriginalCtrl.text = removeExtraSpaces(textOriginalCtrl.text);
    original = textOriginalCtrl.text
        .replaceAll(RegExp(r'[‘’]'), "'"); //để I’m contain I'm
    // .replaceAll(RegExp(r'[“”]'), '"');
  }

  String oriOfLrc = '';
  replaceLrcByOriginal() {
    String sub = '';
    listModelOfLrcResult = [];
    int end;
    //oriOfLrc
    oriOfLrc = original.replaceAll(RegExp(r'\n+'),
        '\n'); //nếu '' thì từ đầu cuối đoạn trc và đầu đoạn sau hợp lại thành 1 từ
    // textOriginalCtrl.text = oriOfLrc;//có lệch xíu cx ko sao (vì index lấy từ oriOfLrc (ko có \n))
    int flag = 0;
    bool isMatch; //true khi notEmpty&match
    for (int i = 0; i < listModelOfLrc.length; ++i) {
      LyricModel model = listModelOfLrc[i];
      if (model.sentence.length >= 2) {
        //cang nhieu word thi do chinh xac cang cao (ko bi trung vs cau khac)
        //but cũng phải ít word để câu sau ko match nữa là merge lại 3 câu trở đi -> quá dài
        //but có 1word thì dễ trùng dẫn đến xac dinh index sai (nếu từ đó trong lrc sai nữa mà vô tình trùng khơp vs ori thì sai hoàn toàn)
        //ưu tiên độ chính xac nên min=3 lỡ merge câu dài quá cx ko sao. thà dài còn hơn sai
        //trim().isNotEmpty
        //thought Alice => nên tach riêng ra nên min=2 là đẹp
        String cau = model.sentence.toLowerCase();
        end = oriOfLrc
            .replaceAll(puncReplaceBySpace, ' ')
            .replaceAll(
                breaklines, ' ') //ori:Chapter 1\nDo..,lrc:Chapter 1 Do..
            .toLowerCase()
            .indexOf(cau);
        // p('end', end);
        if (end > -1) {
          isMatch = true; //reset
          flag = 0; //reset
          //note: tìm thấy rồi thì handle câu empty trc trc khi removeDone
          if (i >= 1) {
            int pre = listModelOfLrcResult
                .lastIndexWhere((element) => element.sentence == '');
            //listRes <= listModel nên pre lun <= i
            if (pre > -1) {
              //tìm thấy empty
              if (listModelOfLrcResult[pre].sentence == '' ||
                  listModelOfLrcResult[pre].sentence.isEmpty) {
                end = handleEndIndex(end - 1, oriOfLrc);
                sub = oriOfLrc.substring(0, end); //0->đầu câu sau
                //-1:lùi lại 1 dấu (nháy...) để nó ko lấy dấu mở của câu sau
                listModelOfLrcResult[pre].sentence = sub;
                // if (sub.contains('\n')) {
                //   passageModelResult2
                //       .add(PassageModel(time: listModelOfLrcResult[pre].time));
                // }
                oriOfLrc = oriOfLrc.removeDoneString(end);
                int startOfHighlight = textOriginalCtrl.text.indexOf(sub);
                if (startOfHighlight != -1) {
                  onHighlightOri(SentenceHighlight(
                      start: startOfHighlight,
                      end: startOfHighlight + sub.length));
                }
              }
            }
          }
          end = oriOfLrc.toLowerCase().indexOf(cau) + model.sentence.length;
          end = handleEndIndex(end, oriOfLrc); //+1 nó lấy ký tự đầu của câu sau
          //index = cuối câu thì căt nó ko lấy ký tự cuối nên phải +1
          String text = oriOfLrc.substring(0, end);
          oriOfLrc = oriOfLrc.removeDoneString(end);
          sub = text;
          int demPunc = countPunc(oriOfLrc);
          if (demPunc > 0) {
            String punc = oriOfLrc.substring(0, demPunc);
            sub += punc;
            oriOfLrc = oriOfLrc.removeDoneString(demPunc); //remove punc
          }
          listModelOfLrcResult.add(LyricModel(time: model.time, sentence: sub));
          // if (sub.contains('\n')) {
          //   passageModelResult2.add(PassageModel(time: model.time));
          // }
        } else {
          isMatch = false;
        }
      } else {
        isMatch = false;
      }
      //sentence empty|| sentence = ''
      if (!isMatch) {
        if (flag == 0) {
          LyricModel? model2;
          if (i == listModelOfLrc.length - 1) {
            //cau cuoi ko co cau sau
            model2 = LyricModel(time: model.time, sentence: oriOfLrc);
            // p('model2 cua cau cuoi',
            //     model2); //chỉ câu cuối not match (mấy câu trc ko emp) ms nhảy dô đây
            resLrcErr(i, 'Câu cuối not match, đã handle');
          } else {
            model2 = LyricModel(time: model.time, sentence: '');
          }
          //not match vẫn add để lấy time rồi hồi match thì handle sentence của những câu trc
          listModelOfLrcResult.add(model2);
          flag = 1; //khi match roi thi reset=0
          resLrcWarning(i); //not match lần đầu
        } else {
          //nhữn câu empty sau thì do nothing
          onLrcErr(i); // '>=2 câu liên tục ko match, đã merge'
          //do này ko add vào result nên phải lấy time trong listModelOfLrc
        }
      }
    }
  }

  bool isRemoveBreakline = true;
  removeBreaklineOfPassage() {
    if (isRemoveBreakline) {
      resPassageCtrl.text =
          resPassageCtrl.text.replaceAll(RegExp(r'\n+'), '\n');
    } else {
      resPassageCtrl.text = resPassageCtrl.text.replaceAll('\n', '\n\n');
    }
    isRemoveBreakline = !isRemoveBreakline;
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    for (int i = 0; i < ori.length; ++i) {
      if (ori[i] == ' ' || ori[i] == '\n') {
        //charactor.hasMatch(ori[i]) ||
        break;
      } else if (i < ori.length - 1 &&
          puncNoSpace.hasMatch(ori[i]) && //-—
          charactor.hasMatch(ori[i + 1])) {
        //..now-but I .. =>break at 'b'
        ++dem;
        break;
      }
      ++dem;
    }
    // p('dem', dem);
    return dem;
  }

  onHighlightOri(SentenceHighlight model) {
    textOriginalCtrl.listIndex.add(model);
  }

  void reset() {
    oriOfLrc = '';
    listModelOfLrc = [];
    listModelOfLrcResult = [];
    listSentenceNoTime = [];
    listLrcText = [];
    listTime = [];
    listLrcWord = [];
    resStr = '';
    err = '';
    passage = [];
    passageModelResult = [];
    resLrcCtrl.clear();
    resLrcCtrl.listErr = [];
    textLrcCtrl.listErr = [];
    resPassageCtrl.listErr = [];
    textOriginalCtrl.listIndex = [];
    isRemoveBreakline = true;
  }

  resLrcErr(int i, String text) {
    err += text;
    if (i > -1 && i < listModelOfLrcResult.length) {
      String timeLine = listModelOfLrcResult[i].time;
      resLrcCtrl.listErr
          .add(ErrorModel(type: TypeErr.error, timeLine: timeLine));
      //i=-1 là ko hiện index,chỉ hiện text
      err += ' (at $timeLine)';
    }
    err += '\n';
  }

  void onPassageErr(
      {int i = -1, int indexOfPassage = -1, String? s, String? timeLine}) {
    if (s != null) {
      err += s;
    }
    // err += ' At PASSAGE $indexOfPassage:';
    if (timeLine != null) {
      resPassageCtrl.listErr
          .add(ErrorModel(type: TypeErr.error, timeLine: timeLine));
    }
    if (i > -1) {
      err +=
          'Thiếu passage $i:${passage[i].sentences.first}..${passage[i].sentences.last}';
    }
    err += '\n';
  }

  void onLrcErr(int i) {
    if (i < listModelOfLrc.length) {
      String timeLine = listModelOfLrc[i].time;
      textLrcCtrl.listErr
          .add(ErrorModel(type: TypeErr.error, timeLine: timeLine));
      //i=-1 là ko hiện index,chỉ hiện text
      // err += 'At $timeLine: $s\n';
    }
  }
}
