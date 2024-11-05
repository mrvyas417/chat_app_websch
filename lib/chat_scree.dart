import 'package:flutter/material.dart';
import 'model/chat_message_model.dart';

import 'service/database_service.dart';
import 'service/messge_service.dart'; // Import the DatabaseService

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late MessageService messageService;
  TextEditingController msgController = TextEditingController();

  // Database helper instance
  final DatabaseService _databaseHelper = DatabaseService();

  @override
  void initState() {
    super.initState();
    messageService = MessageService(
      onMessageReceived: (msg) {
        setState(() {
          // Prevent adding the same message again
          if (!messageService.msgList.any((message) =>
              message.msgtext == msg.msgtext && message.userid == msg.userid)) {
            messageService.msgList.add(msg);
          }
        });
      },
    );

    // Load messages from the database
    _loadMessages();

    messageService.connect();
  }

  Future<void> _loadMessages() async {
    // Load messages from the database and add them to msgList
    List<MessageData> messages = await _databaseHelper.getMessages();
    setState(() {
      messageService.msgList = messages; // Assign loaded messages to msgList
    });

    // Notify the UI about loaded messages
    for (var message in messages) {
      // You can choose to notify or handle them as you need
      messageService.onMessageReceived(message);
    }
  }

  @override
  void dispose() {
    msgController.dispose();
    messageService.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (msgController.text.isNotEmpty) {
      final sentMessage = MessageData(
        msgtext: msgController.text,
        userid: messageService.myId,
        isme: true,
      );

      setState(() {
        // Check for duplicates before adding
        if (!messageService.msgList.any((message) =>
            message.msgtext == sentMessage.msgtext &&
            message.userid == sentMessage.userid)) {
          messageService.msgList.add(sentMessage);
        }
      });

      messageService.sendMessage(msgController.text, messageService.receiverId);
      _databaseHelper
          .insertMessage(sentMessage); // Save the sent message to the database
      msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(receiverId: messageService.myId),
        actions: const [AppBarActions()],
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(msgList: messageService.msgList),
          ),
          MessageInput(
            controller: msgController,
            onSend: _sendMessage,
            onCameraPressed: () => print("Camera pressed"),
            onGalleryPressed: () => print("Gallery pressed"),
          ),
        ],
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  final String receiverId;

  const AppBarTitle({super.key, required this.receiverId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(receiverId),
      ],
    );
  }
}

class AppBarActions extends StatelessWidget {
  const AppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.video_call),
          onPressed: () => print("Video call pressed"),
        ),
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () => print("Audio call pressed"),
        ),
      ],
    );
  }
}

class MessageList extends StatelessWidget {
  final List<MessageData> msgList;

  const MessageList({super.key, required this.msgList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: msgList.length,
      itemBuilder: (context, index) {
        final message = msgList[index];
        return Align(
          alignment:
              message.isme ? Alignment.centerRight : Alignment.centerLeft,
          child: MessageCard(message: message),
        );
      },
    );
  }
}

class MessageCard extends StatelessWidget {
  final MessageData message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: message.isme ? Colors.blue[100] : Colors.red[100],
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.isme ? "Me" : message.userid,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(message.msgtext),
            // Optionally add a timestamp here
            // Text(message.timestamp.toString()), // Uncomment if timestamp is part of MessageData
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.file_copy),
            onPressed: onCameraPressed,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: onCameraPressed,
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: onGalleryPressed,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter your message",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
