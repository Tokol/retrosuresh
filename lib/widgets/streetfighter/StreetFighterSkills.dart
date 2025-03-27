import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../models/SkillMove.dart';
import '../../models/WorkExperience.dart';

class StreetFighterSkills extends StatefulWidget {
  const StreetFighterSkills({super.key});

  @override
  State<StreetFighterSkills> createState() => _StreetFighterSkillsState();
}

class _StreetFighterSkillsState extends State<StreetFighterSkills> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  SkillMove? _selectedMove;
  bool _showJourney = false;

  // Sample data - replace with your actual info
  final List<SkillMove> _skills = [
    SkillMove(
      name: "FLUTTER TYPHOON",
      input: "⬇↘→ + A",
      description: "Launches cross-platform apps like Hadoukens",
      realWorldUse: "Built 5 apps @TechCorp (2022)",
      mastery: 95,
      enemyImage: "images/legacy_code.webp",
      color: Colors.blue,
    ),
    SkillMove(
      name: "JAVA UPPERCUT",
      input: "←↙↓ + B",
      description: "One-shots NullPointerException",
      realWorldUse: "Optimized backend @CodeFort (2020)",
      mastery: 90,
      enemyImage: "images/legacy_code.webp",
      color: Colors.red,
    ),
    SkillMove(
      name: "CLIENT WHISPERER",
      input: "↓↑ + C",
      description: "Converts vague requests into specs",
      realWorldUse: "Managed 10+ clients @DevGuild (2021)",
      mastery: 85,
      enemyImage: "images/legacy_code.webp",
      color: Colors.green,
    ),
  ];

  final List<WorkExperience> _experience = [
    WorkExperience(
      company: "TECH CORP",
      period: "2020-2022",
      role: "MOBILE WARRIOR",
      achievements: [
        "Shipped 5 Flutter apps",
        "Reduced crashes by 70%",
      ],
    ),
    WorkExperience(
      company: "CODE FORT",
      period: "2018-2020",
      role: "JAVA KNIGHT",
      achievements: [
        "Slayed legacy code dragon",
        "Boosted performance 3x",
      ],
    ),
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Main Content
          if (!_showJourney) _buildVsScreen(),
          if (_showJourney) _buildJourneyMap(),

          // KO Screen (overlay)
          if (_selectedMove != null) _buildKOScreen(),
        ],
      ),
    );
  }

  // ========================
  // WIDGET BUILDERS
  // ========================

  Widget _buildBackground() {
    return Image.asset(
      "images/sf_street_fighter_stage.webp",
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildVsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            "CHOOSE YOUR SKILL",
            style: GoogleFonts.pressStart2p(
              fontSize: 24,
              color: Colors.yellow,
            ),
          ),
          const SizedBox(height: 40),

          // Player vs Enemy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Player
              Image.asset(
                "images/suresh.JPG",
                width: 100,
              ),

              // Moves List
              Column(
                children: _skills
                    .map((move) => _buildMoveCard(move))
                    .toList(),
              ),

              // Enemy
              Image.asset(
                _selectedMove?.enemyImage ?? _skills[0].enemyImage,
                width: 100,
              ),
            ],
          ),

          // Continue Button
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () {
              _audioPlayer.play(AssetSource('select.mp3'));
              //_audioPlayer.play('sfx/select.wav');
              setState(() => _showJourney = true);
            },
            child: Text(
              "VIEW MY JOURNEY →",
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveCard(SkillMove move) {
    return GestureDetector(
      onTap: () {
        _audioPlayer.play(AssetSource('sfx/punch.wav'));
        setState(() => _selectedMove = move);
      },
      child: MouseRegion(
       // onEnter: () => _audioPlayer.play(AssetSource('sfx/blip.wav')),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: move.color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(
                move.input,
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: move.color,
                ),
              ),
              Text(
                move.name,
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKOScreen() {
    return GestureDetector(
      onTap: () => setState(() => _selectedMove = null),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "K.O.!",
                style: GoogleFonts.pressStart2p(
                  fontSize: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: _selectedMove!.color),
                ),
                child: Column(
                  children: [
                    Text(
                      _selectedMove!.name,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 16,
                        color: _selectedMove!.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedMove!.description,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "REAL-WORLD USE:",
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: Colors.yellow,
                      ),
                    ),
                    Text(
                      _selectedMove!.realWorldUse,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "CLICK TO CONTINUE",
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyMap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "MY 8-BIT JOURNEY",
            style: GoogleFonts.pressStart2p(
              fontSize: 24,
              color: Colors.yellow,
            ),
          ),
          const SizedBox(height: 30),

          // Map Visualization
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _experience.map((exp) => _buildCompanyCastle(exp)).toList(),
            ),
          ),

          // Back Button
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () {
              _audioPlayer.play(AssetSource('sfx/select.wav'));
              setState(() => _showJourney = false);
            },
            child: Text(
              "← BACK TO SKILLS",
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCastle(WorkExperience exp) {
    return GestureDetector(
      onTap: () => _showExperienceDialog(exp),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Image.asset(
              "assets/castles/${exp.company.toLowerCase()}.png",
              height: 100,
            ),
            Text(
              exp.company,
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
            Text(
              exp.period,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExperienceDialog(WorkExperience exp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            exp.company,
            style: GoogleFonts.pressStart2p(
              color: Colors.yellow,
              fontSize: 14,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ROLE: ${exp.role}",
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "ACHIEVEMENTS:",
                  style: GoogleFonts.pressStart2p(
                    color: Colors.yellow,
                    fontSize: 10,
                  ),
                ),
                ...exp.achievements.map((achievement) => Text(
                  "- $achievement",
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CLOSE",
                style: GoogleFonts.pressStart2p(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}