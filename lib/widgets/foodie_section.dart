import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:country_flags/country_flags.dart';

class FoodieArcadeGrid extends StatefulWidget {
  final double fontScale;
  final double imageScale;

  const FoodieArcadeGrid({
    super.key,
    required this.fontScale,
    required this.imageScale,
  });

  @override
  State<FoodieArcadeGrid> createState() => _FoodieArcadeGridState();
}

class _FoodieArcadeGridState extends State<FoodieArcadeGrid> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _gridPopController;
  late Animation<double> _gridPopAnimation;
  int? _selectedIndex;
  bool _showDetail = false;

  // 6x6 Food Grid Data
  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'MOMO',
      'country': 'NEPAL',
      'code': 'NP',
      'image': 'images/food_momo_8bit.png',
      'location': 'YAK & YETI, KATHMANDU',
      'story': 'STEAMED HIMALAYAN DUMPLINGS\nSPICY CHUTNEY KICK!\nFIRST TRIED: 2018',
      'flavor': 'SPICY/SAVORY'
    },
    {
      'name': 'SUSHI',
      'country': 'JAPAN',
      'code': 'JP',
      'image': 'images/food_sushi_8bit.png',
      'location': 'TSUKIJI MARKET, TOKYO',
      'story': 'FRESH WASABI BLAST\nUMAMI EXPLOSION!\nFIRST TRIED: 2019',
      'flavor': 'FRESH/UMAMI'
    },
    // Add 34 more items following same structure
    // ...
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(0.3);

    _gridPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _gridPopAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _gridPopController, curve: Curves.easeOutBack)
    );

    // Fill remaining slots with empty items if less than 36
    while (_foodItems.length < 36) {
      _foodItems.add({'empty': true});
    }
  }

  @override
  void dispose() {
    _gridPopController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _selectFood(int index) {
    if (_foodItems[index]['empty'] == true) return;

    setState(() {
      _selectedIndex = index;
      _showDetail = true;
    });

    _audioPlayer.play(AssetSource('sounds/arcade_select.wav'));
    _gridPopController.forward(from: 0);
  }

  void _closeDetail() {
    _audioPlayer.play(AssetSource('sounds/arcade_back.wav'));
    setState(() => _showDetail = false);
  }

  Widget _buildGridItem(int index) {
    final item = _foodItems[index];

    if (item['empty'] == true) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Center(
          child: Icon(
            Icons.question_mark,
            color: Colors.grey[600],
            size: 20 * widget.fontScale,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _selectFood(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedBuilder(
          animation: _gridPopAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _selectedIndex == index ? _gridPopAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedIndex == index
                        ? Colors.amber
                        : Colors.grey[700]!,
                    width: 2 * widget.imageScale,
                  ),
                  image: DecorationImage(
                    image: AssetImage(item['image']),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // Item Label
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4 * widget.fontScale),
                        color: Colors.black.withOpacity(0.7),
                        child: Text(
                          item['name'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10 * widget.fontScale,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Country Flag Badge
                    if (item['code'] != null)
                      Positioned(
                        top: 4 * widget.imageScale,
                        right: 4 * widget.imageScale,
                        child: CountryFlag.fromCountryCode(
                          item['code'],
                          width: 20 * widget.imageScale,
                          height: 15 * widget.imageScale,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    if (_selectedIndex == null) return const SizedBox();

    final food = _foodItems[_selectedIndex!];

    return Stack(
      children: [
        // Background Overlay
        GestureDetector(
          onTap: _closeDetail,
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        // Detail Card
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(20 * widget.imageScale),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: Colors.amber,
                  width: 3 * widget.imageScale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 20 * widget.imageScale,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    'FOOD DOSSIER',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 16 * widget.fontScale,
                      color: Colors.amber,
                      letterSpacing: 2,
                    ),
                  ),
                  Divider(color: Colors.amber),
                  SizedBox(height: 10 * widget.imageScale),

                  // Content Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Image
                      Container(
                        width: 150 * widget.imageScale,
                        height: 150 * widget.imageScale,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          image: DecorationImage(
                            image: AssetImage(food['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 20 * widget.imageScale),

                      // Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Country
                            Row(
                              children: [
                                Text(
                                  food['name'],
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 18 * widget.fontScale,
                                    color: Colors.amber,
                                  ),
                                ),
                                SizedBox(width: 10 * widget.imageScale),
                                CountryFlag.fromCountryCode(
                                  food['code'],
                                  width: 40 * widget.imageScale,
                                  height: 30 * widget.imageScale,
                                ),
                              ],
                            ),
                            SizedBox(height: 10 * widget.imageScale),

                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 16 * widget.fontScale,
                                ),
                                SizedBox(width: 5 * widget.imageScale),
                                Text(
                                  food['location'],
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 10 * widget.fontScale,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10 * widget.imageScale),

                            // Flavor
                            Text(
                              'FLAVOR PROFILE: ${food['flavor']}',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 12 * widget.fontScale,
                                color: Colors.lightGreenAccent,
                              ),
                            ),
                            SizedBox(height: 15 * widget.imageScale),

                            // Story
                            Container(
                              padding: EdgeInsets.all(10 * widget.imageScale),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Text(
                                food['story'],
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 10 * widget.fontScale,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * widget.imageScale),

                  // Close Button
                  ElevatedButton(
                    onPressed: _closeDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * widget.imageScale,
                        vertical: 10 * widget.imageScale,
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Text(
                      'BACK TO GRID',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12 * widget.fontScale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Grid
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/arcade_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.all(10 * widget.imageScale),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4 * widget.imageScale,
              crossAxisSpacing: 4 * widget.imageScale,
            ),
            itemCount: 36,
            itemBuilder: (context, index) => _buildGridItem(index),
          ),
        ),

        // Title Banner
        Positioned(
          top: 20 * widget.imageScale,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 30 * widget.imageScale,
                vertical: 10 * widget.imageScale,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border.all(
                  color: Colors.amber,
                  width: 3 * widget.imageScale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 10 * widget.imageScale,
                  ),
                ],
              ),
              child: Text(
                'FOOD ARCADE - SELECT YOUR DISH',
                style: GoogleFonts.pressStart2p(
                  fontSize: 14 * widget.fontScale,
                  color: Colors.amber,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),

        // Detail Panel
        if (_showDetail) _buildDetailPanel(),
      ],
    );
  }
}