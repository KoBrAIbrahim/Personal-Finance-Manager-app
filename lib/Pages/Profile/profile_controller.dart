import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> pickAndUploadProfileImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final file = File(pickedFile.path);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  final storageRef = FirebaseStorage.instance
      .ref()
      .child('profile_images')
      .child('${user.email}.jpg');

  final uploadTask = await storageRef.putFile(file);

  final downloadUrl = await uploadTask.ref.getDownloadURL();
  return downloadUrl;
}
