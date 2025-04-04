import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/testimonals.dart';

class TerminalTestimonials extends StatefulWidget {
  final List<Testimonial> testimonials;
  final VoidCallback? onBack;

  const TerminalTestimonials({
    Key? key,
    required this.testimonials,
    this.onBack,
  }) : super(key: key);

  @override
  State<TerminalTestimonials> createState() => _TerminalTestimonialsState();
}

class _TerminalTestimonialsState extends State<TerminalTestimonials>
    with TickerProviderStateMixin {
  late final AnimationController _cursorController;
  late final AnimationController _glowController;
  int? _selectedIndex;
  int _hoveredIndex = 0;
  final FocusNode _gridFocusNode = FocusNode();
  final FocusNode _detailFocusNode = FocusNode();
  bool _isTyping = false;
  bool _isGlowing = false;

  @override
  void initState() {
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,  // Now this works with multiple controllers
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,  // This is now allowed
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedIndex == null) {
        _gridFocusNode.requestFocus();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _glowController.dispose();
    // ... other disposals
    super.dispose();
  }

  void _viewTestimonial(int index) {
    setState(() {
      _isTyping = true;
      _selectedIndex = index;
      _isGlowing = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() => _isTyping = false);
        _detailFocusNode.requestFocus();
      });
    });
  }

  void _returnToDir() {
    setState(() {
      _selectedIndex = null;
      _isGlowing = false;
      _gridFocusNode.requestFocus();
    });
  }

  void _moveSelection(int xDelta, int yDelta) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isSmallScreen ? 3 : 4;

    setState(() {
      final newIndex = _hoveredIndex + xDelta + (yDelta * crossAxisCount);
      _hoveredIndex = newIndex.clamp(0, widget.testimonials.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final textStyle = GoogleFonts.ibmPlexMono(
      color: const Color(0xFF00FF00),
      fontSize: isSmallScreen ? 12 : 14,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: _isGlowing
              ? const Color(0xFF00FF00).withOpacity(_glowController.value)
              : const Color(0xFF00FF00),
          width: 2,
        ),
        boxShadow: _isGlowing
            ? [
          BoxShadow(
            color: const Color(0xFF00FF00).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar with animated underline
          Stack(
            children: [
              Text(
                "╔════TESTIMONIAL TERMINAL════╗",
                style: textStyle.copyWith(
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: const Color(0xFF00FF00).withOpacity(0.3),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 1,
                  color: const Color(0xFF00FF00).withOpacity(_glowController.value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Current path with typing animation
          Row(
            children: [
              Text(
                "C:\\testimonials> ",
                style: textStyle.copyWith(
                  color: const Color(0xFF00FF00).withOpacity(0.8),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _selectedIndex != null
                      ? "type ${widget.testimonials[_selectedIndex!].name.split(' ')[0]}.TXT"
                      : "dir /w",
                  key: ValueKey(_selectedIndex != null),
                  style: textStyle.copyWith(color: Colors.white),
                ),
              ),
              AnimatedBuilder(
                animation: _cursorController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cursorController.value,
                    child: Text("_", style: textStyle),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content area with animated transition
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: _selectedIndex != null
                  ? _buildDetailView(widget.testimonials[_selectedIndex!], isSmallScreen)
                  : _buildDirectoryView(isSmallScreen),
            ),
          ),

          // Footer navigation with animated buttons
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: _selectedIndex != null ? 0.7 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _selectedIndex != null
                      ? "[ESC] Back to directory"
                      : "[↑↓←→] Navigate   [ENTER] Select",
                  style: textStyle.copyWith(
                    color: const Color(0xFF00FF00).withOpacity(0.7),
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
              if (_selectedIndex != null || widget.onBack != null)
                MouseRegion(
                  onEnter: (_) => setState(() => _isGlowing = true),
                  onExit: (_) => setState(() => _isGlowing = false),
                  child: GestureDetector(
                    onTap: _selectedIndex != null ? _returnToDir : widget.onBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFF0000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: _isGlowing
                            ? const Color(0xFFFF0000).withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        "[ESC]",
                        style: textStyle.copyWith(
                          color: const Color(0xFFFF0000),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryView(bool isSmallScreen) {
    final crossAxisCount = isSmallScreen ? 3 : 4;

    return KeyboardListener(
      autofocus: true,
      focusNode: _gridFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowRight:
              _moveSelection(1, 0);
              break;
            case LogicalKeyboardKey.arrowLeft:
              _moveSelection(-1, 0);
              break;
            case LogicalKeyboardKey.arrowDown:
              _moveSelection(0, 1);
              break;
            case LogicalKeyboardKey.arrowUp:
              _moveSelection(0, -1);
              break;
            case LogicalKeyboardKey.enter:
              if (_hoveredIndex >= 0 && _hoveredIndex < widget.testimonials.length) {
                _viewTestimonial(_hoveredIndex);
              }
              break;
            case LogicalKeyboardKey.escape:
              widget.onBack?.call();
              break;
            default:
              break;
          }
        }
      },
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: widget.testimonials.length,
        itemBuilder: (context, index) {
          final name = widget.testimonials[index].name.split(' ')[0];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoveredIndex = index),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _viewTestimonial(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _hoveredIndex == index
                          ? Colors.yellow
                          : const Color(0xFF00FF00),
                      width: _hoveredIndex == index ? 2 : 1,
                    ),
                    color: _hoveredIndex == index
                        ? Colors.green.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _hoveredIndex == index
                        ? [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(_hoveredIndex == index ? 1.1 : 1.0),
                        child: CircleAvatar(
                          radius: isSmallScreen ? 18 : 22,
                          backgroundImage: AssetImage(widget.testimonials[index].photo),
                          backgroundColor: Colors.black,
                          child: _hoveredIndex == index
                              ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.yellow,
                                width: 2,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$name.TXT",
                        style: GoogleFonts.ibmPlexMono(
                          color: _hoveredIndex == index ? Colors.yellow : Colors.white,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: _hoveredIndex == index ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (_hoveredIndex == index)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.keyboard_return,
                            color: Colors.yellow,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailView(Testimonial t, bool isSmallScreen) {
    return KeyboardListener(
      focusNode: _detailFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          _returnToDir();
        }
      },
      child: GestureDetector(
        onTap: _returnToDir,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isTyping ? 0.5 : 1.0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with glow effect
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00FF00).withOpacity(_glowController.value * 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF00).withOpacity(_glowController.value * 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: isSmallScreen ? 40 : 48,
                        backgroundImage: AssetImage(t.photo),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Details with typing animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF00FF00).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "NAME: ${t.name.toUpperCase()}",
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ROLE: ${t.position.toUpperCase()}",
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quote with animated appearance
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00FF00),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Text(
                    '"${t.quote}"',
                    style: GoogleFonts.ibmPlexMono(
                      color: const Color(0xFF00FF00),
                      fontSize: isSmallScreen ? 14 : 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Back prompt
                AnimatedOpacity(
                  opacity: _isGlowing ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: const Color(0xFFFF0000),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Press ESC or click anywhere to return",
                        style: GoogleFonts.ibmPlexMono(
                          color: const Color(0xFFFF0000),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}