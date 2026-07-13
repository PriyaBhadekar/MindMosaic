// CREATE lib/presentation/screens/patient/games/memory_flashcard_game.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/game_model.dart';
import '../../../../providers/game_provider.dart';
import '../../../../providers/voice_provider.dart';
import '../../../widgets/common/gradient_button.dart';

class MemoryFlashcardGame extends StatefulWidget {
  const MemoryFlashcardGame({super.key});

  @override
  State<MemoryFlashcardGame> createState() => _MemoryFlashcardGameState();
}

class _MemoryFlashcardGameState extends State<MemoryFlashcardGame>
    with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadFlashcardGame();
    });
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

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: switch (game.status) {
        GameStatus.idle => _buildIdle(context, game),
        GameStatus.playing => _buildPlaying(context, game),
        GameStatus.finished => _buildFinished(context, game),
      },
    );
  }

  // ── Idle / loading screen ──────────────────────────────────────────
  Widget _buildIdle(BuildContext context, GameProvider game) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.caregiverGradient),
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
                      onTap: () {
                        game.reset();
                        Navigator.pop(context);
                      },
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
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 64),
              const SizedBox(height: 20),
              const Text(
                'Memory Flashcard',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Can you remember the faces\nof your loved ones?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.80),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Difficulty selector
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
                        final sel = d == game.difficulty;
                        return GestureDetector(
                          onTap: () => game.setDifficulty(d),
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
                                color: sel
                                    ? AppColors.primary
                                    : Colors.white,
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

              if (game.isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else if (game.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          game.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        text: 'Try Again',
                        onTap: () => game.loadFlashcardGame(),
                        gradient: const LinearGradient(
                          colors: [Colors.white24, Colors.white30],
                        ),
                        height: 52,
                      ),
                    ],
                  ),
                )
              else if (game.questions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'No memories found.\nAsk your caregiver to add some memories first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          '${game.questions.length} questions ready',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          text: "Let's Play!",
                          onTap: () {
                            game.startGame();
                            _animateNext();
                            // Speak first question
                            final q = game.currentQuestion;
                            if (q != null) {
                              context
                                  .read<VoiceProvider>()
                                  .speak(q.question);
                            }
                          },
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFE8E4FF)],
                          ),
                          height: 58,
                          icon: const Icon(Icons.play_arrow_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                      ],
                    ),
                  ),

              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Playing screen ─────────────────────────────────────────────────
  Widget _buildPlaying(BuildContext context, GameProvider game) {
    final q = game.currentQuestion!;

    return SafeArea(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    game.reset();
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
                        'Question ${game.currentIndex + 1} of ${game.questions.length}',
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
                          value: game.progressPercent,
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
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${game.score} pts',
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

          // ── Card area ─────────────────────────────────────
          Expanded(
            child: SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Image card
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: q.imageUrl != null && q.imageUrl!.isNotEmpty
                                ? Image.network(
                              q.imageUrl!,
                              fit: BoxFit.cover,

                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;

                                return Container(
                                  color: AppColors.surfaceVariant,

                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },

                              errorBuilder: (_, __, ___) =>
                                  _ImagePlaceholder(),
                            )
                                : _ImagePlaceholder(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Question text + TTS
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              q.question,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context
                                .read<VoiceProvider>()
                                .speak(q.question),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.volume_up_rounded,
                                  color: AppColors.primary, size: 22),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Answer options
                      Expanded(
                        flex: 4,
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: q.options.map((opt) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _AnswerButton(
                                label: opt,
                                isSelected: game.selectedAnswer == opt,
                                isCorrect: game.answered &&
                                    opt == q.correctAnswer,
                                isWrong: game.answered &&
                                    game.selectedAnswer == opt &&
                                    opt != q.correctAnswer,
                                enabled: !game.answered,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  game.selectAnswer(opt);

                                  Future.delayed(
                                    const Duration(seconds: 5),
                                        () {

                                      if (!mounted) return;

                                      game.nextQuestion();

                                      if (game.status == GameStatus.playing) {

                                        _animateNext();

                                        final next = game.currentQuestion;

                                        if (next != null) {

                                          context
                                              .read<VoiceProvider>()
                                              .speak(next.question);
                                        }
                                      }
                                    },
                                  );

                                  // Speak feedback
                                  final correct =
                                      opt == q.correctAnswer;
                                  final explanation = q.description ?? '';
                                  final relation = q.relationInfo ?? '';

                                  if (correct) {

                                    context.read<VoiceProvider>().speak(
                                      'Wonderful! '
                                          'That is ${q.correctAnswer}. '
                                          '${relation.isNotEmpty ? relation + ". " : ""}'
                                          '$explanation',
                                    );

                                  } else {

                                    context.read<VoiceProvider>().speak(
                                      'That is okay. '
                                          'This is ${q.correctAnswer}. '
                                          '${relation.isNotEmpty ? relation + ". " : ""}'
                                          '$explanation',
                                    );

                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Next button ────────────────────────────────────

        ],
      ),
    );
  }

  // ── Results screen ─────────────────────────────────────────────────
  Widget _buildFinished(BuildContext context, GameProvider game) {
    final total = game.questions.length;
    final score = game.score;
    final percent = total > 0 ? (score / total * 100).round() : 0;
    final isPerfect = score == total;
    final isGood = percent >= 60;

    final (emoji, title, subtitle, gradient) = isPerfect
        ? (
    '🏆',
    'Perfect Score!',
    'You remembered everyone!',
    AppColors.caregiverGradient,
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
    AppColors.cardGradient4,
    );

    // Speak result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceProvider>().speak(
        '$title You scored $score out of $total. $subtitle',
      );
    });

    return Stack(
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
                      game.reset();
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

                // Trophy / emoji
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

                // Score card
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
                        label: 'Score',
                        value: '$score / $total',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white30,
                      ),
                      _ResultStat(
                        label: 'Accuracy',
                        value: '$percent%',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white30,
                      ),
                      _ResultStat(
                        label: 'Difficulty',
                        value: game.difficulty,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action buttons
                GradientButton(
                  text: 'Play Again',
                  onTap: () {
                    game.restart();
                    _animateNext();
                    final q = game.currentQuestion;
                    if (q != null) {
                      context.read<VoiceProvider>().speak(q.question);
                    }
                  },
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
                    game.reset();
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
    );
  }
}

// ── Answer button ──────────────────────────────────────────────────────
class _AnswerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool enabled;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.surface;
    Color borderColor = AppColors.borderLight;
    Color textColor = AppColors.textPrimary;
    Widget? trailingIcon;

    if (isCorrect) {
      bgColor = AppColors.successLight;
      borderColor = AppColors.success;
      textColor = AppColors.success;
      trailingIcon = const Icon(Icons.check_circle_rounded,
          color: AppColors.success, size: 22);
    } else if (isWrong) {
      bgColor = AppColors.dangerLight;
      borderColor = AppColors.danger;
      textColor = AppColors.danger;
      trailingIcon = const Icon(Icons.cancel_rounded,
          color: AppColors.danger, size: 22);
    } else if (isSelected) {
      bgColor = AppColors.primary.withOpacity(0.08);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isCorrect || isWrong ? [] : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}

// ── Image placeholder ──────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceVariant,
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded,
              size: 72, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'Who is this person?',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
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