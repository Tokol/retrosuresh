import 'package:flutter/material.dart';
import 'package:suresh_portfilo/widgets/developer_contact/arcade_marquee.dart';
import 'package:suresh_portfilo/widgets/heman/heman_contact.dart';
import 'package:suresh_portfilo/widgets/ninjaturtle/ninja_service.dart';
import 'package:suresh_portfilo/widgets/retro_screen_Wrapper.dart';
import 'package:suresh_portfilo/widgets/streetfighter/StreetFighterSkills.dart';
import 'package:suresh_portfilo/widgets/testimonal_widget.dart';
import 'package:suresh_portfilo/widgets/zelda/skill_invetory.dart';

import 'data/datas.dart';
import 'widgets/space_invaders/space_services.dart';

class DeveloperModScreen extends StatefulWidget {
  final VoidCallback onBack;
  const DeveloperModScreen({super.key, required this.onBack});

  @override
  State<DeveloperModScreen> createState() => _DeveloperModScreenState();
}

class _DeveloperModScreenState extends State<DeveloperModScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scaleFactor = size.width / 600;
    final double fontScale = scaleFactor.clamp(0.8, 1.5);
    final double imageScale = scaleFactor.clamp(0.8, 1.2);

    return RetroScreenWrapper(
      title: 'DEVELOPER MODE',
      onBack: widget.onBack,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.8, // Constrain height to avoid overflow
                child: SkillInventory(),
              ),

              SizedBox(
                height: size.height * 0.8, // Constrain height to avoid overflow
                child:  TurtleServices(),
              ),


              ArcadeTestimonialWidget( // Add the new section here
                scale: 1.2,
                testimonials: collegeTestimonials,
              ),

             // HeManContactSection(),
              SizedBox(
                height: size.height * 0.8, // Constrain height to avoid overflow
                child: HeManContactSection(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}