class LyricModel {
  LyricModel({
    required this.time,
    this.sentence = '',
  }); //this.index
  String time;
  String sentence;
  // int? index;
  @override
  String toString() {
    return '$time ${sentence.replaceAll(RegExp(r'^\n+|\n+$'), '')}';
  }
}
