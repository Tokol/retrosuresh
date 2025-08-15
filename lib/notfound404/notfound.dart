// lib/pages/not_found_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:suresh_portfilo/widgets/retro_screen_Wrapper.dart';

enum _Phase { attract, blow, insert, boot }

class NotFoundPage extends StatefulWidget {
  final String requested;
  const NotFoundPage({super.key, required this.requested});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage>
    with TickerProviderStateMixin {
  _Phase phase = _Phase.attract;
  bool muted = false;

  // Blow mini-game
  double meter = 0.0;
  final rnd = Random();
  final List<_Dust> dust = [];

  // Insert animation
  late final AnimationController insertCtrl;
  late final Animation<double> insertAnim;

  // Boot text
  final List<String> bootLines = [];
  int _bootStep = 0;
  Timer? _bootTimer;

  // Text scale
  final double textScale = 1.2;

  // --- Audio (just_audio like your He-Man file) ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _puffs = const [
    'assets/sounds/puff_01.wav',
    'assets/sounds/puff_02.wav',
    'assets/sounds/puff_03.wav',
  ];

  @override
  void initState() {
    super.initState();
    insertCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    insertAnim =
        CurvedAnimation(parent: insertCtrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    insertCtrl.dispose();
    _bootTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String asset, {double volume = 1}) async {
    if (muted) return;
    try {
      await _audioPlayer.setAsset(asset);
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play();
    } catch (_) {}
  }

  void _startBlow() {
    setState(() => phase = _Phase.blow);
    _playSound('assets/sounds/404_coin.wav', volume: .9);
  }

  void _blowOnce() {
    if (phase != _Phase.blow) return;
    final inc = 0.10 + rnd.nextDouble() * 0.12;
    setState(() {
      meter = (meter + inc).clamp(0.0, 1.0);
      dust.add(_Dust(
        key: UniqueKey(),
        x: rnd.nextDouble() * 0.6 + 0.2,
        vy: -(0.6 + rnd.nextDouble() * 0.8),
        lifeMs: 500 + rnd.nextInt(500),
        size: 12 + rnd.nextInt(10),
      ));
    });
    _playSound(_puffs[rnd.nextInt(_puffs.length)], volume: .9);
    _playSound('assets/sounds/tick_blip.wav', volume: .35);
  }

  Future<void> _insertCart() async {
    setState(() => phase = _Phase.insert);
    await insertCtrl.forward();
    await _playSound('assets/sounds/insert_kachunk.wav', volume: 1);
    _startBoot();
  }

  void _startBoot() {
    setState(() {
      phase = _Phase.boot;
      bootLines.clear();
      _bootStep = 0;
    });
    _bootTimer?.cancel();
    _bootTimer =
        Timer.periodic(const Duration(milliseconds: 550), (Timer t) {
          setState(() {
            if (_bootStep == 0) {
              bootLines.add(
                  'BOOT> CHECKING ${widget.requested.isEmpty ? '/' : widget.requested}');
              _playSound('assets/sounds/boot_beep.wav', volume: .7);
            } else if (_bootStep == 1) {
              bootLines.add('ERROR: LEVEL 404');
              _playSound('assets/sounds/boot_beep.wav', volume: .5);
            } else if (_bootStep == 2) {
              bootLines.add('ACTION: RETURN TO BASE');
              _playSound('assets/sounds/boot_beep.wav', volume: .5);
            } else {
              t.cancel();
            }
            _bootStep++;
          });
        });
  }

  // viewport helper
  double _vh(BuildContext c, double frac) =>
      MediaQuery.sizeOf(c).height * frac;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final pressTextTheme = GoogleFonts.pressStart2pTextTheme(base.textTheme);
    final themed = base.copyWith(
      textTheme: pressTextTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          textStyle:
          MaterialStatePropertyAll<TextStyle?>(pressTextTheme.labelLarge),
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle:
          MaterialStatePropertyAll<TextStyle?>(pressTextTheme.labelLarge),
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
    );

    // Select current page section
    final body = switch (phase) {
      _Phase.attract => _buildAttract(),
      _Phase.blow => _buildBlow(),
      _Phase.insert => _buildInsert(),
      _Phase.boot => _buildBoot(),
    };

    return Theme(
      data: themed,
      child: Stack(
        children: [
          _overlay('images/crt_vignette.png', opacity: .12),
          _overlay('images/crt_scanlines.png', opacity: .08),

          // --- SCROLLABLE CENTER to prevent overflow ---
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey(phase),
                          child: body,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Mute toggle
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              richMessage: TextSpan(
                text: muted ? 'Sound off' : 'Sound on',
                style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.yellow),
              ),
              decoration: BoxDecoration(
                color: const Color(0xCC000000),
                border: Border.all(color: Colors.yellow, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                onPressed: () => setState(() => muted = !muted),
                icon: _soundIcon(muted),
              ),
            )
          ),
        ],
      ),
    );
  }

  // === Sections ===

  Widget _buildAttract() {
    final path = widget.requested.isEmpty ? '/' : widget.requested;

    return Column(
      key: const ValueKey('attract'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decorative 4-0-4 coins
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image('images/coin_4.png', size: 56),
            const SizedBox(width: 12),
            _image('images/coin_0.png', size: 56),
            const SizedBox(width: 12),
            _image('images/coin_4.png', size: 56),
          ],
        ),
        const SizedBox(height: 16),

        _titleArt(),
        const SizedBox(height: 10),

        Text(
          'We couldn’t find: $path',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 11 * textScale,
            color: const Color(0xFF0F172A), // slate-900 / charcoal
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(.20),
                offset: const Offset(0, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),


        const SizedBox(height: 20),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: _startBlow,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image('images/coin_0.png', size: 18),
                  const SizedBox(width: 8),
                  const Text('INSERT COIN'),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (_) => false),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image('images/icon_home.png', size: 16),
                  const SizedBox(width: 8),
                  const Text('Go Home'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),
        _image('images/cartridge.png', width: 280, height: 240, fallbackBox: true),
      ],
    );
  }

  Widget _buildBlow() {
    final artH = min(220.0, _vh(context, .35));

    return Column(
      key: const ValueKey('blow'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _titleArt(small: true),
        const SizedBox(height: 6),
        Text(
          'Clean the cart: ${widget.requested.isEmpty ? '/' : widget.requested}',
          style:
          GoogleFonts.pressStart2p(fontSize: 11 * textScale, color: Colors.white70),
        ),
        const SizedBox(height: 18),

        SizedBox(
          height: artH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 24,
                child: _image('images/console_slot.png',
                    width: 520, height: 120, fallbackBox: true),
              ),
              Positioned(
                bottom: 120,
                child: _image('images/cartridge.png',
                    width: 260, height: 220, fallbackBox: true),
              ),
              ...dust.map((d) => _DustWidget(
                dust: d,
                onDone: () => setState(() => dust.remove(d)),
              )),
            ],
          ),
        ),

        SizedBox(
          width: 480,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: meter,
              minHeight: 14,
              backgroundColor: Colors.white10,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: _blowOnce,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Text('BLOW'),
              ),
            ),
            FilledButton(
              onPressed: (meter >= 1.0) ? _insertCart : null,
              child: const Text('INSERT CARTRIDGE'),
            ),
            OutlinedButton(
              onPressed: () => setState(() {
                meter = 0;
                dust.clear();
              }),
              child: const Text('Reset'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (_) => false),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsert() {
    final artH = min(240.0, _vh(context, .38));

    return Column(
      key: const ValueKey('insert'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _titleArt(small: true),
        const SizedBox(height: 18),
        SizedBox(
          height: artH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 24,
                child: _image('images/console_slot.png',
                    width: 540, height: 130, fallbackBox: true),
              ),
              AnimatedBuilder(
                animation: insertAnim,
                builder: (_, __) {
                  final dy = 120 * (1 - insertAnim.value);
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: _image('images/cartridge.png',
                        width: 280, height: 230, fallbackBox: true),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Inserting…',
            style: GoogleFonts.pressStart2p(
                fontSize: 11 * textScale, color: Colors.white60)),
      ],
    );
  }

  Widget _buildBoot() {
    return Column(
      key: const ValueKey('boot'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _titleArt(small: true),
        const SizedBox(height: 14),
        Container(
          width: 560,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          alignment: Alignment.centerLeft,
          child: DefaultTextStyle(
            style: GoogleFonts.pressStart2p(
              fontSize: 11 * textScale,
              color: Colors.cyanAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bootLines.map((l) => Text(
                l,
                style: GoogleFonts.pressStart2p(
                  fontSize: 11 * textScale,
                  color: const Color(0xFF22D3EE),
                ),
              )).toList(),

            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (_) => false),
              child: const Text('Back to Home'),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  phase = _Phase.attract;
                  meter = 0;
                  dust.clear();
                  insertCtrl.value = 0;
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      ],
    );
  }

  // === Helpers ===

  Widget _titleArt({bool small = false}) {
    // If images/title_404.png exists it shows; otherwise fallback text.
    final w = small ? 340.0 : 520.0;
    final h = small ? 120.0 : 180.0;
    return _image(
      'images/title_404.png',
      width: w,
      height: h,
      fallbackText: Column(
        children: [
          Text(
            'CARTRIDGE MISSING',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 12 * textScale,
              color: Colors.yellow,
              shadows: [Shadow(color: Colors.red.withOpacity(.7), blurRadius: 10)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlay(String asset, {double opacity = .1}) {
    return Positioned.fill(
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        opacity: AlwaysStoppedAnimation(opacity),
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _image(
      String asset, {
        double? width,
        double? height,
        double? size,
        bool fallbackBox = false,
        Widget? fallbackText,
      }) {
    return Image.asset(
      asset,
      width: size ?? width,
      height: size ?? height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        if (fallbackText != null) return fallbackText;
        if (!fallbackBox) return const SizedBox.shrink();
        return Container(
          width: size ?? width ?? 120,
          height: size ?? height ?? 120,
          decoration: BoxDecoration(
            color: Colors.white10,
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _soundIcon(bool isMuted) {
    return Image.asset(
      isMuted ? 'images/icon_sound_off.png' : 'images/icon_sound_on.png',
      width: 28,
      height: 28,
      errorBuilder: (_, __, ___) => Icon(
        isMuted ? Icons.volume_off : Icons.volume_up,
        color: Colors.white,
      ),
    );
  }
}

// ===== Dust puff =====

class _Dust {
  final Key key;
  final double x;   // 0..1 across width
  final double vy;  // negative goes up
  final int lifeMs;
  final int size;   // px
  _Dust({required this.key, required this.x, required this.vy, required this.lifeMs, required this.size});
}

class _DustWidget extends StatefulWidget {
  final _Dust dust;
  final VoidCallback onDone;
  const _DustWidget({required this.dust, required this.onDone});

  @override
  State<_DustWidget> createState() => _DustWidgetState();
}

class _DustWidgetState extends State<_DustWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.dust.lifeMs),
    );
    c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
    c.forward();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        final y = 80 + (-widget.dust.vy * 80.0 * c.value);
        final a = 1 - c.value;
        return Positioned(
          key: widget.dust.key,
          left: (widget.dust.x * MediaQuery.of(context).size.width) -
              widget.dust.size / 2,
          bottom: y,
          child: Opacity(
            opacity: a.clamp(0.0, 1.0),
            child: Image.asset(
              'images/dust_01.png',
              width: widget.dust.size.toDouble(),
              height: widget.dust.size.toDouble(),
              errorBuilder: (_, __, ___) => Icon(
                Icons.blur_on,
                size: widget.dust.size.toDouble(),
                color: Colors.white24,
              ),
            ),
          ),
        );
      },
    );
  }
}
