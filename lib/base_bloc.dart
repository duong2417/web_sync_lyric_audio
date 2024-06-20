class BaseBloc {
  // BaseBloc._internal();
  // static final BaseBloc _instance = BaseBloc._internal();
  // factory BaseBloc() => _instance; //khi ktao class thì nó gọi instance này
  // late final List<String>? listTimeOfPassage;//LateInitializationError: Field 'listTimeOfPassage' has already been initialized.

  String oriText = '';
  List<String> listNoTime = [];
  // List<String> sentences = [];
}
