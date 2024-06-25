RegExp puncReg = RegExp(r'["?!.,:;-_—(){}]'); //punc '
RegExp dauNgatCau = RegExp(r'[,]'); //punc '//good-bye//-_—
RegExp closePunc = RegExp("[\"”'’?!.,:;-_)}—]"); //punc
RegExp charactor =RegExp(r'[A-Z][a-z]'); //punc
// RegExp openPunc = RegExp(r'[“(‘{]'); //punc
// bool containPunc(String str) {
//   return str.contains(punc);
// }

int handleEndIndex(int end, String original) =>
    end < original.length ? (end > -1 ? end : 0) : original.length - 1;

extension StringExtension on String {
  String removeDoneString(int start) {
    return substring(start);//.trim();
  }
}
