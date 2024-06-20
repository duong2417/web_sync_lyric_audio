import 'package:flutter/material.dart';
import 'package:web_sync_lyrix/base_bloc.dart';
import 'package:web_sync_lyrix/print.dart';

class Passage extends BaseBloc {
  final passageTextCtrl = TextEditingController();
  String result = '';
  // List<String> listTimeOfPassage = [];
  List<List<String>> passages = [];
  splitOriToPassage(String ori) {
    RegExp regex = RegExp(r'[!.,:;?]');
    List list = ori.split('\n');
    for (int i = 0; i < list.length; ++i) {
      list[i] = list[i].split(regex);
    }
    passages = list as List<List<String>>;
    //[[oh,I have dog],[now, we are talking]]
  }

  findMatch() {
    //List<String> listNoTime, List<String> sentence
    //last sentence of passage=cố định
    for (int a = 0; a < passages.length; ++a) {
      List<String> sentences = passages[a];
      int flag = 0;
      for (int i = sentences.length - 1; i >= 0; --i) {
        for (int j = 0; j < listNoTime.length; ++j) {
          if (listNoTime[j].isEqualSentence(sentences[i])) {
            // listTimeOfPassage.add(listTime[i]);
            // result = '$result${listTimeOfPassage![i]}\n${passages[a]}\n';
            //remove done part of
            // p('listTimeOfPassage', listTimeOfPassage);
            listNoTime.removeRange(0, j);
            p('listNoTime remove range', listNoTime);
            flag = 1;
            break;
          }
        }
        if (flag == 1) break;
      }
    }
    passageTextCtrl.text = result;
  }
}

extension StringExtension on String {
  bool isEqualSentence(String otherSentence) {
    RegExp regex = RegExp(r'[!.,:;? ]');
    return replaceAll(regex, '') == otherSentence.replaceAll(regex, '');
  }
}
