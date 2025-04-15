import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:suresh_portfilo/widgets/space_invaders/space_invaders_form.dart';
import 'package:suresh_portfilo/widgets/space_invaders/space_invaders_game.dart';
import 'package:http/http.dart' as http;

class SpaceInvadersMessageBlaster extends StatefulWidget {
  final double scale;

  const SpaceInvadersMessageBlaster({
    super.key,
    this.scale = 1.0,
  });

  @override
  State<SpaceInvadersMessageBlaster> createState() =>
      _SpaceInvadersMessageBlasterState();
}

class _SpaceInvadersMessageBlasterState
    extends State<SpaceInvadersMessageBlaster> with TickerProviderStateMixin {
  // Form state
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  // Screen state
  bool _isGameScreen = false;
  bool _isSuccess = false;

  // Animation controllers
  late AnimationController _flickerController;
  late AnimationController _projectileController;
  late AnimationController _explosionController;

  // Game state
  double _spaceshipX = 0.5; // Static position
  double _alienX = 0.5; // Static position
  double? _projectileY; // For bullet (upward)
  bool _isProjectileFired = false;

  // Audio players
  late AudioPlayer _laserPlayer;
  late AudioPlayer _explosionPlayer;
  late AudioPlayer _jinglePlayer;
  late AudioPlayer _typingPlayer;
  late AudioPlayer _errorPlayer;

  // Dynamic scale factor based on screen size
  late double _dynamicScale;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudio();
  }

  Future<void> _initializeAnimations() async {
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _projectileController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Slow bullet movement
    )..addListener(() {
      setState(() {
        _projectileY = 1.0 - _projectileController.value; // Bullet moves upward
        if (_projectileY != null && _projectileY! < 0.1) {
          debugPrint('Bullet hit alien');
          _projectileController.stop();
          _isProjectileFired = false;
          _projectileY = null;
          _explosionController.forward();
          _explosionPlayer.play();
        }
      });
    });

    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slower explosion animation (1 second)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('Explosion completed, showing MESSAGE SENT!');
        setState(() => _isSuccess = true);
        _jinglePlayer.play();
      }
    });
  }

  Future<void> _initializeAudio() async {
    _laserPlayer = AudioPlayer();
    _explosionPlayer = AudioPlayer();
    _jinglePlayer = AudioPlayer();
    _typingPlayer = AudioPlayer();
    _errorPlayer = AudioPlayer();

    try {
      await _laserPlayer.setAsset('assets/laser_shoot.wav');
      await _explosionPlayer.setAsset('assets/explosion.wav');
      await _jinglePlayer.setAsset('assets/success.wav');
      await _typingPlayer.setAsset('assets/ckack.m4a');
      await _errorPlayer.setAsset('assets/error_bleep.flac');
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _projectileController.dispose();
    _explosionController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _laserPlayer.dispose();
    _explosionPlayer.dispose();
    _jinglePlayer.dispose();
    _typingPlayer.dispose();
    _errorPlayer.dispose();
    super.dispose();
  }

  void _launchGame() {
    if (_formKey.currentState!.validate()) {
      // Reset all game states
      _sendEmail();
      _explosionController.reset();
      _projectileController.reset();

      setState(() {
        _isGameScreen = true;
        _isSuccess = false;
        _spaceshipX = 0.5;
        _alienX = 0.5;
        _projectileY = null;
        _isProjectileFired = false;
      });

      // Start bullet animation automatically
      _fireProjectile();

      // Force a frame update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    } else {
      _errorPlayer.play();
    }
  }


  Future<void> _sendEmail() async {
    final uri = Uri.parse('https://emailserver.walkershive.com.np/api/email/send');



    final request = http.MultipartRequest('POST', uri);
    request.fields['token'] = 'S2JEtxvSeelRWpEolVCnYd5kVThLRc1FVpDw1ZaOWVNSiZ3B3imuGG18bO87';
    request.fields['mail_to_address'] = 'lamasuresh9841955416@gmail.com'; // you can change this to fixed or input
    request.fields['mail_data'] = '''
Name: ${_nameController.text.trim()}
Email: ${_emailController.text.trim()}

Message:
${_messageController.text.trim()}
''';

    request.fields['subject'] = 'Message from Portfolio website contact section ';
    request.fields['mail_category'] = '1'; // assuming '1' is default category
    request.fields['cc[]'] = 'lamasuresh9841955416@gmail.com';

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully');
      } else {
        debugPrint('❌ Failed to send email. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error sending email: $e');
    }
  }


  void _fireProjectile() {
    if (!_isProjectileFired) {
      debugPrint('Firing bullet');
      _isProjectileFired = true;
      _projectileY = 1.0;
      _projectileController.forward(from: 0.0);
      _laserPlayer.play();
    }
  }

  void _resetForm() {
    setState(() {
      _isGameScreen = false;
      _isSuccess = false;
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    });
  }

  Future<void> _playTypingSound() async {
    try {
      await _typingPlayer.seek(Duration.zero);
      await _typingPlayer.play();
    } catch (e) {
      debugPrint('Error playing typing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic scale based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    _dynamicScale = widget.scale * (screenWidth / 600);

    // Calculate game height
    final screenHeight = MediaQuery.of(context).size.height;
    final gameHeight = screenHeight * 0.8;

    return _isGameScreen
        ? SizedBox(
      height: gameHeight,
      width: double.infinity,
      child: SpaceInvadersGame(
        dynamicScale: _dynamicScale,
        spaceshipX: _spaceshipX,
        alienX: _alienX,

        isSuccess: _isSuccess,

        onResetForm: _resetForm,
      ),
    )
        : SpaceInvadersForm(
      flickerController: _flickerController,
      dynamicScale: _dynamicScale,
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      messageController: _messageController,
      onLaunch: _launchGame,
      onTyping: () {
        setState(() {});
        _playTypingSound();
      },
    );
  }
}