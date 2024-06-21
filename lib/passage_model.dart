class PassageModel {
  PassageModel({required this.time, required this.passage, this.index});
  String time, passage;
  int? index;
  @override
  String toString() {
    return '$index\n$time\n$passage';
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
