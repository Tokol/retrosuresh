import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:suresh_portfilo/models/testimonals.dart';

class TetrisBlock extends StatefulWidget {
  final Testimonial testimonial;
  final int index;
  final AudioPlayer audioPlayer;
  final String blockType;

  const TetrisBlock({
    Key? key,
    required this.testimonial,
    required this.index,
    required this.audioPlayer,
    required this.blockType,
  }) : super(key: key);

  @override
  State<TetrisBlock> createState() => _TetrisBlockState();
}

class _TetrisBlockState extends State<TetrisBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fallAnimation;
  late Animation<double> _rotateAnimation;
  bool _showDetails = false;

  final _colors = {
    'I': Colors.cyan,
    'J': Colors.blue,
    'L': Colors.orange,
    'O': Colors.yellow,
    'S': Colors.green,
    'T': Colors.purple,
    'Z': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000 + (widget.index * 300)),
      vsync: this,
    );

    _fallAnimation = Tween(begin: -200.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    _rotateAnimation = Tween(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) {
            setState(() => _showDetails = true);
          }
        });
        _playSound();
      }
    });
  }

  Future<void> _playSound() async {
    try {
      await widget.audioPlayer.seek(Duration.zero);
      await widget.audioPlayer.play();
    } catch (e) {
      debugPrint("Sound error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blockColor = _colors[widget.blockType]!;
    final isSmall = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _fallAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: GestureDetector(
              onTap: () {
                if (_controller.isCompleted) {
                  setState(() => _showDetails = !_showDetails);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: blockColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _showDetails
                    ? _buildTestimonialContent(blockColor, isSmall)
                    : Center(
                  child: Text(
                    widget.blockType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'PressStart2P',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestimonialContent(Color blockColor, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Photo
          Container(
            width: isSmall ? 24 : 32,
            height: isSmall ? 24 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: ClipOval(
              child: Image.asset(
                widget.testimonial.photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Name
          Text(
            widget.testimonial.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 10 : 12,
              fontFamily: 'PressStart2P',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Quote
          Text(
            widget.testimonial.quote,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 8 : 10,
              fontFamily: 'PressStart2P',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Position
          Text(
            widget.testimonial.position,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmall ? 7 : 9,
              fontFamily: 'PressStart2P',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}