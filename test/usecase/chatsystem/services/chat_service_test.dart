import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/usecase/chatsystem/models/message_model.dart';
import 'package:myapp/usecase/chatsystem/services/chat_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

void main() {
  late ChatService chatService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    chatService = ChatService(firestore: mockFirestore);
  });

  group('ChatService', () {
    test('sendMessage adds message to Firestore', () async {
      final message = Message(
        senderId: '1',
        receiverId: '2',
        text: 'hello',
        timestamp: DateTime.now(),
      );

      when(() => mockFirestore.collection(any())).thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(any())).thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.collection(any())).thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.add(any())).thenAnswer((_) async => mockDocumentReference);

      await chatService.sendMessage(message, 'chat_123');

      verify(() => mockFirestore.collection('chats')).called(1);
      verify(() => mockCollectionReference.doc('chat_123')).called(1);
      verify(() => mockCollectionReference.add(message.toMap())).called(1);
    });
  });
}
