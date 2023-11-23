import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Storage {
  static Future<String?> uploadImage(File image , int id) async {
  try {
    // Get a reference to the storage service
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;

    // Create a reference to the location you want to upload the image
    String imgName = '$id.jpg';
    firebase_storage.Reference ref =
        storage.ref().child('images').child(imgName);

    // Upload the file to the specified path
    await ref.putFile(image);

    // Get the download URL for the image
    String downloadURL = await ref.getDownloadURL();
    
    return downloadURL;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}
}