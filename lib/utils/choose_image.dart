import 'package:image_picker/image_picker.dart';

// Choose Image Sourcec from Gallery / Camera
chooseImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source, imageQuality: 10);
  if (file != null) {
    return await file.readAsBytes();
  }
}