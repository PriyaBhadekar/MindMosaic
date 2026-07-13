
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/game_service.dart';
import '../../../../data/storage/local_storage.dart';
import '../../../../providers/voice_provider.dart';
import '../../../widgets/common/gradient_button.dart';

class ObjectRecognitionGame extends StatefulWidget {
  const ObjectRecognitionGame({super.key});

  @override
  State<ObjectRecognitionGame> createState() =>
      _ObjectRecognitionGameState();
}

class _ObjectRecognitionGameState
    extends State<ObjectRecognitionGame> {

  final Random _random = Random();

  String difficulty = 'EASY';

  bool started = false;
  bool finished = false;
  bool _isProcessing = false;

  int currentQuestion = 0;
  int score = 0;

  static const int totalQuestions = 5;

  late List<Map<String, dynamic>> gameQuestions;

  final List<Map<String, dynamic>> easyObjects = [
    {
      "emoji": "📱",
      "answer": "Phone",
      "options": ["Phone", "Clock", "Book", "Cup"]
    },
    {
      "emoji": "🕒",
      "answer": "Clock",
      "options": ["Phone", "Clock", "Chair", "Key"]
    },
    {
      "emoji": "📚",
      "answer": "Book",
      "options": ["Laptop", "Book", "Cup", "Bottle"]
    },
    {
      "emoji": "☕",
      "answer": "Cup",
      "options": ["Cup", "Phone", "Chair", "Clock"]
    },
    {
      "emoji": "🔑",
      "answer": "Key",
      "options": ["Bottle", "Key", "Book", "Clock"]
    },
    {
      "emoji": "🪑",
      "answer": "Chair",
      "options": ["Chair", "Phone", "Cup", "Book"]
    },
  ];

  final List<Map<String, dynamic>> mediumObjects = [
    {
      "emoji": "💻",
      "answer": "Laptop",
      "options": ["Laptop", "Phone", "Television", "Book"]
    },
    {
      "emoji": "📺",
      "answer": "Television",
      "options": ["Laptop", "Television", "Clock", "Bottle"]
    },
    {
      "emoji": "☂️",
      "answer": "Umbrella",
      "options": ["Umbrella", "Chair", "Phone", "Book"]
    },
    {
      "emoji": "🍼",
      "answer": "Bottle",
      "options": ["Bottle", "Clock", "Laptop", "Cup"]
    },
    {
      "emoji": "🧊",
      "answer": "Refrigerator",
      "options": ["Television", "Refrigerator", "Phone", "Chair"]
    },
  ];

  final List<Map<String, dynamic>> hardObjects = [
    {
      "emoji": "🎧",
      "answer": "Headphones",
      "options": ["Headphones", "Television", "Laptop", "Clock"]
    },
    {
      "emoji": "🧮",
      "answer": "Calculator",
      "options": ["Calculator", "Bottle", "Chair", "Phone"]
    },
    {
      "emoji": "🎛️",
      "answer": "Remote Control",
      "options": ["Remote Control", "Book", "Cup", "Phone"]
    },
    {
      "emoji": "🌡️",
      "answer": "Thermometer",
      "options": ["Thermometer", "Clock", "Bottle", "Chair"]
    },
    {
      "emoji": "📡",
      "answer": "Microwave",
      "options": ["Microwave", "Laptop", "Book", "Chair"]
    },
  ];

  List<Map<String, dynamic>> getSelectedDifficultySet() {
    switch (difficulty) {
      case 'MEDIUM':
        return mediumObjects;
      case 'HARD':
        return hardObjects;
      default:
        return easyObjects;
    }
  }

  void _speak(String text) {
    if (!mounted) return;
    final voice = context.read<VoiceProvider>();
    voice.speak(text);
  }

  void startGame() {
    final objects = [...getSelectedDifficultySet()];
    objects.shuffle();

    gameQuestions = objects.take(totalQuestions).toList();

    setState(() {
      started = true;
      finished = false;
      score = 0;
      currentQuestion = 0;
      _isProcessing = false;
    });

    _speak("Let's begin.");

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _speak("What is this object?");
    });
  }

  void _speakCurrentQuestion() {
    if (!mounted) return;
    _speak("What is this object?");
  }

  Future<void> answerQuestion(String selected) async {
    if (_isProcessing) return;

    HapticFeedback.selectionClick();

    setState(() {
      _isProcessing = true;
    });

    final correct = gameQuestions[currentQuestion]["answer"];
    final bool isCorrect = selected == correct;

    if (isCorrect) {
      score++;
      _speak("Excellent! That is $correct.");
    } else {
      _speak("That's okay. This object is $correct.");
    }

    await Future.delayed(const Duration(seconds: 3), () {});

    if (!mounted) return;

    if (currentQuestion == totalQuestions - 1) {
      await saveScore();
      if (!mounted) return;

      setState(() {
        finished = true;
        _isProcessing = false;
      });

      _speakEndOfGame();
    } else {
      _speak("Let's look at another object.");

      await Future.delayed(const Duration(milliseconds: 1500), () {});

      if (!mounted) return;

      setState(() {
        currentQuestion++;
        _isProcessing = false;
      });

      await Future.delayed(const Duration(milliseconds: 300), () {});

      if (!mounted) return;
      _speak("What is this object?");
    }
  }

  void _speakEndOfGame() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage >= 80) {
      _speak(
          "Amazing! You completed the game with $score out of $totalQuestions.");
    } else if (percentage >= 50) {
      _speak("Good job! Keep practicing every day.");
    } else {
      _speak("Nice effort. Practice makes memory stronger.");
    }
  }

  Future<void> saveScore() async {
    try {
      final patientId = LocalStorage.getPatientId();

      if (patientId == null) return;

      await GameService.saveScore(
        patientId: patientId,
        gameType: 'OBJECT_RECOGNITION',
        score: score,
        maxScore: totalQuestions,
        difficultyLevel: difficulty,
      );
    } catch (_) {}
  }

  Widget buildOption(String text) {
    return GestureDetector(
      onTap: () => answerQuestion(text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.cardShadow,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!started) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Object Recognition"),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const SizedBox(height: 30),

              const Text(
                "👀",
                style: TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 16),

              const Text(
                "Object Recognition Game",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Identify everyday objects to improve cognitive recognition skills.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              DropdownButton<String>(
                value: difficulty,
                items: const [
                  DropdownMenuItem(
                    value: 'EASY',
                    child: Text('Easy'),
                  ),
                  DropdownMenuItem(
                    value: 'MEDIUM',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'HARD',
                    child: Text('Hard'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      difficulty = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 30),

              GradientButton(
                text: "Start Game",
                onTap: startGame,
              ),
            ],
          ),
        ),
      );
    }

    if (finished) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [

                const Text(
                  "🎉",
                  style: TextStyle(fontSize: 90),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Game Completed!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Your Score: $score / $totalQuestions",
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 30),

                GradientButton(
                  text: "Play Again",
                  onTap: startGame,
                ),

                const SizedBox(height: 12),

                GradientButton(
                  text: "Back",
                  gradient: AppColors.cardGradient3,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = gameQuestions[currentQuestion];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Question ${currentQuestion + 1}/$totalQuestions",
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            LinearProgressIndicator(
              value:
              (currentQuestion + 1) / totalQuestions,
              minHeight: 8,
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(30),
                boxShadow: AppColors.cardShadow,
              ),
              child: Text(
                question["emoji"],
                style: const TextStyle(
                  fontSize: 100,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "What is this object?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _speakCurrentQuestion,
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 28,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            ...question["options"]
                .map<Widget>((e) => buildOption(e))
                .toList(),
          ],
        ),
      ),
    );
  }
}
