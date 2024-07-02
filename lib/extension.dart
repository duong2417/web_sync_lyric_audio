// RegExp puncReg = RegExp(r'["?!.,:;_-_—(){}]'); //punc '
// RegExp dauNgatCau = RegExp(r'[,_-_—;:]'); //punc '//good-bye//
RegExp puncReplaceBySpace =
    RegExp(r'[_-_—-]'); //good-bye => good bye, and -but.. =>and  but
RegExp dauNgatCauNeedRemove = RegExp(r'[,:]');
RegExp closePunc = RegExp("[\"”’,:;-_)}—]");//'.?! VD: ..I'am!"
// RegExp charactor = RegExp(r'[a-z]');
// RegExp charactor = RegExp(r'^[A-Z][a-z]$');
// RegExp openPunc = RegExp(r'[“(‘{]'); //punc
// RegExp kyTuKhoangTrangO2Dau = RegExp(r'^[\r\n\t]+|[\r\n\t]+$');
RegExp kyTuKhoangTrangO2Dau = RegExp(r'^\s+|\s+$');
// bool containPunc(String str) {
//   return str.contains(punc);
// }
const String timeErr = '[00:00:**]';
int handleEndIndex(int end, String original) =>
    end < original.length ? (end > -1 ? end : 0) : original.length - 1;

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start); //.trim();
  }

  int myIndexOf(String s) {
    for (int i = 0; i < length; ++i) {
// if (this[i].contains(pun))
    }
    return 0;
  }

  // bool containExcludePunc(String text) {
  //   String textNoPunc = this.replaceAll(punc, '');
  //   return true;
  // }
}
