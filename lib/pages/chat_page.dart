import 'package:flutter/material.dart';
import 'package:slient_chat/components/chat_bubble.dart';
import 'package:slient_chat/services/auth/auth_service.dart';
import 'package:slient_chat/services/chat/chat_service.dart';
import '../components/my_textfield.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  //chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => scrollDown(),
        ); // Future.delayed
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
          () => scrollDown(),
    );

  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

// scroll controller
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // send message function
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );

      // clear textfield
      _messageController.clear();
    }

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

// build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    List<String> ids = [senderID, widget.receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, chatRoomId))
              .toList(),
        );
      },
    );
  }

  // build individual message item
  Widget _buildMessageItem(doc, String chatRoomId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String messageId = doc.id;
    String currentUserId = _authService.getCurrentUser()!.uid;

    bool isCurrentUser = data['senderID'] == currentUserId;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final reactions = data['reactions'] as Map<String, dynamic>?;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data['message'],
            isCurrentUser: isCurrentUser,
            messageId: messageId,
            chatRoomId: chatRoomId,
            currentUserId: currentUserId,
            reactions: reactions,
            onReaction: (msgId, emoji) {
              _chatService.toggleReaction(chatRoomId, msgId, emoji);
            },
          ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // textfield should take up most of the space
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false,
              focusNode: myFocusNode
            ),
          ),

          // send button
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward,
              color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
