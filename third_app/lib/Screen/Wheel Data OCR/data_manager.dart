class DataManager {
  Map<String, String> trainData;
  Map<String, String> appData;
  static bool afterCut = false; //true: yes after cut,false: no after cut

  // Initialize trainData and appData in the constructor
  DataManager._privateConstructor() : trainData = {}, appData = {};

  static final DataManager _instance = DataManager._privateConstructor();

  factory DataManager() {
    return _instance;
  }
}