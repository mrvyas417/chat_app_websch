// class MessageData {
//   String msgtext;
//   String userid;
//   bool isme;

//   MessageData({
//     required this.msgtext,
//     required this.userid,
//     required this.isme,
//   });

//   factory MessageData.fromJson(Map<String, dynamic> json) {
//     return MessageData(
//       msgtext: json["msgtext"] ?? "", // Default to empty string if null
//       userid: json["userid"] ?? "Unknown", // Default to "Unknown" if null
//       isme: json["isme"] == 1,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'msgtext': msgtext,
//       'userid': userid,
//       'isme': isme ? 1 : 0,
//     };
//   }
// }
class MessageData {
  String msgtext; // The content of the message
  String userid; // The ID of the user who sent the message
  bool isme; // A flag indicating if the message is from the current user

  // Constructor with required parameters
  MessageData({
    required this.msgtext,
    required this.userid,
    required this.isme,
  });

  // Factory constructor to create a MessageData object from JSON
  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      msgtext: json["msgtext"] ?? "", // Default to empty string if null
      userid: json["userid"] ?? "Unknown", // Default to "Unknown" if null
      isme: json["isme"] == 1, // Assuming 1 means true
    );
  }

  // Method to convert MessageData object to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'msgtext': msgtext,
      'userid': userid,
      'isme': isme ? 1 : 0, // Convert bool to int for storage
    };
  }
}
