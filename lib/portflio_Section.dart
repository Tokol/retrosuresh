import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioScreen extends StatelessWidget {
  final String player;

  const PortfolioScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$player MODE', style: GoogleFonts.pressStart2p()),
        backgroundColor: const Color(0xFFFF007A),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'WELCOME TO $player QUEST',
                style: GoogleFonts.pressStart2p(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              if (player == 'Lecturer')
                Text('Teaching Tips & Memes', style: GoogleFonts.pressStart2p(color: Colors.yellow)),
              if (player == 'Developer')
                Text('Projects & Code', style: GoogleFonts.pressStart2p(color: Colors.yellow)),
              if (player == 'Traveller')
                Text('Travel Stories', style: GoogleFonts.pressStart2p(color: Colors.yellow)),
            ],
          ),
        ),
      ),
    );
  }
}