import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePicture(String uid, String imagePath) async {
    final ref = _storage.ref().child('profile_pictures').child('$uid.jpg');
    final uploadTask = ref.putFile(File(imagePath));
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }
}