import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Writes a small test document to `test/ping`.
  static Future<void> writeTestDoc() async {
    await _db.collection('test').doc('ping').set({
      'message': 'hello from app',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reads the test document at `test/ping` and returns its data.
  static Future<Map<String, dynamic>?> readTestDoc() async {
    final doc = await _db.collection('test').doc('ping').get();
    return doc.exists ? doc.data() : null;
  }
}
