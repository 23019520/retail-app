import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  /// Upload a file and return its download URL.
  /// [path] is the storage folder path, e.g. 'products/abc123'
  Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final filename = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('$path/$filename');

      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await task.ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  /// Delete a file by its full download URL.
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // File may already be deleted — fail silently
    }
  }
}
