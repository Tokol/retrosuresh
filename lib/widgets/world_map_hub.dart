// world_map_hub.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class WorldMapHub extends StatefulWidget {
  final double fontScale;
  final double imageScale;
  const WorldMapHub({super.key, required this.fontScale, required this.imageScale});

  @override
  State<WorldMapHub> createState() => _WorldMapHubState();
}

class _WorldMapHubState extends State<WorldMapHub> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _hoveredRegion;

  // Placeholder regions based on your travels
  final List<Map<String, dynamic>> _regions = [
    {'name': 'Nepal', 'icon': 'images/nepal_flag.png', 'position': Offset(0.6, 0.4)},
    {'name': 'Egypt', 'icon': 'images/egypt_flag.png', 'position': Offset(0.2, 0.6)},
    {'name': 'Thailand', 'icon': 'images/thailand_flag.png', 'position': Offset(0.7, 0.5)},
    {'name': 'India', 'icon': 'images/india_flag.png', 'position': Offset(0.5, 0.45)},
    // Add more regions (Singapore, Malaysia, Vietnam, etc.) as needed
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(0.3);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playHoverSound() {
    _audioPlayer.play(AssetSource('map_hover.wav')); // Placeholder sound
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/world_map_8bit.png'), // Placeholder 8-bit map
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Travel Stats HUD
          Positioned(
            top: 10 * widget.fontScale,
            right: 10 * widget.fontScale,
            child: Container(
              padding: EdgeInsets.all(8 * widget.fontScale),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border.all(color: Colors.cyan, width: 2 * widget.fontScale),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Countries: 7',
                    style: GoogleFonts.pressStart2p(fontSize: 10 * widget.fontScale, color: Colors.cyan),
                  ),
                  Text(
                    'Miles: 3000+',
                    style: GoogleFonts.pressStart2p(fontSize: 10 * widget.fontScale, color: Colors.cyan),
                  ),
                  Text(
                    'Cultures: 10+',
                    style: GoogleFonts.pressStart2p(fontSize: 10 * widget.fontScale, color: Colors.cyan),
                  ),
                ],
              ),
            ),
          ),
          // Avatar (center of map initially)
          Positioned(
            left: size.width * 0.5 - 20 * widget.imageScale,
            top: size.height * 0.4 - 20 * widget.imageScale,
            child: Image.asset(
              'images/avatar_8bit.png', // Placeholder 8-bit avatar
              width: 40 * widget.imageScale,
              height: 40 * widget.imageScale,
            ),
          ),
          // Interactive Regions
          ..._regions.map((region) {
            return Positioned(
              left: size.width * region['position'].dx - 20 * widget.imageScale,
              top: size.height * region['position'].dy - 20 * widget.imageScale,
              child: MouseRegion(
                onEnter: (_) {
                  _playHoverSound();
                  setState(() => _hoveredRegion = region['name']);
                },
                onExit: (_) => setState(() => _hoveredRegion = null),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to specific section (to be implemented later)
                    print('Selected ${region['name']}');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..scale(_hoveredRegion == region['name'] ? 1.2 : 1.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          region['icon'],
                          width: 40 * widget.imageScale,
                          height: 40 * widget.imageScale,
                        ),
                        if (_hoveredRegion == region['name'])
                          Positioned(
                            bottom: -20 * widget.fontScale,
                            child: Text(
                              region['name'],
                              style: GoogleFonts.pressStart2p(
                                fontSize: 10 * widget.fontScale,
                                color: Colors.yellow,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}