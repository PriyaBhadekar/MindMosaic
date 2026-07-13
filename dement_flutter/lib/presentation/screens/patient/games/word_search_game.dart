import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/game_service.dart';
import '../../../../data/storage/local_storage.dart';
import '../../../../providers/voice_provider.dart';
import '../../../widgets/common/gradient_button.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame>
    with SingleTickerProviderStateMixin {
  String difficulty = 'EASY';

  bool loading = false;
  bool started = false;
  bool finished = false;
  bool answered = false;

  int currentIndex = 0;
  int score = 0;

  List<String> words = [];
  List<String> options = [];

  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardSlide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  void _animateNext() {
    _cardCtrl.reset();
    _cardCtrl.forward();
  }

  Future<void> startGame() async {
    setState(() => loading = true);

    try {
      final data = await GameService.getWordSearchGame(difficulty);
      words = List<String>.from(data['words'] ?? []);
      words.shuffle();

      currentIndex = 0;
      score = 0;
      started = true;
      finished = false;
      answered = false;

      generateOptions();

      if (mounted) {
        context.read<VoiceProvider>().speak("Let's begin.");
        await Future.delayed(const Duration(milliseconds: 800));
        _speakCurrentQuestion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load game: $e")),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  void generateOptions() {
    if (words.isEmpty) return;
    final currentWord = words[currentIndex];
    final temp = <String>[currentWord];
    for (final w in words) {
      if (w != currentWord && temp.length < 4) temp.add(w);
    }
    temp.shuffle();
    options = temp;
  }

  void _speakCurrentQuestion() {
    if (words.isEmpty) return;
    final currentWord = words[currentIndex];
    context.read<VoiceProvider>().speak('Find the word $currentWord.');
  }

  Future<void> answer(String selectedWord) async {
    if (answered) return;
    HapticFeedback.selectionClick();
    answered = true;

    final correctWord = words[currentIndex];
    final isCorrect = selectedWord == correctWord;

    if (isCorrect) {
      score++;
      if (mounted) {
        context
            .read<VoiceProvider>()
            .speak('Wonderful! You found $correctWord.');
      }
    } else {
      if (mounted) {
        context
            .read<VoiceProvider>()
            .speak("That's okay. The correct answer is $correctWord.");
      }
    }

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (currentIndex == words.length - 1) {
      await saveScore();
      setState(() => finished = true);
      _speakFinishResult();
    } else {
      if (mounted) {
        context.read<VoiceProvider>().speak("Let's try the next word.");
      }
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      currentIndex++;
      answered = false;
      generateOptions();
      setState(() {});
      _animateNext();
      _speakCurrentQuestion();
    }
  }

  void _speakFinishResult() {
    final total = words.length;
    final percent = total > 0 ? (score / total * 100).round() : 0;
    if (percent >= 80) {
      context.read<VoiceProvider>().speak(
            'Amazing! You completed the game with $score out of $total.',
          );
    } else if (percent >= 50) {
      context.read<VoiceProvider>().speak('Good job! Keep practicing every day.');
    } else {
      context
          .read<VoiceProvider>()
          .speak('Nice effort. Practice makes memory stronger.');
    }
  }

  Future<void> saveScore() async {
    try {
      final patientId = LocalStorage.getPatientId();
      if (patientId == null) return;
      await GameService.saveScore(
        patientId: patientId,
        gameType: 'WORD_SEARCH',
        score: score,
        maxScore: words.length,
        difficultyLevel: difficulty,
      );
    } catch (_) {}
  }

  Widget buildOption(String text) {
    return GestureDetector(
      onTap: () => answer(text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!started) return _buildStartScreen();
    if (finished) return _buildFinishedScreen();
    return _buildPlayingScreen();
  }

  // ── Start screen ───────────────────────────────────────────────────
  Widget _buildStartScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.cardGradient2),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text('🔎', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 20),
                const Text(
                  'Word Search',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Find the correct word from\nthe given choices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.80),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'Select Difficulty',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['EASY', 'MEDIUM', 'HARD'].map((d) {
                          final sel = d == difficulty;
                          return GestureDetector(
                            onTap: () => setState(() => difficulty = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      sel ? AppColors.primary : Colors.white,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GradientButton(
                    text: "Let's Play!",
                    isLoading: loading,
                    onTap: startGame,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFE8E4FF)],
                    ),
                    height: 58,
                    icon: loading
                        ? null
                        : const Icon(Icons.play_arrow_rounded,
                            color: AppColors.primary, size: 24),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Playing screen ─────────────────────────────────────────────────
  Widget _buildPlayingScreen() {
    if (words.isEmpty) return const SizedBox.shrink();
    final currentWord = words[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        started = false;
                        finished = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${currentIndex + 1} of ${words.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (currentIndex + 1) / words.length,
                            backgroundColor: AppColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$score pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card area
            Expanded(
              child: SlideTransition(
                position: _cardSlide,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Word display card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient2,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: AppColors.primaryShadow(
                                AppColors.cardGradient2.colors.first),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Find This Word',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentWord,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Instruction row with replay
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Choose the matching word below',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _speakCurrentQuestion,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withOpacity(0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.volume_up_rounded,
                                    color: AppColors.primary, size: 22),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Options
                        Expanded(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            children:
                                options.map((e) => buildOption(e)).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Finished screen ────────────────────────────────────────────────
  Widget _buildFinishedScreen() {
    final total = words.length;
    final percent = total > 0 ? (score / total * 100).round() : 0;
    final isPerfect = score == total;
    final isGood = percent >= 60;

    final (emoji, title, subtitle, gradient) = isPerfect
        ? (
            '🏆',
            'Perfect Score!',
            'You found every word!',
            AppColors.cardGradient2,
          )
        : isGood
            ? (
                '⭐',
                'Well Done!',
                'Great memory today!',
                AppColors.caregiverGradient,
              )
            : (
                '💪',
                'Keep Practising!',
                "You'll do better next time.",
                AppColors.cardGradient4,
              );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakFinishResult();
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: gradient)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          started = false;
                          finished = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.30)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultStat(
                            label: 'Score', value: '$score / $total'),
                        Container(
                            width: 1, height: 40, color: Colors.white30),
                        _ResultStat(label: 'Accuracy', value: '$percent%'),
                        Container(
                            width: 1, height: 40, color: Colors.white30),
                        _ResultStat(label: 'Difficulty', value: difficulty),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GradientButton(
                    text: 'Play Again',
                    onTap: startGame,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFE8E4FF)],
                    ),
                    height: 58,
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        started = false;
                        finished = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back to Games',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result stat widget ─────────────────────────────────────────────────
class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}