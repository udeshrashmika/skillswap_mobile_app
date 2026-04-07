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
  final Map<String, int> _pendingRatings = {};
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  static const List<String> _labels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Excellent',
  ];

  Future<void> _submitRating(
    String docId,
    String teacherId,
    String teacherName,
  ) async {
    final rating = _pendingRatings[docId] ?? 0;
    if (rating == 0) return;

    try {
      await FirebaseFirestore.instance.collection('requests').doc(docId).update(
        {'rated': true, 'savedRating': rating},
      );

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
              ((currentRating * totalReviews) + rating) / (totalReviews + 1);

          transaction.update(teacherRef, {
            'rating': double.parse(newRating.toStringAsFixed(1)),
            'reviewCount': totalReviews + 1,
          });
        }
      });

      setState(() => _pendingRatings.remove(docId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback sent to $teacherName!'),
          backgroundColor: _darkPurple,
        ),
      );
    } catch (e) {
      debugPrint("Rating Error: $e");
    }
  }

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
              return _buildHistoryCard(doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(String docId, Map<String, dynamic> data) {
    bool isRated = data['rated'] ?? false;
    int savedRating = data['savedRating'] ?? 0;
    int pending = _pendingRatings[docId] ?? 0;
    String teacherName = data['receiverName'] ?? "Teacher";

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
                child: Text(
                  teacherName[0],
                  style: const TextStyle(
                    color: _darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      ),
                    ),
                    Text(
                      data['skillTitle'] ?? "Skill Session",
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
          isRated
              ? _ratedSection(savedRating)
              : _ratingInput(docId, data['receiverId'], teacherName, pending),
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

  Widget _ratingInput(
    String docId,
    String teacherId,
    String name,
    int pending,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How was your session with $name?",
          style: const TextStyle(fontSize: 12, color: _secondaryText),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _pendingRatings[docId] = i + 1),
                child: Icon(
                  Icons.star_rounded,
                  size: 30,
                  color: i < pending ? _starColor : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (pending > 0)
              Text(
                _labels[pending],
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
            onPressed: pending > 0
                ? () => _submitRating(docId, teacherId, name)
                : null,
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

  Widget _buildEmptyState() => Center(
    child: Text(
      'No completed swaps to rate.',
      style: GoogleFonts.poppins(color: _secondaryText),
    ),
  );
}
