import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
class HeManContactSection extends StatefulWidget {
  const HeManContactSection({Key? key}) : super(key: key);

  @override
  _HeManContactSectionState createState() => _HeManContactSectionState();
}

class _HeManContactSectionState extends State<HeManContactSection>
    with TickerProviderStateMixin {
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _projectController = TextEditingController();

  // Form state
  bool _isSubmitted = false;
  bool _showSuccess = false;
  String _currentQuote = '';

  // Animation controllers
  late AnimationController _powerUpController;
  late AnimationController _swordSwingController;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // He-Man quotes
  final List<String> _heManQuotes = [
    'BY THE POWER OF GRAYSKULL!',
    'I HAVE THE POWER!',
    'FOR THE HONOR OF GRAYSKULL!',
    'LET THE POWER RETURN!',
    'GOOD JOURNEY!',
  ];

  // Social media links
  final List<Map<String, dynamic>> _socialLinks = [
  //  {'icon': 'images/facebook.png', 'url': 'https://linkedin.com', 'color': Colors.red, 'iconColor': Colors.blueAccent},
    {'icon': 'images/linkedin.png', 'url': 'https://www.linkedin.com/in/suresh-lama-151b92156/', 'color': Colors.red,'iconColor': Colors.blueAccent},
    {'icon': 'images/instagram.png', 'url': 'https://www.instagram.com/indradthor/', 'color': Colors.pink, 'iconColor': Colors.white},
    {'icon': 'images/whatsapp.png', 'url': 'https://api.whatsapp.com/send/?phone=9779841955416&text=Hello%2C+I+am+reaching+out+via+your+portfolio+website.+I+would+like+to+discuss+something+with+you.&type=phone_number&app_absent=0', 'color': Colors.green, 'iconColor': Colors.green},
    {'icon': 'images/youtube.png', 'url': 'https://www.youtube.com/@CodeWithYeti-b9f', 'color': Colors.red, 'iconColor': Colors.red},
    {'icon': 'images/medium.png', 'url': 'https://medium.com/@lamasuresh9841955416', 'color': Colors.orange,'iconColor': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    _powerUpController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _swordSwingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Set initial quote
    _updateQuote();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _projectController.dispose();
    _powerUpController.dispose();
    _swordSwingController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateQuote() {
    setState(() {
      _currentQuote = _heManQuotes[Random().nextInt(_heManQuotes.length)];
    });
  }

  Future<void> _playSound(String sound) async {
    await _audioPlayer.setAsset(sound);
    await _audioPlayer.play();
  }

  void _submitForm() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _projectController.text.isEmpty) {





      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'FILL ALL FIELDS, MORTAL!',
            style: GoogleFonts.pressStart2p(fontSize: 10),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      _playSound('assets/sounds/sword_clink.mp3');
      return;
    }

    _sendEmail();

    _playSound('assets/sounds/heman_yell.wav');
    _powerUpController.forward();

    setState(() {
      _isSubmitted = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSuccess = true;
      });
    });
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
${_projectController.text.trim()}
''';

    request.fields['subject'] = 'Message from Portfolio website developer section ';
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


  void _resetForm() {
    _playSound('assets/sounds/sword_swing.mp3');
    setState(() {
      _isSubmitted = false;
      _showSuccess = false;
      _nameController.clear();
      _emailController.clear();
      _projectController.clear();
    });
    _updateQuote();
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required Color color,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.black.withOpacity(0.5),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.pressStart2p(
          color: Colors.white,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.pressStart2p(
            color: color,
            fontSize: 10,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        maxLines: maxLines,
        onTap: () => _playSound('assets/sounds/sword_swing.mp3'),
      ),
    );
  }

  Widget _buildSocialButton(Map<String, dynamic> social, int index,) {
    return GestureDetector(
      onTap: () async {
        _playSound('assets/sounds/sword_swing.mp3');
        final url = social['url'];
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          border: Border.all(color: social['color'], width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          social['icon'],
          width: 24,
          height: 24,
          color: social['iconColor'],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
      Text(
      'SUMMON HE-MAN',
      style: GoogleFonts.pressStart2p(
        color: Colors.yellow,
        fontSize: 18,
        shadows: [
        Shadow(
        color: Colors.red,
        blurRadius: 10,
        offset: const Offset(2, 2),
        )],
      ),
    ),
    const SizedBox(height: 16),
    Text(
    _currentQuote,
    style: GoogleFonts.pressStart2p(
    color: Colors.yellow,
    fontSize: 12,
    ),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 24),
    _buildFormField(
    controller: _nameController,
    label: 'YOUR NAME:',
    color: Colors.cyan,
    ),
    _buildFormField(
    controller: _emailController,
    label: 'YOUR EMAIL:',
    color: Colors.orange,
    ),
    _buildFormField(
    controller: _projectController,
    label: 'YOUR PROJECT:',
    color: Colors.purple,
    maxLines: 3,
    ),
    const SizedBox(height: 24),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red[900],
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
    )),
    onPressed: _submitForm,
    child: Text(
    'SUMMON POWER!',
    style: GoogleFonts.pressStart2p(
    fontSize: 12,
    color: Colors.yellow,
    ),
    ),
    ),
    const SizedBox(height: 24),
    Text(
    'FIND ME ON:',
    style: GoogleFonts.pressStart2p(
    color: Colors.white,
    fontSize: 10,
    ),
    ),
    const SizedBox(height: 8),
    Wrap(
    alignment: WrapAlignment.center,
    children: _socialLinks.map((social) => _buildSocialButton(social, _socialLinks.indexOf(social))).toList(),
    ),
    ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: CurvedAnimation(
            parent: _powerUpController,
            curve: Curves.elasticOut,
          ),
          child: GifView.asset(
            'images/heman.gif',
            width: 300,
            height: 300,
          //  frameRate: FrameRate.max,
          ),
        ),
        const SizedBox(height: 24),
        if (_showSuccess) ...[
          Text(
            'MESSAGE SENT!',
            style: GoogleFonts.pressStart2p(
              color: Colors.yellow,
              fontSize: 18,
              shadows: [
                Shadow(
                    color: Colors.red,
                    blurRadius: 10,
                    offset: const Offset(2, 2)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'I SHALL ANSWER YOUR CALL SOON!',
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: _resetForm,
            child: Text(
              'SEND ANOTHER',
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/heman_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border.all(color: Colors.yellow, width: 4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isSubmitted ? _buildSuccessContent() : _buildFormContent(),
            ),
          ),
        ),
      ),
    );
  }
}