import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RetroServices extends StatefulWidget {
  const RetroServices({super.key});

  @override
  State<RetroServices> createState() => _RetroServicesState();
}

class _RetroServicesState extends State<RetroServices>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedIndex = 0;
  late AnimationController _controller;
  bool _isFiring = false;

  // Sample service data
  final List<Map<String, dynamic>> services = [
    {
      'name': 'Web Dev',
      'color': Colors.greenAccent,
      'icon': 'images/ship1.png',
      'desc': 'Building galactic websites',
      'level': 85,
    },
    {
      'name': 'Mobile Apps',
      'color': Colors.purpleAccent,
      'icon': 'images/ship2.png',
      'desc': 'Crafting stellar apps',
      'level': 90,
    },
    {
      'name': 'UI Design',
      'color': Colors.redAccent,
      'icon': 'images/ship3.png',
      'desc': 'Pixel-perfect interfaces',
      'level': 75,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _fireLaser(int index) async {
    setState(() => _isFiring = true);
    await _audioPlayer.play(AssetSource('assets/sounds/laser.wav'));
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _selectedIndex = index;
      _isFiring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Star field
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: StarFieldPainter(_controller.value),
                size: Size.infinite,
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'SERVICE INVADERS',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.cyan, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),

                  // Service selection
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return ServiceShip(
                          service: services[index],
                          isSelected: _selectedIndex == index,
                          isFiring: _isFiring && _selectedIndex == index,
                          onTap: () => _fireLaser(index),
                        );
                      },
                    ),
                  ),

                  // Enemy target
                  Expanded(
                    child: TargetZone(
                      service: services[_selectedIndex],
                      isFiring: _isFiring,
                    ),
                  ),
                ],
              ),
            ),

            // CRT effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
                stops: const [0.95, 1.0],
                tileMode: TileMode.repeated,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final double animationValue;

  StarFieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(animationValue);
    for (int i = 0; i < 50; i++) {
      canvas.drawCircle(
        Offset(
          (i * 73) % size.width,
          (i * 47) % size.height,
        ),
        1 + (i % 3).toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ServiceShip extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final bool isFiring;
  final VoidCallback onTap;

  const ServiceShip({
    required this.service,
    required this.isSelected,
    required this.isFiring,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Image.asset(
                  service['icon'],
                  width: 80,
                  color: service['color'],
                ),
                const SizedBox(height: 8),
                Text(
                  service['name'],
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (isFiring)
              Container(
                width: 2,
                height: 100,
                color: Colors.red,
              ),
            if (isSelected)
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: service['color'], width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TargetZone extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isFiring;

  const TargetZone({
    required this.service,
    required this.isFiring,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isFiring
              ? Image.asset(
            'images/explosion.png',
            width: 100,
            key: const ValueKey('explosion'),
          )
              : Image.asset(
            'images/alien.png',
            width: 100,
            color: service['color'],
            key: const ValueKey('alien'),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            border: Border.all(color: service['color'], width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                service['desc'],
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: service['level'] / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: service['color'],
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${service['level']}% POWER',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  color: service['color'],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}