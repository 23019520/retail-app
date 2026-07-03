import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  /// Upload a file and return its download URL.
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

  /// Upload a product image and return its download URL.
  Future<String?> uploadProductImage({
    required String productId,
    required File file,
  }) =>
      uploadFile(file: file, path: 'products/$productId');

  /// Upload a business logo and return its download URL.
  Future<String?> uploadBusinessLogo({
    required String businessId,
    required File file,
  }) =>
      uploadFile(file: file, path: 'businesses/$businessId');

  /// Delete a file by its full download URL.
  Future<void> deleteFile(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } catch (_) {}
  }
}