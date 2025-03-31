import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';

import '../pixel_border.dart';

class HeManContactSection extends StatefulWidget {
  const HeManContactSection({Key? key}) : super(key: key);

  @override
  _HeManContactSectionState createState() => _HeManContactSectionState();
}

class _HeManContactSectionState extends State<HeManContactSection>
    with TickerProviderStateMixin {
  // Form controllers
  final _yourNameOrOrgController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _projectTypeController = TextEditingController();
  final _projectDurationController = TextEditingController();
  final _offeringPriceController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Focus nodes for detecting when fields are selected
  final _yourNameOrOrgFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _contactNumberFocus = FocusNode();
  final _projectTypeFocus = FocusNode();
  final _projectDurationFocus = FocusNode();
  final _offeringPriceFocus = FocusNode();
  final _additionalNotesFocus = FocusNode();

  // Form field states
  bool _isYourNameOrOrgFilled = false;
  bool _isEmailFilled = false;
  bool _isContactNumberFilled = false;
  bool _isProjectTypeFilled = false;
  bool _isProjectDurationFilled = false;
  bool _isOfferingPriceFilled = false;
  bool _isAdditionalNotesFilled = false;

  // Spark effect states
  bool _showYourNameOrOrgSpark = false;
  bool _showEmailSpark = false;
  bool _showContactNumberSpark = false;
  bool _showProjectTypeSpark = false;
  bool _showProjectDurationSpark = false;
  bool _showOfferingPriceSpark = false;
  bool _showAdditionalNotesSpark = false;

  // Radio group states
  String? _projectScale = 'Startup';
  String? _projectReadiness = 'Ready to Start';
  String? _jobType = 'Project Basis';

  // He-Man quotes during form entry (visual only)
  String _currentQuote = '';
  final List<String> _heManQuotes = [
    'FOR ETERNIA!',
    'BY MY SWORD!',
    'POWER UP!',
    'I’M READY!',
    'LET’S GO!',
  ];

  // Form submission state
  bool _isSubmitted = false;
  bool _showSpeechBubble = false;

  // Button hover state
  bool _isButtonHovered = false;

  // Social media interaction states
  bool _showSocialSpark = false;
  Color _socialSparkColor = Colors.yellow;
  bool _showSwordSlash = false;
  double _swordSlashOffset = 0.0;
  bool _showSkeletor = false;
  bool _showSkeletorTaunt = false;
  bool _showSkull = false;
  double _skullOffset = 0.0;
  String _socialBattleCry = '';
  String _skeletorTaunt = '';
  String _heManResponse = '';
  int _tappedSocialIndex = -1;

  final List<String> _skeletorTaunts = [
    'YOU’LL NEVER WIN, HE-MAN!',
    'I’LL GET YOU!',
    'FOOLISH MORTAL!',
  ];

  final List<String> _heManResponses = [
    'NOT TODAY, SKELETOR!',
    'I HAVE THE POWER!',
    'FOR GRAYSKULL!',
  ];

  // Audio player using just_audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isImagePrecached = false;

  @override
  void initState() {
    super.initState();
    _yourNameOrOrgController.addListener(_updateYourNameOrOrgState);
    _emailController.addListener(_updateEmailState);
    _contactNumberController.addListener(_updateContactNumberState);
    _projectTypeController.addListener(_updateProjectTypeState);
    _projectDurationController.addListener(_updateProjectDurationState);
    _offeringPriceController.addListener(_updateOfferingPriceState);
    _additionalNotesController.addListener(_updateAdditionalNotesState);

    // Add listeners for focus changes to play sword_clink.mp3
    _yourNameOrOrgFocus.addListener(_playSwordClinkOnFocus);
    _emailFocus.addListener(_playSwordClinkOnFocus);
    _contactNumberFocus.addListener(_playSwordClinkOnFocus);
    _projectTypeFocus.addListener(_playSwordClinkOnFocus);
    _projectDurationFocus.addListener(_playSwordClinkOnFocus);
    _offeringPriceFocus.addListener(_playSwordClinkOnFocus);
    _additionalNotesFocus.addListener(_playSwordClinkOnFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isImagePrecached) {
      precacheImage(const AssetImage('images/heman_bg.jpg'), context);
      precacheImage(const AssetImage('images/heman.gif'), context);
      precacheImage(const AssetImage('images/linkden.png'), context);
      precacheImage(const AssetImage('images/instagram.png'), context);
      precacheImage(const AssetImage('images/whatsapp.png'), context);
      precacheImage(const AssetImage('images/youtube.png'), context);
      precacheImage(const AssetImage('images/medium.png'), context);
      _isImagePrecached = true;
    }
  }

  @override
  void dispose() {
    _yourNameOrOrgController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _projectTypeController.dispose();
    _projectDurationController.dispose();
    _offeringPriceController.dispose();
    _additionalNotesController.dispose();
    _yourNameOrOrgFocus.dispose();
    _emailFocus.dispose();
    _contactNumberFocus.dispose();
    _projectTypeFocus.dispose();
    _projectDurationFocus.dispose();
    _offeringPriceFocus.dispose();
    _additionalNotesFocus.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Form field state updates
  void _updateYourNameOrOrgState() {
    setState(() {
      _isYourNameOrOrgFilled = _yourNameOrOrgController.text.isNotEmpty;
      if (_isYourNameOrOrgFilled && !_showYourNameOrOrgSpark) {
        _showYourNameOrOrgSpark = true;
        _currentQuote = _heManQuotes[0];
      }
    });
  }

  void _updateEmailState() {
    setState(() {
      _isEmailFilled = _emailController.text.isNotEmpty;
      if (_isEmailFilled && !_showEmailSpark) {
        _showEmailSpark = true;
        _currentQuote = _heManQuotes[1];
      }
    });
  }

  void _updateContactNumberState() {
    setState(() {
      _isContactNumberFilled = _contactNumberController.text.isNotEmpty;
      if (_isContactNumberFilled && !_showContactNumberSpark) {
        _showContactNumberSpark = true;
        _currentQuote = _heManQuotes[2];
      }
    });
  }

  void _updateProjectTypeState() {
    setState(() {
      _isProjectTypeFilled = _projectTypeController.text.isNotEmpty;
      if (_isProjectTypeFilled && !_showProjectTypeSpark) {
        _showProjectTypeSpark = true;
        _currentQuote = _heManQuotes[3];
      }
    });
  }

  void _updateProjectDurationState() {
    setState(() {
      _isProjectDurationFilled = _projectDurationController.text.isNotEmpty;
      if (_isProjectDurationFilled && !_showProjectDurationSpark) {
        _showProjectDurationSpark = true;
        _currentQuote = _heManQuotes[4];
      }
    });
  }

  void _updateOfferingPriceState() {
    setState(() {
      _isOfferingPriceFilled = _offeringPriceController.text.isNotEmpty;
      if (_isOfferingPriceFilled && !_showOfferingPriceSpark) {
        _showOfferingPriceSpark = true;
        _currentQuote = _heManQuotes[0];
      }
    });
  }

  void _updateAdditionalNotesState() {
    setState(() {
      _isAdditionalNotesFilled = _additionalNotesController.text.isNotEmpty;
      if (_isAdditionalNotesFilled && !_showAdditionalNotesSpark) {
        _showAdditionalNotesSpark = true;
        _currentQuote = _heManQuotes[1];
      }
    });
  }

  void _playSwordClinkOnFocus() {
    if (_yourNameOrOrgFocus.hasFocus ||
        _emailFocus.hasFocus ||
        _contactNumberFocus.hasFocus ||
        _projectTypeFocus.hasFocus ||
        _projectDurationFocus.hasFocus ||
        _offeringPriceFocus.hasFocus ||
        _additionalNotesFocus.hasFocus) {
      _playSwordClink();
    }
  }

  void _playSubmission() async {
    await _audioPlayer.setAsset('heman_yell.wav');
    await _audioPlayer.play();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showSpeechBubble = true;
      });
    });
  }

  void _playSwordClink() async {
    await _audioPlayer.setAsset('sword_clink.mp3');
    await _audioPlayer.play();
  }

  void _submitForm() {
    if (_isYourNameOrOrgFilled &&
        _isEmailFilled &&
        _isContactNumberFilled &&
        _isProjectTypeFilled &&
        _isProjectDurationFilled &&
        _isOfferingPriceFilled) {
      setState(() {
        _isSubmitted = true;
      });
      _playSubmission();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all required fields!',
            style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSocialTap(int index, String url) async {
    setState(() {
      _tappedSocialIndex = index;
      _showSocialSpark = true;
      _showSwordSlash = true;
      _swordSlashOffset = 0.0;
      _showSkeletor = true;
      _showSkull = true;
      _skullOffset = 0.0;
      _socialBattleCry = _heManQuotes[Random().nextInt(_heManQuotes.length)];
      _skeletorTaunt = _skeletorTaunts[Random().nextInt(_skeletorTaunts.length)];
      _heManResponse = _heManResponses[Random().nextInt(_heManResponses.length)];

      switch (index) {
        case 0:
          _socialSparkColor = Colors.cyan;
          break;
        case 1:
          _socialSparkColor = Color(0xFFFF00FF);
          break;
        case 2:
          _socialSparkColor = Colors.green;
          break;
        case 3:
          _socialSparkColor = Colors.red;
          break;
        case 4:
          _socialSparkColor = Colors.orange;
          break;
      }
    });

    _playSwordClink();

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _swordSlashOffset += 2.0;
        if (_swordSlashOffset >= 20.0) {
          _showSwordSlash = false;
          timer.cancel();
        }
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showSkeletor = false;
        _showSkeletorTaunt = false;
      });

      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {
          _skullOffset += 2.0;
          if (_skullOffset >= 20.0) {
            _showSkull = false;
            timer.cancel();
          }
        });
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _socialBattleCry = _heManResponse;
        });
      });
    });

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/heman_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'SUMMON THE POWER OF GRAYSKULL!',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.yellow,
                        fontSize: 14,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_currentQuote.isNotEmpty && !_isSubmitted)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _currentQuote,
                        style: GoogleFonts.pressStart2p(
                          color: Colors.yellow,
                          fontSize: 10,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        _buildFormField(
                          controller: _yourNameOrOrgController,
                          focusNode: _yourNameOrOrgFocus,
                          label: 'YOUR NAME OR ORGANIZATION:',
                          color: Colors.cyan,
                          showSpark: _showYourNameOrOrgSpark,
                          sparkColor: Colors.yellow,
                        ),
                        _buildFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: 'EMAIL:',
                          color: Colors.blue,
                          showSpark: _showEmailSpark,
                          sparkColor: Colors.blue,
                        ),
                        _buildFormField(
                          controller: _contactNumberController,
                          focusNode: _contactNumberFocus,
                          label: 'CONTACT NUMBER:',
                          color: Colors.orange,
                          showSpark: _showContactNumberSpark,
                          sparkColor: Colors.orange,
                        ),
                        _buildFormField(
                          controller: _projectTypeController,
                          focusNode: _projectTypeFocus,
                          label: 'PROJECT TYPE (e.g., mobile app, website):',
                          color: Colors.red,
                          showSpark: _showProjectTypeSpark,
                          sparkColor: Colors.red,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: PixelBorderBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PROJECT SCALE:',
                                    style: GoogleFonts.pressStart2p(
                                      color: Colors.green,
                                      fontSize: 10,
                                    ),
                                  ),
                                  ...[
                                    'Startup',
                                    'Early Idea',
                                    'Running Operation',
                                    'Other'
                                  ].map((value) => RadioListTile<String>(
                                    title: Text(
                                      value,
                                      style: GoogleFonts.pressStart2p(
                                        color: Colors.green,
                                        fontSize: 8,
                                      ),
                                    ),
                                    value: value,
                                    groupValue: _projectScale,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _projectScale = newValue;
                                      });
                                    },
                                    activeColor: Colors.yellow,
                                  )).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildFormField(
                          controller: _projectDurationController,
                          focusNode: _projectDurationFocus,
                          label: 'PROJECT DURATION:',
                          color: Colors.purple,
                          showSpark: _showProjectDurationSpark,
                          sparkColor: Colors.purple,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: PixelBorderBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PROJECT READINESS:',
                                    style: GoogleFonts.pressStart2p(
                                      color: Colors.cyan,
                                      fontSize: 10,
                                    ),
                                  ),
                                  ...[
                                    'Ready to Start',
                                    'Still in Planning',
                                    'Exploring Feasibility'
                                  ].map((value) => RadioListTile<String>(
                                    title: Text(
                                      value,
                                      style: GoogleFonts.pressStart2p(
                                        color: Colors.cyan,
                                        fontSize: 8,
                                      ),
                                    ),
                                    value: value,
                                    groupValue: _projectReadiness,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _projectReadiness = newValue;
                                      });
                                    },
                                    activeColor: Colors.yellow,
                                  )).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: PixelBorderBox(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JOB TYPE:',
                                    style: GoogleFonts.pressStart2p(
                                      color: Colors.red,
                                      fontSize: 10,
                                    ),
                                  ),
                                  ...[
                                    'Project Basis',
                                    'Salary',
                                    'Equity',
                                    'Other'
                                  ].map((value) => RadioListTile<String>(
                                    title: Text(
                                      value,
                                      style: GoogleFonts.pressStart2p(
                                        color: Colors.red,
                                        fontSize: 8,
                                      ),
                                    ),
                                    value: value,
                                    groupValue: _jobType,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _jobType = newValue;
                                      });
                                    },
                                    activeColor: Colors.yellow,
                                  )).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildFormField(
                          controller: _offeringPriceController,
                          focusNode: _offeringPriceFocus,
                          label: 'OFFERING PRICE (currency & amount):',
                          color: Colors.yellow,
                          showSpark: _showOfferingPriceSpark,
                          sparkColor: Colors.yellow,
                        ),
                        _buildFormField(
                          controller: _additionalNotesController,
                          focusNode: _additionalNotesFocus,
                          label: 'ADDITIONAL NOTES:',
                          color: Colors.purple,
                          showSpark: _showAdditionalNotesSpark,
                          sparkColor: Colors.purple,
                          maxLines: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: MouseRegion(
                            cursor: _isSubmitted
                                ? SystemMouseCursors.basic
                                : SystemMouseCursors.click,
                            onEnter: (_) {
                              if (!_isSubmitted) {
                                setState(() {
                                  _isButtonHovered = true;
                                });
                              }
                            },
                            onExit: (_) {
                              setState(() {
                                _isButtonHovered = false;
                              });
                            },
                            child: GestureDetector(
                              onTap: _isSubmitted ? null : _submitForm,
                              child: PixelBorderBox(
                                borderColor: Colors.red,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: _isButtonHovered && !_isSubmitted
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.transparent,
                                    boxShadow: _isButtonHovered && !_isSubmitted
                                        ? [
                                      BoxShadow(
                                        color:
                                        Colors.red.withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Text(
                                    'UNLEASH THE POWER!',
                                    style: GoogleFonts.pressStart2p(
                                      color:
                                      _isSubmitted ? Colors.grey : Colors.red,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.black.withOpacity(0.3),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isLargeScreen ? 10 : 8,
                        runSpacing: isLargeScreen ? 10 : 8,
                        direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                        children: [
                          _buildSocialMediaIcon(
                            index: 0,
                            imagePath: 'images/linkden.png',
                            url: 'https://linkedin.com/in/yourprofile',
                            glowColor: Colors.cyan,
                          ),
                          _buildSocialMediaIcon(
                            index: 1,
                            imagePath: 'images/instagram.png',
                            url: 'https://instagram.com/yourprofile',
                            glowColor: Color(0xFFFF00FF),
                          ),
                          _buildSocialMediaIcon(
                            index: 2,
                            imagePath: 'images/whatsapp.png',
                            url: 'https://wa.me/yournumber',
                            glowColor: Colors.green,
                          ),
                          if (!isSmallScreen) ...[
                            _buildSocialMediaIcon(
                              index: 3,
                              imagePath: 'images/youtube.png',
                              url: 'https://youtube.com/yourchannel',
                              glowColor: Colors.red,
                            ),
                            _buildSocialMediaIcon(
                              index: 4,
                              imagePath: 'images/medium.png',
                              url: 'https://medium.com/@yourprofile',
                              glowColor: Colors.orange,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (isSmallScreen)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.black.withOpacity(0.3),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        direction: Axis.vertical,
                        children: [
                          _buildSocialMediaIcon(
                            index: 3,
                            imagePath: 'images/youtube.png',
                            url: 'https://youtube.com/yourchannel',
                            glowColor: Colors.red,
                          ),
                          _buildSocialMediaIcon(
                            index: 4,
                            imagePath: 'images/medium.png',
                            url: 'https://medium.com/@yourprofile',
                            glowColor: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  if (_socialBattleCry.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _socialBattleCry,
                        style: GoogleFonts.pressStart2p(
                          color: Colors.yellow,
                          fontSize: 10,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isSubmitted)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 40,
              top: MediaQuery.of(context).size.height / 2 - 40,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.black.withOpacity(0.5),
                child: GifView.asset(
                  'images/heman.gif',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          if (_isSubmitted && _showSpeechBubble)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 100,
              top: MediaQuery.of(context).size.height / 2 - 80,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'BY THE POWER OF GRAYSKULL, YOUR MESSAGE IS SENT!',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.yellow,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required Color color,
    required bool showSpark,
    required Color sparkColor,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          PixelBorderBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: maxLines,
                style: GoogleFonts.pressStart2p(
                  color: color,
                  fontSize: 10,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: GoogleFonts.pressStart2p(
                    color: color,
                    fontSize: 10,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          if (showSpark)
            Positioned(
              right: 8,
              top: 8,
              child: AnimatedOpacity(
                opacity: showSpark ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: sparkColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon({
    required int index,
    required String imagePath,
    required String url,
    required Color glowColor,
  }) {
    return GestureDetector(
      onTap: () => _onSocialTap(index, url),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.black, width: 2),
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 4,
              height: 4,
              color: Colors.red,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 4,
              height: 4,
              color: Colors.grey[800],
            ),
          ),
          Image.asset(
            imagePath,
            width: 12,
            height: 12,
          ),
          Positioned(
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                width: 8,
                height: 4,
                color: Colors.yellow.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border:
                Border.all(color: glowColor, width: 2, style: BorderStyle.solid),
              ),
            ),
          ),
          if (_showSocialSpark && _tappedSocialIndex == index)
            Positioned(
              right: 0,
              top: 0,
              child: AnimatedOpacity(
                opacity: _showSocialSpark ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _socialSparkColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          if (_showSwordSlash && _tappedSocialIndex == index)
            Positioned(
              left: _swordSlashOffset - 10,
              top: _swordSlashOffset - 10,
              child: Transform.rotate(
                angle: 45 * 3.14159 / 180,
                child: Container(
                  width: 10,
                  height: 20,
                  color: Colors.yellow,
                ),
              ),
            ),
          if (_showSkeletor && _tappedSocialIndex == index)
            Positioned(
              right: -10,
              bottom: -10,
              child: AnimatedOpacity(
                opacity: _showSkeletor ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 2,
                        top: 2,
                        child: Container(
                          width: 2,
                          height: 2,
                          color: Colors.yellow,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 2,
                          height: 2,
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showSkeletor && _tappedSocialIndex == index)
            Positioned(
              right: -60,
              bottom: 10,
              child: AnimatedOpacity(
                opacity: _showSkeletor ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    _skeletorTaunt,
                    style: GoogleFonts.pressStart2p(
                      color: Colors.purple,
                      fontSize: 6,
                    ),
                  ),
                ),
              ),
            ),
          if (_showSkull && _tappedSocialIndex == index)
            Positioned(
              right: -_skullOffset,
              bottom: -_skullOffset,
              child: AnimatedOpacity(
                opacity: _showSkull ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 4,
                  height: 4,
                  color: Colors.purple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}