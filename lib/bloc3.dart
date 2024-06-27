import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/custom_textfield/custom_lrc_textfield.dart';
import 'package:web_sync_lyrix/custom_textfield/custom_ori_textfield.dart';
import 'package:web_sync_lyrix/custom_textfield/custom_textfield.dart';
import 'package:web_sync_lyrix/model/err_model.dart';
import 'package:web_sync_lyrix/extension.dart';
import 'package:web_sync_lyrix/model/model.dart';
import 'package:web_sync_lyrix/passage_model.dart';

class Lyric {
  List<LyricModel> listModelOfLrcResult = []; //result
  List<LyricModel> listModelOfLrc = []; //result
  final textLrcCtrl = CustomLrcTextField();
  final textOriginalCtrl = CustomOriTextField();
  final resLrcCtrl = CustomTextEditCtrl();
  final passageResCtrl = TextEditingController();
  // final passageResCtrl2 = TextEditingController();
  List<String> listLrcText = [], listTime = []; //each row//listOriginalText,
  List<List<String>> listLrcWord = [], listSentenceNoTime = [];
  List<OnePassage> passage = [];
  List<PassageModel> passageModelResult = []; //result
  // List<PassageModel> passageModelResult2 = []; //result
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
    // reconvertResPassage2(models);
  }

  List<String> listPassage = [];
  handlePassage(List<LyricModel> listResult) {
    listPassage = original.split('\n')
      ..removeWhere((element) => element.isEmpty)
      ..forEach((element) {
        element = element.trim(); //remove \n thừa//f
      });
    // p('listPassage', listPassage);
    if (listPassage.length < 2) {
      //passage
      passageModelResult.add(PassageModel(
          time: '[00:00:00]', passage: listPassage[0])); // index: 1
      onPassageErr(s: 'Only 1 passage!');
    } else {
      List<LyricModel> clone = List.from(listResult);
      String lrcSentence;
      for (int i = 0; i < listPassage.length; ++i) {
        //passage
        for (int j = 0; j < clone.length; ++j) {
          lrcSentence = clone[j].sentence.trim();
          if (listPassage[i].contains(lrcSentence)) {
            passageModelResult.add(
                PassageModel(time: clone[j].time, passage: listPassage[i]));
            //lrc remove done part: từ 0->vị trí listTime đó
            clone.removeRange(0, j);
            break;
          } else {}
        }
      }
      passageResCtrl.text = hanleResPassage(passageModelResult);
      // handleResPassage2(passageModelResult2);
    }
  }

  String hanleResPassage(List<PassageModel> passageModelResult) {
    String res = '';
    for (PassageModel model in passageModelResult) {
      res += model.toString();
    }
    return res;
  }

  List<String> listSentenceOfLrc = [];
  splitLrcText() {
    listLrcText = textLrcCtrl.text.split(
        '\n') //lrc phải xóa hêt dấu, chỉ còn chữ thì câu trong passage dễ contain hơn (nhiều khi máy tự thêm dấu sai)
      ..removeWhere((element) => element.isEmpty)
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

  void onWarning(int i) {
    //phải là leng result vì có mấy cái time có trong listModelOfLrc thì ko có result(đã xóa)
    if (i < listModelOfLrcResult.length) {
      String timeLine = listModelOfLrcResult[i].time;
      resLrcCtrl.listErr.add(ErrorModel(timeLine: timeLine));
    }
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
      if (e.sentence != '') {
        resStr += e.toString().replaceAll(kyTuKhoangTrangO2Dau, '');
      } else {
        if (flag == 0) {
          resStr +=
              '${e.time} ${oriOfLrc.replaceAll(kyTuKhoangTrangO2Dau, '')}';
          flag = 1;
        }
        onErr(i, 'Result chứa câu empty, đã handle');
      }
      resStr += '\n';
    }
    resLrcCtrl.text = resStr;
    if (resStr.isEmpty) {
      onErr(-1, 'Ko có câu nào trùng khơp');
    }
  }

  String err = '';
  String original = '';
  pretreatmentOri() {
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
        end = oriOfLrc.toLowerCase().indexOf(cau); //replaceAll(dauNgatCau, '').
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
          int demPunc = countPunc(oriOfLrc); //kyTuConThieu&punc
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
            onErr(i, 'Câu cuối not match, đã handle');
          } else {
            model2 = LyricModel(time: model.time, sentence: '');
          }
          //not match vẫn add để lấy time rồi hồi match thì handle sentence của những câu trc
          listModelOfLrcResult.add(model2);
          flag = 1; //khi match roi thi reset=0
          onWarning(i); //not match lần đầu
        } else {
          //nhữn câu empty sau thì do nothing
          onLrcErr(i); // '>=2 câu liên tục ko match, đã merge'
          //do này ko add vào result nên phải lấy time trong listModelOfLrc
        }
      }
    }
  }

  int countPunc(String ori) {
    //ori lấy từ word đó trở về sau (ko lấy word)
    //đếm số dấu ngay sau word
    int dem = 0;
    for (int i = 0; i < ori.length; ++i) {
      if (ori[i] == ' ' || ori[i] == '\n') {
        break;
      }
      ++dem;
    }
    return dem;
  }

  onErr(int i, String text) {
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
    // passageModelResult2 = [];
    resLrcCtrl.clear();
    resLrcCtrl.listErr = [];
    textLrcCtrl.listErr = [];
    textOriginalCtrl.listIndex = [];
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
  // reconvertResPassage2(List<LyricModel> lrcResult) {
  //   String res = '${lrcResult[0].time} ${listPassage[0]}}\n\n';
  //   List<String> times = [];
  //   for (int i = 0; i < lrcResult.length; ++i) {
  //     //empty err
  //     // result[i].passage = listPassage[i];
  //     if (lrcResult[i].sentence.contains('\n')) {
  //       times.add(lrcResult[i].time);
  //     }
  //   }
  //   for (int i = 0; i < times.length; ++i) {
  //     res += '${times[i]} ${listPassage[i + 1]}\n\n';
  //   }
  //   passageResCtrl2.text = res;
  // }

    // handleResPassage2(List<PassageModel> resultOnlyTime) {
  //   resultOnlyTime.insert(
  //       0,
  //       PassageModel(
  //           time: listModelOfLrcResult[0].time, passage: listPassage[0]));
  //   String res = resultOnlyTime[0].toString();
  //   for (int i = 1; i < resultOnlyTime.length; ++i) {
  //     resultOnlyTime[i].passage = listPassage[i];
  //     res += resultOnlyTime[i].toString();
  //   }
  //   passageResCtrl2.text = res;
  // }