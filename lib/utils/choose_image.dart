import 'package:image_picker/image_picker.dart';

// Choose Image Sourcec from Gallery / Camera
chooseImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
}