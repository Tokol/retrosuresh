import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:suresh_portfilo/widgets/streetfighter/StreetFighterSkills.dart';
import 'arcade_machine.dart';
import 'developer_mod_screen.dart';
import 'lecturer_mod_screen.dart';
 // Fixed typo

class ArcadeLanding extends StatefulWidget {
  const ArcadeLanding({super.key});

  @override
  _ArcadeLandingState createState() => _ArcadeLandingState();
}

class _ArcadeLandingState extends State<ArcadeLanding> {
  bool _started = false;
  String? _selectedPlayer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _startGame() async {
    await _audioPlayer.play(AssetSource('start.wav')); // Use start.wav
    setState(() => _started = true);
  }

  void _selectPlayer(String player) async {
    await _audioPlayer.setVolume(0.3);
    await _audioPlayer.play(AssetSource('success.wav'));
    setState(() => _selectedPlayer = player);

    Future.delayed(const Duration(milliseconds: 300), () {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        if (player == 'Lecturer') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LecturerModeScreen(
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        }

        if(player=='Developer'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:(context)=> DeveloperModScreen(
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(

        child: Center(
          child: ArcadeMachine(
            onPlayerSelected: _selectPlayer,
          ),
        ),
      ),
    );
  }
}