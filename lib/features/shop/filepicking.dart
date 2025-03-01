import 'package:file_picker/file_picker.dart';

void _pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    PlatformFile file = result.files.first;
    // Handle the file (e.g., upload or process it)
    print("File picked: ${file.name}");
  } else {
    // User canceled the picker
    print("No file selected");
  }
}