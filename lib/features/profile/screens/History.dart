import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _bg = Color(0xFFFBFBFE);
const Color _lavender = Color(0xFF818CF8);
const Color _teal = Color(0xFF2DD4BF);
const Color _textColor = Color(0xFF1E293B);
const Color _secondaryText = Color(0xFF64748B);
const Color _softPurple = Color(0xFFEEEDFE);
const Color _darkPurple = Color(0xFF464275);
const Color _starColor = Color(0xFFFBA100);

class SwapEntry {
  final String id;
  final String teacherId;
  final String initials;
  final Color avatarBg;
  final Color avatarFg;
  final String name;
  final String university;
  final String taughtYou;
  final String youTaught;
  final String date;
  final String duration;
  bool rated;
  int savedRating;

  SwapEntry({
    required this.id,
    required this.teacherId,
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    required this.name,
    required this.university,
    required this.taughtYou,
    required this.youTaught,
    required this.date,
    required this.duration,
    this.rated = false,
    this.savedRating = 0,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Map<String, int> _pendingRatings = {};
  static const List<String> _labels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Excellent',
  ];

  Future<void> _submitRating(SwapEntry entry) async {
    final rating = _pendingRatings[entry.id] ?? 0;
    if (rating == 0) return;

    try {
      await FirebaseFirestore.instance
          .collection('swap_history')
          .doc(entry.id)
          .update({'rated': true, 'savedRating': rating});

      final teacherRef = FirebaseFirestore.instance
          .collection('users')
          .doc(entry.teacherId);

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

      setState(() => _pendingRatings.remove(entry.id));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile Updated! You rated ${entry.name.split(' ')[0]} $rating stars.',
          ),
          backgroundColor: _darkPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync Error: $e')));
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
          'Swap History',
          style: GoogleFonts.poppins(
            color: _textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('swap_history')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(color: _darkPurple),
            );
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return _buildEmptyState();

          final entries = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SwapEntry(
              id: doc.id,
              teacherId: data['teacherId'] ?? '',
              initials: data['initials'] ?? 'NA',
              avatarBg: Color(data['avatarBg'] ?? 0xFFCECBF6),
              avatarFg: Color(data['avatarFg'] ?? 0xFF3C3489),
              name: data['name'] ?? 'Unknown User',
              university: data['university'] ?? 'Unknown University',
              taughtYou: data['taughtYou'] ?? 'N/A',
              youTaught: data['youTaught'] ?? 'N/A',
              date: data['date'] ?? '',
              duration: data['duration'] ?? '',
              rated: data['rated'] ?? false,
              savedRating: data['savedRating'] ?? 0,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: entries.length,
            itemBuilder: (context, index) => _buildCard(entries[index]),
          );
        },
      ),
    );
  }

  Widget _buildCard(SwapEntry entry) {
    final pending = _pendingRatings[entry.id] ?? 0;
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
                backgroundColor: entry.avatarBg,
                child: Text(
                  entry.initials,
                  style: TextStyle(
                    color: entry.avatarFg,
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
                      entry.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      entry.university,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(entry.rated),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _skillBox('Learned', entry.taughtYou, true)),
              const SizedBox(width: 8),
              Expanded(child: _skillBox('Taught', entry.youTaught, false)),
            ],
          ),
          const Divider(height: 24),
          entry.rated
              ? _ratedSection(entry.savedRating)
              : _ratingInput(entry, pending),
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
        rated ? 'Rated' : 'Pending',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: rated ? const Color(0xFF0F6E56) : _lavender,
        ),
      ),
    );
  }

  Widget _skillBox(String label, String skill, bool isMain) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: _secondaryText),
          ),
          Text(
            skill,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isMain ? _lavender : _darkPurple,
            ),
          ),
        ],
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
        Text(
          'You rated this session ${rating}/5',
          style: const TextStyle(fontSize: 12, color: _secondaryText),
        ),
      ],
    );
  }

  Widget _ratingInput(SwapEntry entry, int pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _pendingRatings[entry.id] = i + 1),
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
            onPressed: pending > 0 ? () => _submitRating(entry) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Submit Feedback',
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
      'No swaps found yet.',
      style: GoogleFonts.poppins(color: _secondaryText),
    ),
  );
}
