import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


class ArcadeMarqueeContact extends StatefulWidget {
  @override
  _ArcadeMarqueeContactState createState() => _ArcadeMarqueeContactState();
}

class _ArcadeMarqueeContactState extends State<ArcadeMarqueeContact> {
  bool isCLit = false, isOLit = false, isTLit1 = false, isALit = false, isCLit2 = false;
  bool isNLit = false, isTLit2 = false; // Light up on submission
  bool isFlickering = false;
  bool isSubmitted = false;

  void startFlicker() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        isFlickering = !isFlickering;
      });
      if (timer.tick >= 5) timer.cancel(); // Flicker for 1 second (5 cycles)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Image.asset('images/marquee/arcade_wall_bg.png', fit: BoxFit.cover),
        // Marquee and Form
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Marquee
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: isFlickering && isCLit ? 0.8 : 1.0,
                    duration: Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isCLit ? Colors.red : Colors.grey,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        'C',
                        style: GoogleFonts.pressStart2p(
                          color: isCLit ? Colors.red : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Repeat for O, N, T, A, C, T with corresponding booleans
                ],
              ),
              // Form Fields
              Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      if (value.isNotEmpty) setState(() => isCLit = true);
                    },
                    decoration: InputDecoration(
                      labelText: 'NAME',
                      labelStyle: GoogleFonts.pressStart2p(color: Colors.cyan),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(  color: Color(0xFFFF00FF), ),
                      ),
                    ),
                  ),
                  // Repeat for Email, Project Type, Project Budget, Description
                ],
              ),
              // Social Media Tokens
              Wrap(
                spacing: 5,
                children: [
                  GestureDetector(
                  //  onTap: () => launchUrl('linkedin_url'),
                    child: Image.asset('images/marquee/social/linkedin_token.png'),
                  ),
                  // Repeat for Instagram, WhatsApp, YouTube
                ],
              ),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isNLit = true;
                    isTLit2 = true;
                    isSubmitted = true;
                  });
                  startFlicker();
                  // Play neon buzz sound
                },
                child: Text('LIGHT IT UP!', style: GoogleFonts.pressStart2p(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  side: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              if (isSubmitted)
                Text(
                  'SIGN LIT! MESSAGE SENT!',
                  style: GoogleFonts.pressStart2p(color: Colors.green),
                ),
            ],
          ),
        ),
      ],
    );
  }
}