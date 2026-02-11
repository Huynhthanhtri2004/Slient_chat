import 'package:slient_chat/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:slient_chat/services/chat/chat_service.dart';
import '../components/user_tile.dart';
import '../services/auth/auth_service.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer:const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users except current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot){
          // error
          if (snapshot.hasError) {
            return const Text("Error");
          }

          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          // return listview
          return ListView(
            children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
          );
        }
    );
  }

   // build individual list tile for user (có preview tin nhắn cuối)
   Widget _buildUserListItem(
       Map<String, dynamic> userData,
       BuildContext context,
       ) {
     final currentUser = _authService.getCurrentUser()!;
     if (userData["email"] == currentUser.email) {
       return const SizedBox.shrink();
     }
     final otherUid = userData["uid"] as String;
     final List<String> ids = [currentUser.uid, otherUid];
     ids.sort();
     final chatRoomId = ids.join('_');

     return StreamBuilder<Map<String, dynamic>?>(
       stream: _chatService.getLastMessageStream(chatRoomId),
       builder: (context, msgSnapshot) {
         String? subtitle;
         if (msgSnapshot.hasData && msgSnapshot.data != null) {
           final data = msgSnapshot.data!;
           final message = data['message'] as String?;
           if (message != null && message.isNotEmpty) {
             final isFromMe = data['senderID'] == currentUser.uid;
             subtitle = isFromMe ? 'Bạn: $message' : message;
           }
         }
         return UserTile(
           text: userData["email"] as String,
           subtitle: subtitle,
           onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => ChatPage(
                   receiverEmail: userData["email"] as String,
                   receiverID: otherUid,
                 ),
               ),
             );
           },
         );
       },
     );
   }
}
