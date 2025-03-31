import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/datas.dart';
import '../pixel_border.dart';

class SkillInventory extends StatefulWidget {
  const SkillInventory({super.key});

  @override
  State<SkillInventory> createState() => _SkillInventoryState();
}

class _SkillInventoryState extends State<SkillInventory> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = skillInventory.isNotEmpty ? skillInventory[0]["name"] : null;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/zelda_map.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isSmallScreen
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildGrid(crossAxisCount),
                      const SizedBox(height: 16),
                      _buildDescriptionBox(),
                    ],
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildGrid(crossAxisCount),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildDescriptionBox(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 400) return 3;
    if (width < 600) return 4;
    return 6;
  }

  Widget _buildGrid(int crossAxisCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "SKILL INVENTORY",
          style: GoogleFonts.pressStart2p(
            fontSize: 20,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(height: 16),
        PixelBorderBox(
          borderColor: Colors.cyan,
          padding: const EdgeInsets.all(6),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: skillInventory.length,
            itemBuilder: (context, index) {
              final item = skillInventory[index];
              return _buildItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final isSelected = _selectedItem == item["name"];
    final isSword = item["icon"] == "images/sword.png"; // Check if this is the sword item

    return MouseRegion(
      cursor: isSword ? SystemMouseCursors.click : MouseCursor.defer, // Custom cursor for sword
      child: GestureDetector(
        onTap: () {
          _audioPlayer.setVolume(0.03);
          _audioPlayer.play(AssetSource('zelda_item.wav'));
          setState(() => _selectedItem = item["name"]);
        },
        child: PixelBorderBox(
          borderColor: isSelected ? (item["color"] as Color) : Colors.grey,
          padding: const EdgeInsets.all(1.5),
          child: Image.asset(
            item["icon"] as String? ?? "images/default_icon.png",
            width: 9,
            height: 9,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.error, size: 8, color: item["color"] as Color),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionBox() {
    if (_selectedItem == null || skillInventory.isEmpty) {
      return const SizedBox.shrink();
    }
    final item = skillInventory.firstWhere(
          (i) => i["name"] == _selectedItem,
      orElse: () => skillInventory[0],
    );

    return PixelBorderBox(
      borderColor: item["color"] as Color,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                "images/zelda_icon.png",
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 16),
              ),
              const SizedBox(width: 6),
              Image.asset(
                item["icon"] as String? ?? "images/default_icon.png",
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(children: [
            Flexible(

              child: Text(
                item["name"] as String? ?? "Unknown Skill",
                style: GoogleFonts.pressStart2p(
                  fontSize: 24,
                  color: item["color"] as Color,
                ),
              ),
            ),

            Image.asset(
               "images/sword.png",
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 16),
            ),

          ],),
          const SizedBox(height: 6),
          Text(
            item["description"] as String? ?? "No description",
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "USE: ${item["use"] as String? ?? "No use specified"}",
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 6),
       Row(children: [
         Image.asset(
           "images/sheild.png",
           width: 32,
           height: 32,
           errorBuilder: (context, error, stackTrace) =>
           const Icon(Icons.error, size: 16),
         ),

         Flexible(
         child: Container(
           width: 90,
           height: 9,
           child: LinearProgressIndicator(
             value: (item["mastery"] as int? ?? 0) / 100,
             backgroundColor: Colors.grey,
             valueColor: AlwaysStoppedAnimation<Color>(item["color"] as Color),
           ),
         ),
       ),],),
          const SizedBox(height: 4),
          Text(
            "${item["mastery"] as int? ?? 0}%",
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}