import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class StorageController {
  Future<String> uploadImageToStorage(String folder, String name, Uint8List file) async {
    Reference ref = _storage.ref().child(folder).child('$name.jpg');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
