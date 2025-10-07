import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:prime_health_patients/utils/toaster.dart';

class Helper {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({ImageSource? source}) async {
    try {
      final XFile? file = await _picker.pickImage(source: source ?? ImageSource.camera);
      if (file != null) {
        return File(file.path);
      }
      return null;
    } catch (err) {
      toaster.error("Error while clicking image!");
      return null;
    }
  }
}

Helper helper = Helper();
