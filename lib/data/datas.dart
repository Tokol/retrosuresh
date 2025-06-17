import 'package:flutter/material.dart';

import '../models/testimonals.dart';
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
    'name': 'Sanjana Prajapati,',
    'text': 'He’s got that perfect mix of awesome humor and serious dedication, making every class a blast! Plus, we love how he brings his own projects into the mix—it’s inspiring and keeps things real.',
    'avatar': 'images/student3.webp',
    'position': '6th Sem ICMS',
  },

  {
    'name': 'Dipendra Thapa',
    'text': 'Learning Java and Android Studio under Sures Lama (sir) was a transformative experience. Their passion, clarity, and hands-on approach made complex concepts feel simple and engaging. Beyond technical skills, they instilled confidence and a problem-solving mindset that will stay with me forever. A truly inspiring mentor! Truly an inspiring mentor!',
    'avatar': 'images/student2.webp',
    'position': 'Student at London College',
  },

  {
    'name': 'Dibya Kafle',
    'text': 'Brings energy to every lecture!',
    'avatar': 'images/student4.webp',
    'position': '3rd sem ICMS',
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
    'sound': 'assets/sounds/attack1.mp3',
    'icon': 'images/leo.gif',
    'service_icon': 'images/mobile_dev.png'
  },
  {
    'name': 'IT CONSULTING',
    'turtle': 'Raphael',
    'color': Colors.redAccent,
    'quote': 'Need a sharper tech strategy? I’ll spot the gaps and cut through the chaos like a sai in action!',
    'mastery': 90,
    'sound': 'assets/sounds/attack2.mp3',
    'icon': 'images/raph.gif',
    'service_icon': 'images/it_consultation.png'
  },
  {
    'name': 'GPT WRAPPER APP',
    'turtle': 'Donatello',
    'color': Colors.purpleAccent,
    'quote': 'Turn ChatGPT into Jarvis—without Ultron-level bugs.',
    'mastery': 88,
    'sound': 'assets/sounds/piza.mp3',
    'icon': 'images/donnie.gif',
    'service_icon': 'images/gpt_wrapper.png'
  },
  {
    'name': 'AI AGENT INTEGRATION',
    'turtle': 'Michelangelo',
    'color': Colors.orangeAccent,
    'quote': 'Deploy AI agents that won\'t go HAL 9000 on your users, dude!',
    'mastery': 93,
    'sound': 'assets/sounds/cowabunga.mp3',
    'icon': 'images/mikey.gif',
    'service_icon': 'images/ai_agent.png'
  },
];

final List<Testimonial> developerTestimonials = [Testimonial(
  name: "Takahiro funayama",
  photo: "images/Takahiro funayama.png",
  quote: "We are gratful for Mr. suresh Lama for outstanding work on the JICA Farmer Survey App, an offline data collection tool for farmers in the remote areas of Nepal. His Professionalism, dedication and technical expertise were instrumental in delivering a high-quality product successfully and efficiently",
  position: "Project Lead",
  organization: "JICA",
),
  Testimonial(
    name: "Anish Sharma",
    photo: "images/anish.png",
    quote: "Mr. Suresh Lama turned our business chaos into a well-oiled machine with his IT wizardry. Thanks to his solution, we've automated so much, we've started to wonder if he can automated coffer breaks too. Highly recommended working with this genius.",
    position: "CEO",
    organization: "RED DOT Production",
  ),
  Testimonial(
    name: "Niko Gurung",
    photo: "images/niko.png",
    quote: "Truly IT Consulting Wizard, a genius guy i am blessed to work with",
    position: "CEO",
    organization: "Walkers Hive",
  ),
  Testimonial(
    name: "Dhiraj Lama",
    photo: "images/dhiraj.png",
    quote: "A Genuine, honest and hardworking guy.",
    position: "CO-Founder",
    organization: "Technovaglobal",
  ),];




