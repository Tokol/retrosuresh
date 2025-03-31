import 'package:flutter/material.dart';
final List<String> storyText = [
  "I started as a curious student and ended up addicted—to teaching! Now, I turn mobile programming into an adventure, where every line of code sparks excitement.",

  "Forget snooze-fest lectures and theory overload—I run my classes like real-world coding war rooms. We don’t just ‘learn’; we hunt down problems (straight from GitHub) and crack them like detectives, turning ideas into slick, working apps.",

  "Meme generators? Check. Apps inspired by Harry Potter and Stranger Things? Absolutely. Whiteboards? Barely touched. Instead, we code, debug, and build apps that make learning feel like a game.",

  "No one wants to miss my class—because why would they? Ready to ditch the boring and build something amazing? Let’s code!"
];


final List<Map<String, String>> colleges = [
  {
    'name': 'Institute of Crisis Management Studies (ICMS) | Samarpan Academy',
    'course': 'Mobile Programming',
    'affiliation': 'Tribhuvan University',
    'semester': 'BCA 6th Semester',
    'photo': 'images/icms.jpeg',
  },
  {
    'name': 'London College',
    'course': 'Android Mobile Development ',
    'affiliation': 'University of Sunderland',
    'semester': 'L6 Batch (Final Year)',
    'photo': 'images/london.jpg',
  },
  {
    'name': 'Padmashree College',
    'course': 'Mobile Programming',
    'affiliation': 'Tribhuvan University',
    'semester': 'BCA 6th Semester',
    'photo': 'images/padmashree.jpg',
  },
];


final List<Map<String, String>> collegeTestimonials = [
  {
    'name': 'Nabin Mahara',
    'text': 'Suresh Lama Sir makes coding an adventure! With witty analogies and hands-on projects, he turns complex concepts into "Aha!" moments. Engaging, inspiring, and pure gold—5/5 stars!',
    'avatar': 'images/student1.webp',
    'position': 'London College, Final Year Student 2025',
  },

  {
    'name': 'Colleague C',
    'text': 'A true professional with passion!',
    'avatar': 'images/student3.webp',
    'position': 'Colleague',
  },

  {
    'name': 'Student B',
    'text': 'The best teacher—always engaging!',
    'avatar': 'images/student2.webp',
    'position': 'Student',
  },

  {
    'name': 'Student D',
    'text': 'Brings energy to every lecture!',
    'avatar': 'images/student4.webp',
    'position': 'Student',
  },




];


final List<Map<String, dynamic>> skillInventory = [
  {
    "name": "Flutter Blitz",
    "icon": "images/flutter.png",
    "description": "Strikes with cross-platform app precision",
    "use": "Built Doc Talk complex chat app for health worker during pandemic @Freelance (2021)",
    "mastery": 95,
    "color": Colors.blue,
  },
  {
    "name": "Java Juggernaut",
    "icon": "images/java.png",
    "description": "Crushes native Android challenges",
    "use":  "Shipped 15+ Java-based native Android apps @Eton Technology (2016-2018)",
    "mastery": 90,
    "color": Colors.orange,
  },
  {
    "name": "React Native Ninja",
    "icon": "images/react.png",
    "description": "Stealthily bridges iOS and Android with masterful precision",
    "use": "Forged a high-end, buttery-smooth UI/UX for a demanding Japanese client @IGC Technology (2018-2019)",
    "mastery": 85,
    "color": Colors.cyan,
  },
  {
    "name": "Dart Dynamo",
    "icon": "images/dart.png",
    "description": "Bullseyes async puzzles like a Gerudo archer",
    "use": "Cleared DSA labyrinths & Isolate shrines since Flutter's first release by Google (2017)",
    "mastery": 92,
    "color": Colors.teal,
  },

  {
    "name": "Firebase Forge",
    "icon": "images/firebase.png",
    "description": "Fires rapid Flutter-powered solutions with blazing efficiency",
    "use": "Empowered 10+ apps with real-time Firebase magic (2019-Present)",
    "mastery": 88,
    "color": Colors.yellow,
  },
  {
    "name": "Git Guru",
    "icon": "images/git.png",
    "description": "Masters version control like a pro",
    "use": "Rescued 10,000+ commits from the abyss (2016-Present)",
    "mastery": 90,
    "color": Colors.red,
  },
  {
    "name": "API Alchemist",
    "icon": "images/api.png",
    "description": "Turns REST, SOAP & sockets into digital gold",
    "use": "Wired up countless number of APIs across industries (2016–Present) • From legacy systems to real-time magic",
    "mastery": 87,
    "color": Colors.purple,
  },
  {
    "name": "SQL Sorcerer",
    "icon": "images/sql.png",
    "description": "Casts structured data spells",
    "use": "Optimized School Management System @Eton Technology (2017)",
    "mastery": 85,
    "color": Colors.indigo,
  },
  {
    "name": "Debug Demolisher",
    "icon": "images/bug.png",
    "description": "Smashes bugs with ruthless efficiency",
    "use": "Fixed Nepbay app performance @Nepbay (2019)",
    "mastery": 89,
    "color": Colors.green,
  },

  {
    "name": "Solidity Striker",
    "icon": "images/solidity.png",
    "description": "Kicks blockchain into high gear",
    "use": "Explored blockchain for apps @Freelance (2022)",
    "mastery": 75, // Lower since it’s newer in your experience
    "color": Colors.purpleAccent,
  },
  {
    "name": "IPFS Pathfinder",
    "icon": "images/ipfs.png",
    "description": "Navigates decentralized file frontiers",
    "use": "Integrated IPFS in projects @Freelance (2022)",
    "mastery": 80,
    "color": Colors.pink,
  },
  {
    "name": "ClientSync",
    "icon": "images/handshake.png",
    "description": "Translates ideas into real solutions with automated precision",
  "use": "From coffee-shop consultations to polished deployments for diverse clients @Freelance (2016–Present)",
    "mastery": 86,
    "color": Colors.grey,
  },

  {
    "name": "Quest Leader",
    "icon": "images/teamwork.png",
    "description": "Assembles and rallies dev parties for epic projects",
    "use": "Led 5+ cross-functional teams to deliver complex apps on deadline",
    "mastery": 88,
    "color": Colors.amber,
  },

  {
    "name": "Lore Translator",
    "icon": "images/communication.png",
    "description": "Converts tech jargon into stakeholder-friendly tales",
    "use": "Bridged 50+ client meetings from confusion to clarity (2016–Present)",
    "mastery": 90,
    "color": Colors.lightBlue,
  },

  {
    "name": "Code Sage",
    "icon": "images/mentor.png",
    "description": "Levels up junior developers with ancient wisdom",
    "use": "Mentored 10+ devs @Freelance & communities",
    "mastery": 85,
    "color": Colors.deepPurple,
  },

  {
    "name": "Scrum Ninja",
    "icon": "images/agile.png",
    "description": "Sprints through deadlines without breaking stealth",
    "use": "Shipped 20+ apps using Agile rituals (2017–Present)",
    "mastery": 87,
    "color": Colors.redAccent,
  },

  {
    "name": "Puzzle Warden",
    "icon": "images/problem-solving.png",
    "description": "Unlocks impossible bugs with lateral thinking",
    "use": "Solved 100+ critical production issues across projects",
    "mastery": 93,
    "color": Colors.tealAccent,
  },

  {
    "name": "Tech Bard",
    "icon": "images/speaking.png",
    "description": "Turns complex concepts into engaging campfire stories",
    "use": "Spoke at 5+ tech meetups about latest tech trends",
    "mastery": 80,
    "color": Colors.orangeAccent,
  }




];


