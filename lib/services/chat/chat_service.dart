import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slient_chat/models/message.dart';

class ChatService {

  // get instance of firestore and auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  /*
  List<Map<String, dynamic>> =
  [
    {
      'email': test@gmail.com,
      'id': ...
    },
    {
      'email': tri@gmail.com,
      'id': ...
    },
  ]
  */

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
       // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

// send message
Future<void> sendMessage(String receiverID, String message) async {

    // get current user id
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // create message map
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    // add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
}
  /// Stream tin nhắn mới nhất trong phòng chat (để hiện preview dưới tên user trên Home).
  Stream<Map<String, dynamic>?> getLastMessageStream(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return snapshot.docs.first.data();
        });
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Bật/tắt reaction (thả cảm xúc) cho tin nhắn.
  /// Nếu user đã thả emoji này thì gỡ, chưa thì thêm.
  Future<void> toggleReaction(
    String chatRoomId,
    String messageId,
    String emoji,
  ) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final data = doc.data()!;
    final reactions = data['reactions'] as Map<String, dynamic>?;
    final list = reactions?[emoji];
    final List<dynamic> uidList = list is List ? list : [];
    final hasReacted = uidList.contains(uid);

    if (hasReacted) {
      await docRef.update({
        'reactions.$emoji': FieldValue.arrayRemove([uid]),
      });
    } else {
      await docRef.update({
        'reactions.$emoji': FieldValue.arrayUnion([uid]),
      });
    }
  }
}