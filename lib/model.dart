class LyricModel {
  LyricModel({required this.time, required this.sentence, this.index});
  String time, sentence;
  int? index;
  @override
  String toString() {
    return '$time $sentence';
  }
}
