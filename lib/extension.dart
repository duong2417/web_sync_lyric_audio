// RegExp puncReg = RegExp(r'["?!.,:;-_—(){}]'); //punc '
RegExp dauNgatCau = RegExp(r'[,-_—;:]'); //punc '//good-bye//
// RegExp closePunc = RegExp("[\"”'’?!.,:;-_)}—]"); //punc
// RegExp charactor =RegExp(r'[A-Z][a-z]'); //punc
// RegExp openPunc = RegExp(r'[“(‘{]'); //punc
// RegExp kyTuKhoangTrangO2Dau = RegExp(r'^[\r\n\t]+|[\r\n\t]+$');
RegExp kyTuKhoangTrangO2Dau = RegExp(r'^\s+|\s+$');
// bool containPunc(String str) {
//   return str.contains(punc);
// }

int handleEndIndex(int end, String original) =>
    end < original.length ? (end > -1 ? end : 0) : original.length - 1;

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start); //.trim();
  }

  // bool containExcludePunc(String text) {
  //   String textNoPunc = this.replaceAll(punc, '');
  //   return true;
  // }
}
