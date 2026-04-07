import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color primaryPurple = Color(0xFF6A5AE0);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E1E2D);
  static const Color textMuted = Colors.grey;

  Future<void> _updateRequestStatus(String docId, String status, Map<String, dynamic> requestData) async {
    await FirebaseFirestore.instance.collection('requests').doc(docId).update({
      'status': status,
    });

    if (status == 'completed') {
      try {
        final teacherDoc = await FirebaseFirestore.instance.collection('users').doc(requestData['receiverId']).get();
        final learnerDoc = await FirebaseFirestore.instance.collection('users').doc(requestData['senderId']).get();
        
        String teacherName = 'Teacher';
        String learnerName = 'Learner';
        String university = 'University';
        
        if (teacherDoc.exists) {
          final data = teacherDoc.data() as Map<String, dynamic>;
          teacherName = data['fullName'] ?? data['name'] ?? 'Teacher';
          university = data['university'] ?? 'University';
        }
        
        if (learnerDoc.exists) {
          final data = learnerDoc.data() as Map<String, dynamic>;
          learnerName = data['fullName'] ?? data['name'] ?? 'Learner';
        }

        String tInitials = teacherName.isNotEmpty ? teacherName.substring(0, 1).toUpperCase() : 'T';
        String lInitials = learnerName.isNotEmpty ? learnerName.substring(0, 1).toUpperCase() : 'L';

        await FirebaseFirestore.instance.collection('swap_history').add({
          'skillId': requestData['skillId'],
          'teacherId': requestData['receiverId'],
          'learnerId': requestData['senderId'],
          'participants': [requestData['senderId'], requestData['receiverId']],
          'teacherName': teacherName,
          'learnerName': learnerName,
          'teacherInitials': tInitials,
          'learnerInitials': lInitials,
          'university': university,
          'taughtYou': requestData['skillTitle'],
          'youTaught': 'Pending...', 
          'date': "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
          'duration': '1h', 
          'rated': false,
          'savedRating': 0,
        });
      } catch (e) {
        debugPrint("Error creating history: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: lightBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8.0),
            child: Text(
              "Requests",
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Manage your skill exchange',
                style: TextStyle(color: textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                indicatorColor: primaryPurple,
                indicatorWeight: 3,
                labelColor: primaryPurple,
                unselectedLabelColor: textMuted,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Received'),
                  Tab(text: 'Sent'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRequestsList(isReceived: true),
                  _buildRequestsList(isReceived: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList({required bool isReceived}) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text("Please login to view requests"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where(isReceived ? 'receiverId' : 'senderId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error loading requests: ${snapshot.error}"));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              isReceived ? "No received requests yet" : "No sent requests yet",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final requests = snapshot.data!.docs.toList();
        
        requests.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          Timestamp? t1 = aData['timestamp'] as Timestamp?;
          Timestamp? t2 = bData['timestamp'] as Timestamp?;
          if (t1 == null || t2 == null) return 0;
          return t2.compareTo(t1);
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            final otherUserId = isReceived ? data['senderId'] : data['receiverId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                }

                String name = 'Unknown User';
                String avatarUrl = 'https://randomuser.me/api/portraits/men/32.jpg';

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  name = userData['fullName'] ?? userData['name'] ?? 'Unknown User';
                  avatarUrl = userData['profileImageUrl'] ?? avatarUrl;
                }

                return _buildRequestCard(
                  docId: doc.id,
                  requestData: data,
                  name: name,
                  avatarUrl: avatarUrl,
                  isReceived: isReceived,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestCard({
    required String docId,
    required Map<String, dynamic> requestData,
    required String name,
    required String avatarUrl,
    required bool isReceived,
  }) {
    String status = requestData['status'] ?? 'pending';
    String skillTitle = requestData['skillTitle'] ?? 'Unknown Skill';
    String message = requestData['message'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isReceived ? 'Wants to learn: ' : 'You requested: ',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          skillTitle,
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Message: "$message"',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          if (status == 'pending') ...[
            if (isReceived)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _updateRequestStatus(docId, 'accepted', requestData),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _updateRequestStatus(docId, 'rejected', requestData),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Reject', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              )
            else
              _buildBadge('PENDING', Colors.orange),
          ] 
          else if (status == 'accepted') ...[
            if (isReceived)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateRequestStatus(docId, 'completed', requestData),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: const Text('Mark as Completed', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DD4BF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              )
            else
              _buildBadge('ACCEPTED', Colors.green),
          ] 
          else if (status == 'completed') ...[
            _buildBadge('SESSION COMPLETED', Colors.green),
          ] 
          else if (status == 'rejected') ...[
            _buildBadge('REJECTED', Colors.red),
          ]
        ],
      ),
    );
  }

  Widget _buildBadge(String text, MaterialColor color) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}