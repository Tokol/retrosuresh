import 'package:flutter/material.dart';
import 'package:suresh_portfilo/widgets/retro_screen_Wrapper.dart';

class TravellerModScreen extends StatefulWidget {
  final VoidCallback onBack;
  const TravellerModScreen({super.key, required this.onBack});

  @override
  State<TravellerModScreen> createState() => _TravellerModScreenState();
}

class _TravellerModScreenState extends State<TravellerModScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 600;
    final double fontScale = scaleFactor.clamp(0.8, 1.5);
    final double imageScale = scaleFactor.clamp(0.8, 1.2);
    return RetroScreenWrapper(
      title: 'TRAVELLER MODE',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [



            ],
          ),
        ),
      ),
    );
  }
}
