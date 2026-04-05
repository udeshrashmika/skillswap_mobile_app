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

  static const List<String> _labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];

  
  late Stream<QuerySnapshot> _historyStream;

 
  @override
  void initState() {
    super.initState();
    _historyStream = FirebaseFirestore.instance.collection('swap_history').snapshots();
  }

  Future<void> _submitRating(SwapEntry entry) async {
    final rating = _pendingRatings[entry.id] ?? 0;
    if (rating == 0) return;

    try {
      await FirebaseFirestore.instance
          .collection('swap_history')
          .doc(entry.id)
          .update({
        'rated': true,
        'savedRating': rating,
      });

      setState(() {
        _pendingRatings.remove(entry.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You rated ${entry.name.split(' ')[0]} $rating star${rating > 1 ? 's' : ''}!'),
          backgroundColor: _darkPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
            fontSize: 20,
          ),
        ),
      ),
      
      
      body: StreamBuilder<QuerySnapshot>(
        stream: _historyStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _darkPurple));
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No swap history found.',
                style: GoogleFonts.poppins(color: _secondaryText),
              ),
            );
          }

          final entries = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SwapEntry(
              id: doc.id,
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

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Rate the people you learned from',
                  style: GoogleFonts.poppins(color: _secondaryText, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              ...entries.map((e) => _buildCard(e)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(SwapEntry entry) {
    final pending = _pendingRatings[entry.id] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: entry.avatarBg,
                child: Text(entry.initials,
                    style: TextStyle(color: entry.avatarFg, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, color: _textColor, fontSize: 15)),
                        _statusBadge(entry.rated),
                      ],
                    ),
                    Text(entry.university,
                        style: const TextStyle(color: _secondaryText, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _skillBox('They taught you', entry.taughtYou, true)),
              const SizedBox(width: 8),
              Expanded(child: _skillBox('You taught them', entry.youTaught, false)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.date, style: const TextStyle(color: _secondaryText, fontSize: 12)),
              Text(entry.duration, style: const TextStyle(color: _secondaryText, fontSize: 12)),
            ],
          ),

          const Divider(height: 24, thickness: 0.5),

          entry.rated ? _ratedSection(entry.savedRating) : _ratingInput(entry, pending),
        ],
      ),
    );
  }

  Widget _statusBadge(bool rated) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: rated ? const Color(0xFFE1F5EE) : _softPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rated ? 'Rated' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: rated ? const Color(0xFF0F6E56) : _lavender,
        ),
      ),
    );
  }

  Widget _skillBox(String label, String skill, bool gradient) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _secondaryText, fontSize: 11)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: gradient
                  ? const LinearGradient(colors: [_lavender, _teal])
                  : null,
              color: gradient ? null : _softPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              skill,
              style: TextStyle(
                color: gradient ? Colors.white : _darkPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratedSection(int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your rating',
            style: TextStyle(color: _secondaryText, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            ...List.generate(5, (i) => Icon(
              Icons.star_rounded,
              size: 22,
              color: i < rating ? _starColor : const Color(0xFFE2E8F0),
            )),
            const SizedBox(width: 8),
            Text(
              ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'][rating],
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _textColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ratingInput(SwapEntry entry, int pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How was your session with ${entry.name.split(' ')[0]}?',
          style: const TextStyle(color: _secondaryText, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ...List.generate(5, (i) {
              final val = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _pendingRatings[entry.id] = val),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.star_rounded,
                    size: 32,
                    color: val <= pending ? _starColor : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            if (pending > 0)
              Text(
                _labels[pending],
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _lavender),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: pending > 0 ? () => _submitRating(entry) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkPurple,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: Text(
              'Submit Rating',
              style: GoogleFonts.poppins(
                color: pending > 0 ? Colors.white : const Color(0xFFAAAAAA),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}