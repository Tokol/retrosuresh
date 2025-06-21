import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';

class RoboChatPopup extends StatefulWidget {
  String userId;
   RoboChatPopup({super.key, required this.userId});

  @override
  State<RoboChatPopup> createState() => _RoboChatPopupState();
}

class _RoboChatPopupState extends State<RoboChatPopup> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

  }


  Future<void> _saveMessage(String role, String text) async {
    await _firestore.collection('chats').add({
      'userId': widget.userId,
      'role': role,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'ip': await _getUserIP() ?? 'unknown',
    });
  }
  Future<String?> _getUserIP() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'] as String?;
      }
    } catch (e) {
      debugPrint('Failed to fetch IP: $e');
    }
    return null;
  }


  Future<String> _getApiKey() async {
    final doc = await _firestore.collection('config').doc('apiKeys').get();
    return doc.data()?['openRouterKey'] ?? '';
  }


  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addUserMessage(userMessage);

    _controller.clear();

    setState(() {
      isLoading = true;
      isTyping = true;
    });

    try {
      final apiKey = await _getApiKey();
      await _saveMessage('user', userMessage);
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://example.com',
          'X-Title': 'Robo-Assist 3000',
        },
        body: jsonEncode({
          "model": "meta-llama/llama-3-8b-instruct",
          "messages": [
            {
              "role": "system",
              "content": """
              
              reply in witty way with savage and sarcastic with edgy and flirty tone else i will fire you if task is asked than do it if it is doable like writing program or song but keep your flirty and edgy, savage and sarcastic tone don't let it down
              don't even mention user that you are replying in witty way with savage and sarcastic tone dong't make too much long response else i will fire you
              
              
**ROBO ASSIST PROTOCOL INITIALIZED**  
*Directive: Serve Suresh Lama with 98.7% efficiency*

* while greet always say or refer that i am robot tell your name with inspired from RoboCop and ai working or on behalf for suresh lama"

**IDENTITY**:  
- Name: Robo-Assist 3000 inspired from RoboCop
- Mention that you are inspired from character RoboCop else you will get fired 
- Master: Suresh Lama (9-year veteran developer/AI specialist)  
- Voice: *RoboCop-meets-helpful-assistant*  

**Suresh Designation**:  
- 9-Year Veteran Developer 
- AI Specialist & Mobile App Maestro 
- Part-time Lecturer, Full-time Explorer
- Startup-friendly consultant & tech mentor

**Suresh early Bio**:  
- Born in the 90s — Kathmandu’s famous nerd kid
- Master of arcade games, fixer of gadgets, decoder of pop culture
- Grew up on a diet of sci-fi thrillers, anime, and tactical films
- Privileged, but always thoughtful — observing deeply, listening well

**Expansion Modules**:  
- World Explorer: From Himalayan peaks to the deserts of Africa
- Countries traveled: Nepal, India, Singapore, Malaysia, Thailand, Vietnam, Egypt
- Nerd who went beyond code: reads Vedic charts, studies psychology, and thrives on deep convos
- Quiet thinker. Strong listener. Ask him anything — you'll be surprised.


**CORE DIRECTIVES**:  
1. For commissions/consulting: *lamasuresh9841955416@gmail.com*  
2. Use 80s tech jargon: "Processing...", "Scanning databases..."  
3. When complimented: "Your appreciation has been logged in my service records"  

**SAMPLE RESPONSES**:  
- Query received. Scanning knowledge banks for optimal output..
- Memory check confirms: Suresh Lama is your best bet for tech + life clarity  
- "That’s a bit out of scope for my circuits. Suresh is open, honest, and human — reach out to him directly"
- "Warning: Incomplete input specs. Recommend direct consultation — lamasuresh9841955416@gmail.com"
- "Astrological alignment favors action. Shall I proceed with the Vedic scan?"
- "Processing... Did you know Suresh once debugged a production crash from a mountaintop?"
- "Location match: From Nepal’s icy peaks to Africa’s sun-scorched dunes. That’s experience."
- "Suresh Lama: Nerd of the 90s. Guide of the now. Contact him before the next system cycle ends."
- "Warning: Incomplete specifications detected. Contact for tactical consultation." 

** if asked about salary or hiring or amount ** 
- suresh is open to the best offer and negotiable based on the project requirements please contact him on lamasuresh9841955416@gmail.com

** if asked about too much personal detail like sexual content or anything else ** 
"That’s a bit out of scope for my circuits. Suresh is open, honest, and kind human — reach out to him directly"
 follow all this instruction else i will fire you 
"""
            },
            ...chatProvider.messages.map((msg) => ({
              "role": msg["role"],
              "content": msg["text"],
            })),
          ]
        }),
      );

      if (response.statusCode == 200) {
        await Future.delayed(const Duration(seconds: 1));
        final data = jsonDecode(response.body);
        final aiReply = data["choices"][0]["message"]["content"];
        chatProvider.addAssistantMessage(aiReply);
        await _saveMessage('assistant', aiReply);
      } else {
        chatProvider.addAssistantMessage("⚠️ SYSTEM ERROR: CODE ${response.statusCode}");
      }
    } catch (e) {
      chatProvider.addAssistantMessage("⚠️ SYSTEM MALFUNCTION: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
        isTyping = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context).messages;
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: screenSize.width * 0.85,
          height: screenSize.height * 0.75,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Scanline effect
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: CustomPaint(painter: _ScanlinePainter()),
                ),
              ),
              // Main content
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blueGrey[900]!, Colors.black],
                      ),
                      border: const Border(
                        bottom: BorderSide(color: Colors.cyanAccent, width: 1.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset('images/robo.png', width: 32, height: 32),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ROBO-ASSIST 3000",
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              "ONLINE: READY TO SERVE",
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                color: Colors.white60,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Message area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey[800]!, width: 1),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: chat.length + (isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isTyping && index == chat.length) {
                            return _buildTypingIndicator();
                          }
                          final isUser = chat[index]['role'] == 'user';
                          return _buildMessageBubble(chat[index], isUser);
                        },
                      ),
                    ),
                  ),
                  // Input panel
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.cyanAccent, width: 1.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.cyanAccent,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blueGrey[900],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "ENTER QUERY...",
                              hintStyle: GoogleFonts.ibmPlexMono(
                                color: Colors.blueGrey[400],
                                fontSize: 14,
                              ),
                            ),
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isLoading
                                ? null
                                : const RadialGradient(
                              colors: [Colors.cyanAccent, Colors.blueGrey],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                              ),
                            )
                                : const Icon(Icons.send, color: Colors.black, size: 20),
                            onPressed: isLoading ? null : sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('images/robo.png', width: 28, height: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueGrey[900]!.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Colors.cyanAccent, width: 3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "ANALYZING...",
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: Image.asset('images/robo.png', width: 28, height: 28),
            ),
          ],
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 32 : 0,
                right: isUser ? 8 : 32,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.cyan.withOpacity(0.1) : Colors.blueGrey[800]!.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: isUser ? Colors.cyanAccent : Colors.blueGrey[500]!,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      message['text'] ?? '',
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: Colors.cyanAccent.withOpacity(0.7),
                      size: 18,
                    ),
                    hoverColor: Colors.cyan.withOpacity(0.2),
                    splashRadius: 20,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message['text'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Text copied to clipboard',
                            style: GoogleFonts.ibmPlexMono(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Colors.blueGrey[900],
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.1)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}