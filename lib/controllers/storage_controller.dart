import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class StorageController {
  // Upload Image to Firebase Storage
  Future<String> uploadImageToStorage(String folder, String name, Uint8List file) async {
    Reference ref = _storage.ref().child(folder).child(name.toLowerCase());
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
    UploadTask uploadTask = ref.putData(file, metadata);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Delete Image to Firebase Storage
  Future<void> deleteImage(String folder, String name) async {
    Reference ref = _storage.ref().child(folder).child(name.toLowerCase());
    try {
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}