import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:country_flags/country_flags.dart';
 // For SVG icons

class WorldMapHub extends StatefulWidget {
  final double fontScale;
  final double imageScale;
  const WorldMapHub({super.key, required this.fontScale, required this.imageScale});

  @override
  State<WorldMapHub> createState() => _WorldMapHubState();
}

class _WorldMapHubState extends State<WorldMapHub> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _hoveredRegion;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  final List<Map<String, dynamic>> _regions = [
    {'name': 'Nepal', 'code': 'NP', 'position': Offset(0.64, 0.39)},
    {'name': 'Egypt', 'code': 'IN', 'position': Offset(0.62, 0.44)},
    {'name': 'Thailand', 'code': 'TH', 'position': Offset(0.66, 0.44)},
    {'name': 'India', 'code': 'EG', 'position': Offset(0.51, 0.40)},
    {'name': 'Vietnam', 'code': 'VN', 'position': Offset(0.70, 0.46)},
    {'name': 'Malaysia', 'code': 'MY', 'position': Offset(0.67, 0.50)},
    {'name': 'Singapore', 'code': 'SG', 'position': Offset(0.676, 0.54)},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(0.3);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _blinkController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('images/world_map_8bit.png'),
    fit: BoxFit.cover,
    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
    )),
    child: Stack(
    children: [
    // Stats Container with Avatar Inside
    Positioned(
    top: 20 * widget.fontScale,
    right: 20 * widget.fontScale,
    child: Container(
    padding: EdgeInsets.all(4 * widget.fontScale),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.7),
    border: Border.all(
    color: Colors.cyan,
    width: 2 * widget.fontScale,
    ),
    borderRadius: BorderRadius.circular(12 * widget.fontScale),
    boxShadow: [
    BoxShadow(
    color: Colors.cyan.withOpacity(0.4),
    blurRadius: 10 * widget.fontScale,
    spreadRadius: 2 * widget.fontScale,
    ),
    ],
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    // Avatar at Top
    Container(
    width: 40 * widget.imageScale,
    height: 40 * widget.imageScale,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
    color: Colors.cyan,
    width: 2 * widget.imageScale,
    ),
    ),
    child: ClipOval(
    child: Image.asset(
    'images/avatar_8bit.png',
    fit: BoxFit.cover,
    ),
    ),
    ),
    SizedBox(height: 10 * widget.fontScale),

    // Stats with Icons
    _buildStatRow(Icons.flag, 'Countries: 7'),
    SizedBox(height: 8 * widget.fontScale),
    _buildStatRow(Icons.airplanemode_active, 'Miles: 3000+'),
    SizedBox(height: 8 * widget.fontScale),
    _buildStatRow(Icons.people, 'Cultures: 10+'),
    SizedBox(height: 8 * widget.fontScale),
    _buildStatRow(Icons.language, 'Languages: 6'),
    ],
    ),
    ),
    ),

    // Interactive Regions with Fast Blinking Flags
    ..._regions.map((region) {
    return Positioned(
    left: size.width * region['position'].dx - 20 * widget.imageScale,
    top: size.height * region['position'].dy - 20 * widget.imageScale,
    child: MouseRegion(
    onEnter: (_) {

    setState(() => _hoveredRegion = region['name']);
    },
    onExit: (_) => setState(() => _hoveredRegion = null),
    child: GestureDetector(
    onTap: () => print('Selected ${region['name']}'),
    child: AnimatedBuilder(
    animation: _blinkController,
    builder: (context, child) {
    return Transform.scale(
    scale: _hoveredRegion == region['name'] ? 1.3 : 1.0,
    child: Opacity(
    opacity: _hoveredRegion == region['name'] ? 1.0 : _blinkAnimation.value,
    child: Container(
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
    BoxShadow(
    color: (_hoveredRegion == region['name']
    ? Colors.yellow
        : Colors.cyan).withOpacity(0.7),
    blurRadius: 10 * widget.imageScale,
    spreadRadius: 2 * widget.imageScale,
    ),
    ],
    ),
    child: Stack(
    alignment: Alignment.center,
    children: [
    CountryFlag.fromCountryCode(
    region['code'],
    width: 20 * widget.imageScale,
    height: 20 * widget.imageScale,
    shape: const Rectangle(),
    ),
    if (_hoveredRegion == region['name'])
    Positioned(
    bottom: -25 * widget.fontScale,
    child: Container(
    padding: EdgeInsets.symmetric(
    horizontal: 8 * widget.fontScale,
    vertical: 4 * widget.fontScale,
    ),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.7),
    borderRadius: BorderRadius.circular(4 * widget.fontScale),
    ),
    child: Text(
    region['name'],
    style: GoogleFonts.pressStart2p(
    fontSize: 12 * widget.fontScale,
    color: Colors.yellow,
    shadows: [
    Shadow(
    color: Colors.black.withOpacity(0.8),
    blurRadius: 4,
    offset: Offset(1, 1),
    ),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    );
    },
    ),
    ),
    ),
    );
    }).toList(),
    ],
    ),
    );
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      Icon(
      icon,
      color: Colors.cyan,
      size: 12 * widget.fontScale,
    ),
    SizedBox(width: 8 * widget.fontScale),
    Text(
    text,
    style: GoogleFonts.pressStart2p(
    fontSize: 9 * widget.fontScale,
    color: Colors.cyan,
    shadows: [
    Shadow(
    color: Colors.cyan.withOpacity(0.5),
    blurRadius: 4,
    offset: Offset(1, 1),
    )],
    ),
    ),
    ],
    );
  }
}