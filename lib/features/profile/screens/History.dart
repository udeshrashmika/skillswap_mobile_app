import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _bg = Color(0xFFFBFBFE);
const Color _lavender = Color(0xFF818CF8);
const Color _textColor = Color(0xFF1E293B);
const Color _secondaryText = Color(0xFF64748B);
const Color _softPurple = Color(0xFFEEEDFE);
const Color _darkPurple = Color(0xFF464275);
const Color _starColor = Color(0xFFFBA100);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Session History',
          style: GoogleFonts.poppins(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('senderId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _darkPurple),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return HistoryCard(docId: doc.id, requestData: data);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Text(
      'No completed swaps to rate.',
      style: GoogleFonts.poppins(color: _secondaryText),
    ),
  );
}

class HistoryCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> requestData;

  const HistoryCard({
    super.key,
    required this.docId,
    required this.requestData,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  int pendingRating = 0;
  String teacherName = "Loading...";
  String? profilePicUrl;

  static const List<String> _labels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Excellent',
  ];

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
  }

  Future<void> _fetchTeacherData() async {
    String receiverId = widget.requestData['receiverId'] ?? '';
    if (receiverId.isEmpty) {
      setState(() => teacherName = "Unknown Teacher");
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      if (userDoc.exists && mounted) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          teacherName = userData['fullName'] ?? userData['name'] ?? 'Teacher';
          profilePicUrl = userData['profileImageUrl'] ?? userData['profilePic'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
      if (mounted) setState(() => teacherName = "Teacher");
    }
  }

  Future<void> _submitRating() async {
    if (pendingRating == 0) return;

    String teacherId = widget.requestData['receiverId'] ?? '';
    if (teacherId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.docId)
          .update({'rated': true, 'savedRating': pendingRating});

      final teacherRef = FirebaseFirestore.instance
          .collection('users')
          .doc(teacherId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot teacherSnap = await transaction.get(teacherRef);

        if (teacherSnap.exists) {
          Map<String, dynamic> data =
              teacherSnap.data() as Map<String, dynamic>;

          double currentRating = (data['rating'] ?? 0.0).toDouble();
          int totalReviews = data['reviewCount'] ?? 0;

          double newRating =
              ((currentRating * totalReviews) + pendingRating) /
              (totalReviews + 1);

          transaction.update(teacherRef, {
            'rating': double.parse(newRating.toStringAsFixed(1)),
            'reviewCount': totalReviews + 1,
          });
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback sent to $teacherName!'),
            backgroundColor: _darkPurple,
          ),
        );
      }
    } catch (e) {
      debugPrint("Rating Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRated = widget.requestData['rated'] ?? false;
    int savedRating = widget.requestData['savedRating'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _lavender.withOpacity(0.2),
                backgroundImage:
                    profilePicUrl != null && profilePicUrl!.isNotEmpty
                    ? NetworkImage(profilePicUrl!)
                    : null,
                child: profilePicUrl == null || profilePicUrl!.isEmpty
                    ? Text(
                        teacherName.isNotEmpty
                            ? teacherName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: _darkPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _textColor,
                      ),
                    ),
                    Text(
                      widget.requestData['skillTitle'] ?? "Skill Session",
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(isRated),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 24),
          isRated ? _ratedSection(savedRating) : _ratingInput(),
        ],
      ),
    );
  }

  Widget _statusBadge(bool rated) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: rated ? const Color(0xFFE1F5EE) : _softPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        rated ? 'Rated' : 'Pending Review',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: rated ? const Color(0xFF0F6E56) : _lavender,
        ),
      ),
    );
  }

  Widget _ratedSection(int rating) {
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            Icons.star_rounded,
            size: 20,
            color: i < rating ? _starColor : const Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Feedback submitted',
          style: TextStyle(fontSize: 12, color: _secondaryText),
        ),
      ],
    );
  }

  Widget _ratingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How was your session with $teacherName?",
          style: const TextStyle(fontSize: 12, color: _secondaryText),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => pendingRating = i + 1),
                child: Icon(
                  Icons.star_rounded,
                  size: 30,
                  color: i < pendingRating
                      ? _starColor
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (pendingRating > 0)
              Text(
                _labels[pendingRating],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _lavender,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: pendingRating > 0 ? _submitRating : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Submit Rating',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
