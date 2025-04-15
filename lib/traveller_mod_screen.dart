// traveller_mod_screen.dart
import 'package:flutter/material.dart';
import 'package:suresh_portfilo/widgets/foodie_section.dart';
import 'package:suresh_portfilo/widgets/mono_no_aware_intro.dart';
import 'package:suresh_portfilo/widgets/retro_mail_drop.dart';
import 'package:suresh_portfilo/widgets/retro_screen_Wrapper.dart';
import 'package:suresh_portfilo/widgets/world_map_hub.dart';


class TravellerModScreen extends StatefulWidget {
  final VoidCallback onBack;
  const TravellerModScreen({super.key, required this.onBack});

  @override
  State<TravellerModScreen> createState() => _TravellerModScreenState();
}

class _TravellerModScreenState extends State<TravellerModScreen> {
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    // Hide intro after 12 seconds

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 600;
    final double fontScale = scaleFactor.clamp(0.8, 1.5);
    final double imageScale = scaleFactor.clamp(0.8, 1.2);

    return RetroScreenWrapper(
      title: 'TRAVELLER MODE',
      onBack: widget.onBack,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20 * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.8,
                    child: WorldMapHub(
                      fontScale: fontScale,
                      imageScale: imageScale,
                    ),
                  ),



                  SizedBox(
                    height: size.height * 0.8,
                    child: RetroPostcard(

                      fontScale: fontScale,
                      imageScale: imageScale,
                    ),
                  ),


              // SizedBox(height: 100,
              //     width: size.width,
              // child: Image.network('https://static.vecteezy.com/system/resources/previews/005/266/448/non_2x/retro-futuristic-background-free-vector.jpg', fit: BoxFit.cover),
              // ),
              //
              // SizedBox(
              //   height: size.height * 0.6,
              //   child: FoodieArcadeGrid(
              //     fontScale: fontScale,
              //     imageScale: imageScale,
              //   ),)
                  // Add more sections (Trekking, Postcards, etc.) here later
                ],
              ),

            ),
          ),
          if (_showIntro)
            MonoNoAwareIntro(
              onComplete: () {
                if (mounted) {
                  setState(() => _showIntro = false);
                }
              },
            ),
        ],
      ),
    );
  }
}