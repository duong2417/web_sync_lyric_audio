// RegExp puncReg = RegExp(r'["?!.,:;_-_—(){}]'); //punc '
// RegExp dauNgatCau = RegExp(r'[,_-_—;:]'); //punc '//good-bye//
RegExp puncReplaceBySpace =
    RegExp(r'[_-_—-]'); //good-bye => good bye, and -but.. =>and  but
RegExp breaklines = RegExp('\n+');
RegExp dauNgatCauNeedRemove = RegExp(r'[,:]');
RegExp puncNoSpace =
    RegExp(r"[-—]"); //'.?! VD: ..I'am!" _,:;"”’)}//sau punc nay ko co space
RegExp charactor = RegExp(r"[a-zA-Z]");
// RegExp charactor = RegExp(r'^[A-Z][a-z]$');
// RegExp openPunc = RegExp(r'[“(‘{]'); //punc
// RegExp kyTuKhoangTrangO2Dau = RegExp(r'^[\r\n\t]+|[\r\n\t]+$');
RegExp khoangTrangAtFirstAndLast = RegExp(r'^\s+|\s+$');//include \n
// RegExp kyTuKhoangTrangO2Dau = RegExp(r'^\s+|\s+$');//f
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

  // bool containExcludePunc(String text) {
  //   String textNoPunc = this.replaceAll(punc, '');
  //   return true;
  // }
}

String removeExtraSpaces(String text) {
  // Sử dụng biểu thức chính quy để thay thế nhiều dấu cách bằng một dấu cách
  return text.replaceAll(RegExp(r' +'), ' ');
}
