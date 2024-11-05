import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import '../model/chat_message_model.dart';
import 'database_service.dart';

class MessageService {
  late IOWebSocketChannel _channel;
  bool isConnected = false;

  final String myId = "Shubham"; // Your user ID
  final String receiverId = "Nikita"; // Receiver's ID
  // final String myId = "Nikita"; // Your user ID
  // final String receiverId = "Shubham"; // Receiver's ID
  final String authKey = "addauthkeyifrequired"; // Authentication key

  List<MessageData> msgList = [];
  final Function(MessageData) onMessageReceived;

  // Database helper instance
  final DatabaseService _databaseHelper = DatabaseService();

  MessageService({required this.onMessageReceived}) {
    _loadMessages(); // Load messages from the database during initialization
  }

  Future<void> _loadMessages() async {
    // Load messages from the database and add them to msgList
    List<MessageData> messages = await _databaseHelper.getMessages();
    msgList = messages;

    // Notify the UI about loaded messages
    for (var message in messages) {
      onMessageReceived(message);
    }
  }

  void connect() {
    try {
      _channel = IOWebSocketChannel.connect("ws://20.244.29.35:6060/$myId");
      _channel.stream.listen(
        (message) {
          if (message == "connected") {
            isConnected = true;
            if (kDebugMode) print("Connection established.");
          } else if (message.startsWith("{")) {
            var jsonData = json.decode(message);
            // Create message only if data is valid
            MessageData messageData = MessageData.fromJson(jsonData);
            if (messageData.msgtext.isNotEmpty) {
              // Add only if it doesn't already exist in the list
              if (!msgList.any((msg) =>
                  msg.msgtext == messageData.msgtext &&
                  msg.userid == messageData.userid)) {
                msgList.add(messageData);
                onMessageReceived(messageData);
                // Save the received message to the database
                _databaseHelper.insertMessage(messageData);
              } else {
                if (kDebugMode) print("Duplicate message received.");
              }
            } else {
              if (kDebugMode) print("Received empty message.");
            }
          }
        },
        onDone: () {
          isConnected = false;
          if (kDebugMode) print("WebSocket closed");
        },
        onError: (error) {
          if (kDebugMode) print("WebSocket error: $error");
          isConnected = false;
        },
      );
    } catch (e) {
      if (kDebugMode) print("Error connecting to WebSocket: $e");
    }
  }

  void sendMessage(String text, String recipientId) {
    if (text.isEmpty) {
      if (kDebugMode) print("Cannot send empty message.");
      return; // Prevent sending empty messages
    }

    if (isConnected) {
      String message =
          '{"auth":"$authKey","cmd":"send","userid":"$recipientId","msgtext":"$text"}';

      // Check for duplicates before adding to msgList
      if (!msgList.any((msg) => msg.msgtext == text && msg.userid == myId)) {
        MessageData sentMessage =
            MessageData(msgtext: text, userid: myId, isme: true);
        msgList.add(sentMessage);
        onMessageReceived(sentMessage);
        // Save the sent message to the database
        _databaseHelper.insertMessage(sentMessage);
      }

      _channel.sink.add(message);
    } else {
      if (kDebugMode) print("Not connected. Attempting to reconnect...");
      connect();
    }
  }

  void dispose() {
    _channel.sink.close();
  }
}