final List<Map<String, dynamic>> postcards = [
  {
    'country': 'Egypt',
    'code': 'EG',
    'image': 'images/pyramid_photo.jpg',
    'message': 'Stood in awe before the Pyramids!',
    'story': 'As I stood before the Pyramids, time felt thick in the air—like it was watching me. These stones have outlasted empires, lovers, and sunsets. I couldn’t help but wonder: what will remain of us in 5,000 years? Maybe just a memory in the wind, or maybe nothing at all—and that’s oddly comforting.',
    'location': 'GIZA PLATEAU',
    'date': 'FEB 5, 2022',
    'stampColor': Colors.orange,
  },
  {
    'country': 'Nepal',
    'code': 'NP',
    'image': 'images/mountain_peak_photo.jpg',
    'message': 'Reached the peaks of the Himalayas!',
    'story': 'Trekking to Annapurna felt like shedding layers—not just of jackets, but of ego. Each step reminded me how small I am, yet how full that smallness can feel. The mountains whispered: *I was here before you, and I’ll be here after.* And somehow, that felt peaceful.',
    'location': 'ANNAPURNA RANGE',
    'date': 'NOV 5, 2024',
    'stampColor': Colors.red,
  },

  {
    'country': 'Vietnam',
    'code': 'VN',
    'image': 'images/travel/lotus temple.jpg',
    'message': 'Stood still in the heart of Hanoi.',
    'story': 'The One Pillar Pagoda rose from a lotus pond. Built by Emperor Lý Thái Tông after a divine vision, it became a guardian of hope and rebirth. War tried to erase it. Time tried to forget it. Yet like the lotus, it blooms again. In its shadow, I saw the resilience of faith, the echo of dreams, and the stillness this rushing world forgets.',
    'location': 'Lotus Temple',
    'date': 'JUN 10, 2023',
    'stampColor': Colors.amber,
  },

  {
    'country': 'Nepal',
    'code': 'NP',
    'image': 'images/travel/shaktikor.jpg',
    'message': 'Shaktikhor Waterfall',
    'story': 'Shaktikhor in Chitwan felt like a short hike, but it opened a new chapter for me—my first on the humid trails of the Terai. It wasn’t just the heat I walked through, but the stories of the Chepang community, carved into the hills and whispers of the forest. Sometimes, the smallest trails take you farthest—from routine into discovery.',
    'location': 'SHAKTIKHOR WATERFALL',
    'date': 'JUL 10, 2021',
    'stampColor': Colors.red,
  },


  {
    'country': 'Egypt',
    'code': 'EG',
    'image': 'images/travel/library_eg.jpg',
    'message': 'Bibliotheca Alexandrina',
    'story': 'Standing before the Bibliotheca Alexandrina, I felt the weight of lost knowledge and the hope of rediscovery. Once the heart of ancient wisdom, now reborn by the sea—it reminded me that even what’s lost can return in new form. Like journeys, like parts of ourselves.',
    'location': 'BIBLIOTHECA ALEXANDRINA',
    'date': 'FEB 8, 2022',
    'stampColor': Colors.orange,
  },


  {
    'country': 'Thailand',
    'code': 'TH',
    'image': 'images/travel/thailand.jpg',
    'message': 'Wat Traimit',
    'story': 'Inside Wat Traimit, I took a quiet selfie with a monk. No exchange, no performance—just two paths crossing in stillness. Behind us, the Golden Buddha reminded me how much strength can rest in silence, and how some moments speak without saying a word.',
    'location': 'WAT TRAIMIT',
    'date': 'FEB 11, 2018',
    'stampColor': Colors.blueAccent,
  },


  {
    'country': 'Nepal',
    'code': 'NP',
    'image': 'images/travel/ghandruk.jpg',
    'message': 'GHANDRUK HIKE',
    'story': 'The Ghandruk hike offered stunning mountain views at every turn, but it was the quiet strength of the Gurung village that grounded me. A perfect mix of effort and ease—where culture met altitude, and every step felt like a reward.',
    'location': 'GHANDRUK HIKE',
    'date': 'NOV 3, 2024',
    'stampColor': Colors.red,
  },



  {
    'country': 'Vietnam',
    'code': 'VN',
    'image': 'images/travel/vietnam.jpg',
    'message': 'Hanoi Rickshaw Adventure',
    'story': 'Riding a rickshaw through Hanoi was chaos wrapped in charm. The streets buzzed, yet felt clean and calm in their own rhythm. My rickshaw puller, all smiles, moved like he was part of the flow—not rushing, just present. Sitting there, I didn’t just pass through the city—I really saw it.',
    'location': 'HANOI RICKSHAW ADVENTURE',
    'date': 'JUN 14, 2023',
    'stampColor': Colors.amber,
  },

  {
    'country': 'Malaysia',
    'code': 'MY',
    'image': 'images/travel/malyasia.jpg',
    'message': 'LAGOON ROLLER COASTER',
    'story': 'In Malaysia, I was young, nervous, and curious—my first roller coaster ride. The irony? It was one of the oldest, built in the 1920s. It had carried many like me, across time. Funny how the oldest rides can spark the newest memories.',
    'location': 'LAGOON ROLLER COASTER',
    'date': 'JAN 15, 2017',
    'stampColor': Colors.yellow,
  },

  {
    'country': 'Nepal',
    'code': 'NP',
    'image': 'images/travel/snack.jpg',
    'message': 'Shivapuri ',
  'story': 'In the heart of Shivapuri National Park, I took a break under the summer sun, enjoying a protein bar. Surrounded by the dense jungle, the peaceful rhythm of the forest reminded me of the strength in quiet persistence. With each step, the calm of the land made me want to keep walking further.',
  'location': 'SHIVAPURI NATIONAL PARK',
    'date': 'OCT 5, 2021',
    'stampColor': Colors.red,
  },

  {
    'country': 'Vietnam',
    'code': 'VN',
    'image': 'images/travel/temple of literature.png',
    'message': 'Literature Temple',
    'story': 'With my soulmate-my best friend beside me, I stood at the Temple of Literature in Vietnam—built during a time when Confucian ideals from ancient China shaped the civilization of this region. In that quiet courtyard, we felt something deeper than history—a shared respect for wisdom, tradition, and the silent bond between old teachings and new journeys.',
    'location': 'TEMPLE OF LITERATURE',
    'date': 'JUN 16, 2023',
    'stampColor': Colors.amber,
  },



  {
    'country': 'Singapore',
    'code': 'SG',
    'image': 'images/travel/singapore.jpg',
    'message': 'Singapore waiting  ',
    'story': 'Outside that hotel elevator in Singapore, I looked fresh and ready—but behind the excitement was a quiet nervousness. I was younger, still finding my voice, yet curious enough to step out into the unknown. Looking back, it wasn’t just a city I explored, it was a version of myself becoming braver.',
    'location': 'Singapore: The Journey’s Start',
    'date': 'MAR 5, 2016',
    'stampColor': Colors.teal,
  },


  {
    'country': 'Nepal',
    'code': 'NP',
    'image': 'images/travel/bye chitwan.jpg',
    'message': 'Chitwan ',
    'story': 'Leaving Chitwan, I held a “Chattri” hat, crafted by Tharu farmers for long days in the sun. What once shielded them now marked my quiet goodbye. Some goodbyes aren’t loud—they stay with you, gently, like a piece of the place that never truly leaves.',
    'location': 'GOODBYE CHITWAN',
    'date': 'OCT 5, 2021',
    'stampColor': Colors.red,
  },


  {
    'country': 'Egypt',
    'code': 'EG',
    'image': 'images/travel/nile.png',
    'message': 'Whispers of the Nile',
    'story': 'On a quiet Nile cruise, beneath soft lights and swirling music, I sat—shy, still. The river moved like memory, like myth. It once fed kings and birthed gods, now it carries laughter, lights, and me. Strange how time slips—how a river that made history barely notices you passing.',
    'location': "DINNER CRUISE ON NILE RIVER",
    'date': 'FEB 15, 2022',
    'stampColor': Colors.orange,
  },



  {
    'country': 'Vietnam',
    'code': 'VN',
    'image': 'images/travel/halongcruz.png',
    'message': 'Halong Bay by Sea',
    'story': 'I travelled the sea aboard a cruise hotel, drifting through Halong Bay—where limestone cliffs rose like myths and coastal life moved quietly at the edge of water. From sunrise to starlight, I watched the day breathe in and out. Somewhere between the waves and stillness, I felt the world slow down—just enough to notice it.',
    'location': 'HALONG BAY – CRUISE HOTEL',
    'date': 'JUN 20, 2023',
    'stampColor': Colors.teal,
  }



];