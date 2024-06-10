import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  String? directory = await FilePicker.platform.getDirectoryPath();

  if (directory != null) {
    final File file = File('$directory/$fileName');
    if (file.existsSync()) {
      await file.delete();
    }
    await file.writeAsBytes(bytes);
  }
}
