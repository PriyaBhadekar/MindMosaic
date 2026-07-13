import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/game_service.dart';
import '../../../../data/storage/local_storage.dart';
import '../../../../providers/voice_provider.dart';
import '../../../widgets/common/gradient_button.dart';

class SequenceGame extends StatefulWidget {
  const SequenceGame({super.key});

  @override
  State<SequenceGame> createState() => _SequenceGameState();
}

class _SequenceGameState extends State<SequenceGame>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  String difficulty = 'EASY';
  int score = 0;
  int round = 1;
  int totalRounds = 5;

  bool started = false;
  bool showingSequence = false;
  bool finished = false;
  bool answered = false;

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final List<String> colorNames = ['Red', 'Blue', 'Green', 'Yellow'];

  List<Color> sequence = [];
  List<Color> userSequence = [];

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

  int get sequenceLength {
    switch (difficulty) {
      case 'HARD':
        return 7;
      case 'MEDIUM':
        return 5;
      default:
        return 3;
    }
  }

  String _colorName(Color color) {
    final idx = colors.indexOf(color);
    if (idx < 0) return 'color';
    return colorNames[idx];
  }

  String _sequenceAsWords(List<Color> seq) {
    return seq.map(_colorName).join(', ');
  }

  Future<void> startGame() async {
    score = 0;
    round = 1;
    finished = false;
    started = true;
    answered = false;

    if (mounted) {
      context.read<VoiceProvider>().speak("Let's begin.");
    }

    await Future.delayed(const Duration(milliseconds: 800));
    await generateRound();
  }

  Future<void> generateRound() async {
    sequence = List.generate(
      sequenceLength,
      (_) => colors[_random.nextInt(colors.length)],
    );
    userSequence.clear();
    answered = false;

    if (mounted) {
      setState(() {
        showingSequence = true;
      });
      _animateNext();
      context.read<VoiceProvider>().speak('Remember this color sequence.');
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      showingSequence = false;
    });

    context.read<VoiceProvider>().speak('Now repeat the sequence.');
  }

  void _speakCurrentInstruction() {
    if (showingSequence) {
      context.read<VoiceProvider>().speak(
            'Remember this color sequence: ${_sequenceAsWords(sequence)}.',
          );
    } else {
      context.read<VoiceProvider>().speak('Now repeat the sequence.');
    }
  }

  Future<void> selectColor(Color color) async {
    if (showingSequence || answered) return;

    HapticFeedback.selectionClick();
    userSequence.add(color);

    if (userSequence.length == sequence.length) {
      answered = true;

      bool correct = true;
      for (int i = 0; i < sequence.length; i++) {
        if (sequence[i] != userSequence[i]) {
          correct = false;
          break;
        }
      }

      if (correct) {
        score++;
        if (mounted) {
          context
              .read<VoiceProvider>()
              .speak('Excellent! You remembered the sequence.');
        }
      } else {
        if (mounted) {
          context
              .read<VoiceProvider>()
              .speak("That's okay. Let's try another one.");
        }
      }

      if (round >= totalRounds) {
        await saveScore();
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        setState(() {
          finished = true;
        });
        _speakFinishResult();
      } else {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        round++;
        setState(() {});
        context.read<VoiceProvider>().speak('Here comes the next sequence.');
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        await generateRound();
      }
    }

    if (mounted) setState(() {});
  }

  void _speakFinishResult() {
    final percent = totalRounds > 0 ? (score / totalRounds * 100).round() : 0;
    if (percent >= 80) {
      context.read<VoiceProvider>().speak(
            'Amazing! You completed the game with $score out of $totalRounds.',
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
        gameType: 'SEQUENCE_MEMORY',
        score: score,
        maxScore: totalRounds,
        difficultyLevel: difficulty,
      );
    } catch (_) {}
  }

  Widget buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => selectColor(color),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      return _buildStartScreen();
    }
    if (finished) {
      return _buildFinishedScreen();
    }
    return _buildPlayingScreen();
  }

  // ── Start screen ───────────────────────────────────────────────────
  Widget _buildStartScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.cardGradient4),
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
                const Icon(Icons.psychology,
                    size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Sequence Memory',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Remember and repeat the color\nsequence to train your memory.',
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
                    onTap: startGame,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFE8E4FF)],
                    ),
                    height: 58,
                    icon: const Icon(Icons.play_arrow_rounded,
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
                          'Round $round of $totalRounds',
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
                            value: round / totalRounds,
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
                        // Instruction row with replay
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                showingSequence
                                    ? 'Remember this sequence!'
                                    : 'Repeat the sequence',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _speakCurrentInstruction,
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

                        const SizedBox(height: 24),

                        if (showingSequence)
                          Expanded(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: sequence
                                      .map(
                                        (c) => Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: c,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: AppColors.cardShadow,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              children: [
                                // User progress
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppColors.cardShadow,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${userSequence.length} / ${sequence.length} selected',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // User selection preview
                                if (userSequence.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: userSequence
                                        .map(
                                          (c) => Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: c,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),

                                const Spacer(),

                                // Color buttons
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  alignment: WrapAlignment.center,
                                  children:
                                      colors.map(buildColorButton).toList(),
                                ),

                                const SizedBox(height: 20),
                              ],
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
    final percent =
        totalRounds > 0 ? (score / totalRounds * 100).round() : 0;
    final isPerfect = score == totalRounds;
    final isGood = percent >= 60;

    final (emoji, title, subtitle, gradient) = isPerfect
        ? (
            '🏆',
            'Perfect Score!',
            'You remembered every sequence!',
            AppColors.cardGradient4,
          )
        : isGood
            ? (
                '⭐',
                'Well Done!',
                'Great memory today!',
                AppColors.cardGradient2,
              )
            : (
                '💪',
                'Keep Practising!',
                "You'll do better next time.",
                AppColors.cardGradient1,
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
                            label: 'Score', value: '$score / $totalRounds'),
                        Container(
                            width: 1, height: 40, color: Colors.white30),
                        _ResultStat(
                            label: 'Accuracy', value: '$percent%'),
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