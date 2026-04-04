import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _bg = Color(0xFFFBFBFE);
const Color _lavender = Color(0xFF818CF8);
const Color _teal = Color(0xFF2DD4BF);
const Color _textColor = Color(0xFF1E293B);
const Color _secondaryText = Color(0xFF64748B);
const Color _softPurple = Color(0xFFEEEDFE);
const Color _darkPurple = Color(0xFF464275);
const Color _starColor = Color(0xFFFBA100);

class SwapEntry {
  final int id;
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
  final Map<int, int> _pendingRatings = {};

  final List<SwapEntry> _entries = [
    SwapEntry(
      id: 1,
      initials: 'AM',
      avatarBg: Color(0xFFCECBF6),
      avatarFg: Color(0xFF3C3489),
      name: 'Alex Morgan',
      university: 'NSBM Green University',
      taughtYou: 'React',
      youTaught: 'Figma',
      date: 'Apr 2, 2026',
      duration: '1h 30m',
    ),
    SwapEntry(
      id: 2,
      initials: 'NP',
      avatarBg: Color(0xFF9FE1CB),
      avatarFg: Color(0xFF085041),
      name: 'Nina Perez',
      university: 'Colombo University',
      taughtYou: 'Flutter',
      youTaught: 'Illustrator',
      date: 'Mar 28, 2026',
      duration: '2h',
    ),
    SwapEntry(
      id: 3,
      initials: 'JL',
      avatarBg: Color(0xFFFAC775),
      avatarFg: Color(0xFF633806),
      name: 'James Lee',
      university: 'Moratuwa University',
      taughtYou: 'Node.js',
      youTaught: 'UI Design',
      date: 'Mar 15, 2026',
      duration: '1h',
      rated: true,
      savedRating: 5,
    ),
  ];

  static const List<String> _labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];

  void _submitRating(SwapEntry entry) {
    final rating = _pendingRatings[entry.id] ?? 0;
    if (rating == 0) return;
    setState(() {
      entry.rated = true;
      entry.savedRating = rating;
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
      body: ListView(
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
          ..._entries.map((e) => _buildCard(e)),
        ],
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
          // Header row
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

          // Skill pills row
          Row(
            children: [
              Expanded(child: _skillBox('They taught you', entry.taughtYou, true)),
              const SizedBox(width: 8),
              Expanded(child: _skillBox('You taught them', entry.youTaught, false)),
            ],
          ),

          const SizedBox(height: 12),

          // Date & duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.date, style: const TextStyle(color: _secondaryText, fontSize: 12)),
              Text(entry.duration, style: const TextStyle(color: _secondaryText, fontSize: 12)),
            ],
          ),

          const Divider(height: 24, thickness: 0.5),

          // Rating section
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