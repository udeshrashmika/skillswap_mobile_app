import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../chat/screens/chat.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  static const Color bg = Color(0xFFFBFBFE);
  static const Color lavenderAccent = Color(0xFF818CF8);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);

  late String currentUserId;

  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getChatRoomId(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "${a}_$b";
    } else {
      return "${b}_$a";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Messages",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: textColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: GoogleFonts.poppins(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search messages...",
                  hintStyle: GoogleFonts.poppins(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: lavenderAccent),

                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: secondaryText,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
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
                      "No friends found.",
                      style: GoogleFonts.poppins(color: secondaryText),
                    ),
                  );
                }

                var users = snapshot.data!.docs.where((doc) {
                  if (doc.id == currentUserId) return false;

                  var userData = doc.data() as Map<String, dynamic>;
                  String name = (userData['fullName'] ?? 'Unknown User')
                      .toString()
                      .toLowerCase();

                  if (searchQuery.isEmpty) {
                    return true;
                  } else {
                    return name.contains(searchQuery);
                  }
                }).toList();

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      "No users match your search.",
                      style: GoogleFonts.poppins(color: secondaryText),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index].data() as Map<String, dynamic>;
                    String peerId = users[index].id;
                    String name = userData['fullName'] ?? 'Unknown User';
                    String image = userData['profileImageUrl'] ?? '';
                    String chatRoomId = getChatRoomId(currentUserId, peerId);

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatRoomId)
                          .collection('messages')
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (context, chatSnapshot) {
                        String lastMessage = "Tap to chat";
                        String lastTime = "";
                        int unreadCount = 0;

                        if (chatSnapshot.hasData &&
                            chatSnapshot.data!.docs.isNotEmpty) {
                          var docs = chatSnapshot.data!.docs;
                          var lastDoc =
                              docs.first.data() as Map<String, dynamic>;

                          lastMessage = lastDoc['text'] ?? "Photo/Attachment";
                          if (lastDoc['time'] != null) {
                            lastTime = DateFormat(
                              'hh:mm a',
                            ).format((lastDoc['time'] as Timestamp).toDate());
                          }

                          for (var doc in docs) {
                            var data = doc.data() as Map<String, dynamic>;
                            if (data['senderId'] == peerId &&
                                data['isRead'] == false) {
                              unreadCount++;
                            }
                          }
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  peerId: peerId,
                                  name: name,
                                  image: image,
                                  currentUserId: currentUserId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: image.isNotEmpty
                                    ? Image.network(
                                        image,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          width: 50,
                                          height: 50,
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(
                                            Icons.person,
                                            color: secondaryText,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: const Color(0xFFF1F5F9),
                                        child: const Icon(
                                          Icons.person,
                                          color: secondaryText,
                                        ),
                                      ),
                              ),
                              title: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  lastMessage,
                                  style: GoogleFonts.poppins(
                                    color: unreadCount > 0
                                        ? textColor.withOpacity(0.8)
                                        : secondaryText,
                                    fontSize: 13,
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (lastTime.isNotEmpty)
                                    Text(
                                      lastTime,
                                      style: GoogleFonts.poppins(
                                        color: unreadCount > 0
                                            ? tealAccent
                                            : secondaryText.withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: unreadCount > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  const SizedBox(height: 5),
                                  if (unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: tealAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        unreadCount.toString(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