// final List<Map<String, dynamic>> spaceServices = [
//   {
//     "name": "MOBILE APP DEVELOPMENT",
//     "icon": "assets/battleship.png",
//     "target": "assets/alien.png",
//     "color": Colors.blueAccent,
//     "quote": "I slice through mobile app hurdles—native, cross-platform, you name it—like a katana through code!",
//     "mastery": 95,
//     "sound": "explosion.wav",
//   },
//   {
//     "name": "IT CONSULTING",
//     "icon": "images/battleship.png",
//     "target": "assets/alien.png",
//     "color": Colors.yellowAccent,
//     "quote": "Your tech stack’s Death Star? I know its exhaust port weaknesses.",
//     "mastery": 90,
//     "sound": "explosion.wav",
//   },
//   {
//     "name": "GPT WRAPPER APP",
//     "icon": "images/battleship.png",
//     "target": "images/alien.png",
//     "color": Colors.purpleAccent,
//     "quote": "Turn ChatGPT into Jarvis—without Ultron-level bugs.",
//     "mastery": 88,
//     "sound": "explosion.wav",
//   },
//   {
//     "name": "AI AGENT INTEGRATION",
//     "icon": "images/battleship.png",
//     "target": "assets/alien.png",
//     "color": Colors.greenAccent,
//     "quote": "Deploy AI agents that won’t go HAL 9000 on your users.",
//     "mastery": 93,
//     "sound": "explosion.wav",
//   },
// ];

final List<Map<String, dynamic>> turtleServices = [
  {
    'name': 'MOBILE APP DEVELOPMENT',
    'turtle': 'Leonardo',
    'color': Colors.blueAccent,
    'quote': 'I slice through mobile app hurdles—native, cross-platform, you name it—like a katana through code!',
    'mastery': 95,
    'sound': 'attack1.mp3',
    'icon': 'images/leo.gif',
    'service_icon': 'images/mobile_dev.png'
  },
  {
    'name': 'IT CONSULTING',
    'turtle': 'Raphael',
    'color': Colors.redAccent,
    'quote': 'Need a sharper tech strategy? I’ll spot the gaps and cut through the chaos like a sai in action!',
    'mastery': 90,
    'sound': 'attack2.mp3',
    'icon': 'images/raph.gif',
    'service_icon': 'images/it_consultation.png'
  },
  {
    'name': 'GPT WRAPPER APP',
    'turtle': 'Donatello',
    'color': Colors.purpleAccent,
    'quote': 'Turn ChatGPT into Jarvis—without Ultron-level bugs.',
    'mastery': 88,
    'sound': 'piza.mp3',
    'icon': 'images/donnie.gif',
    'service_icon': 'images/gpt_wrapper.png'
  },
  {
    'name': 'AI AGENT INTEGRATION',
    'turtle': 'Michelangelo',
    'color': Colors.orangeAccent,
    'quote': 'Deploy AI agents that won\'t go HAL 9000 on your users, dude!',
    'mastery': 93,
    'sound': 'cowabunga.mp3',
    'icon': 'images/mikey.gif',
    'service_icon': 'images/ai_agent.png'
  },
];