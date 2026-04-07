import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String name;
  final String image;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.name,
    required this.image,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color bg = Color(0xFFFBFBFE);
  static const Color lavenderAccent = Color(0xFF818CF8);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);

  final TextEditingController _messageController = TextEditingController();
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    chatRoomId = getChatRoomId(widget.currentUserId, widget.peerId);
  }

  String getChatRoomId(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "${a}_$b";
    } else {
      return "${b}_$a";
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String messageText = _messageController.text.trim();
      _messageController.clear();

      Map<String, dynamic> messageMap = {
        "text": messageText,
        "senderId": widget.currentUserId,
        "receiverId": widget.peerId,
        "time": FieldValue.serverTimestamp(),
        "isRead": false,
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageMap);
    }
  }

  void deleteMessage(String messageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Message",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Are you sure you want to delete this message?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: secondaryText),
            ),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .doc(messageId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.image.isNotEmpty
                  ? NetworkImage(widget.image)
                  : null,
              backgroundColor: const Color(0xFFF1F5F9),
              radius: 20,
              child: widget.image.isEmpty
                  ? const Icon(Icons.person, color: secondaryText)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Online",
                    style: GoogleFonts.poppins(
                      color: tealAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: lavenderAccent),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Say hi to ${widget.name}!",
                      style: GoogleFonts.poppins(color: secondaryText),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    var msg = document.data() as Map<String, dynamic>;
                    String docId = document.id;
                    bool isMe = msg['senderId'] == widget.currentUserId;

                    if (!isMe && msg['isRead'] == false) {
                      Future.microtask(() {
                        document.reference.update({'isRead': true});
                      });
                    }

                    String timeString = "";
                    if (msg['time'] != null) {
                      Timestamp timestamp = msg['time'];
                      timeString = DateFormat(
                        'hh:mm a',
                      ).format(timestamp.toDate());
                    }

                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) {
                          deleteMessage(docId);
                        }
                      },
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? tealAccent : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 5),
                              bottomRight: Radius.circular(isMe ? 5 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg['text'] ?? "",
                                style: GoogleFonts.poppins(
                                  color: isMe ? Colors.white : textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeString,
                                    style: GoogleFonts.poppins(
                                      color: isMe
                                          ? Colors.white70
                                          : secondaryText.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: msg['isRead'] == true
                                          ? Colors.blueAccent
                                          : Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Message",
                          hintStyle: GoogleFonts.poppins(
                            color: secondaryText,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: tealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
