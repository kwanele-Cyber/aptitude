import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  Future<void> sendMessage(String chatId, Message message) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  Future<void> sendImage(String chatId, String senderId, String receiverId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    final file = File(result.files.single.path!);
    final ref = _storage
        .ref()
        .child('chat_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final message = Message(
      senderId: senderId,
      receiverId: receiverId,
      text: '',
      timestamp: DateTime.now(),
      imageUrl: url,
    );
    await sendMessage(chatId, message);
  }

  Future<void> sendFile(String chatId, String senderId, String receiverId) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final file = File(result.files.single.path!);
    final ref = _storage
        .ref()
        .child('chat_files')
        .child('${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final message = Message(
      senderId: senderId,
      receiverId: receiverId,
      text: '',
      timestamp: DateTime.now(),
      fileUrl: url,
    );
    await sendMessage(chatId, message);
  }
}
