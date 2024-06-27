class PassageModel {
  PassageModel({
    required this.time,
    this.passage,
  }); //this.index
  String time;
  String? passage;
  // int? index;
  @override
  String toString() {
    return '${convertTime(time)} $passage\n\n'; //$index\n
  }
}

class OnePassage {
  OnePassage({required this.passage, required this.sentences});
  String passage;
  List<String> sentences;
  @override
  String toString() {
    return '$sentences';
  }
}

//[00:00.000]->[00:00:00]
RegExp formatTime = RegExp(r'^\[\d{2}:\d{2}\.\d{3}\]$'); //[00:00.000]
String convertTime(String time) {
  if (formatTime.hasMatch(time)) {
    time = time.replaceFirst('.000', ''); //[00:00]
    time = time.substring(1); //00:00]
    time = '[00:$time';
  }
  // p('time', time);
  return time;
}
