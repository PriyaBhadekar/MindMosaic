// CREATE lib/presentation/screens/patient/patient_voice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/voice_provider.dart';
import '../../widgets/common/voice_assistant_orb.dart';

class PatientVoiceScreen extends StatefulWidget {
  const PatientVoiceScreen({super.key});

  @override
  State<PatientVoiceScreen> createState() => _PatientVoiceScreenState();
}

class _PatientVoiceScreenState extends State<PatientVoiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _bgAnim;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  final List<String> _moods = [
    '😊 Happy',
    '😢 Sad',
    '😰 Anxious',
    '😌 Calm',
    '😕 Confused',
    '😤 Agitated',
  ];

  final Map<String, String> _moodKeys = {
    '😊 Happy': 'HAPPY',
    '😢 Sad': 'SAD',
    '😰 Anxious': 'ANXIOUS',
    '😌 Calm': 'CALM',
    '😕 Confused': 'CONFUSED',
    '😤 Agitated': 'AGITATED',
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bgAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut),
    );

    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _entryCtrl.forward();

    // Auto-greet on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceProvider>().fetchAndSpeakPrompt();
    });
  }

  @override
  void dispose() {

    _bgCtrl.dispose();
    _entryCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceProvider>();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF4A3FBF),
                  const Color(0xFF3ECFB2),
                  _bgAnim.value * 0.4,
                )!,
                Color.lerp(
                  const Color(0xFF6B5FE4),
                  const Color(0xFF28A896),
                  _bgAnim.value * 0.5,
                )!,
              ],
            ),
          ),
          child: child,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _entryFade,
            child: SlideTransition(
              position: _entrySlide,

              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Top bar ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            voice.stopAll();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18),
                          ),
                        ),

                        const Text(
                          'Voice Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Status label ───────────────────────────
                  _StateLabel(state: voice.state),

                  const SizedBox(height: 32),

                  // ── Voice orb ──────────────────────────────
                  VoiceAssistantOrb(
                    isListening: voice.isListening,
                    isActive: !voice.isIdle,
                    size: 130,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (voice.isListening) {
                        voice.stopListening();
                      } else if (voice.isIdle || voice.isSpeaking) {
                        voice.startListening();
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Spoken words bubble ────────────────────
                  if (voice.spokenWords.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _SpeechBubble(
                        text: voice.spokenWords,
                        isUser: true,
                      ),
                    ),

                  // ── Prompt bubble ──────────────────────────
                  if (voice.currentPrompt.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
                      child: _SpeechBubble(
                        text: voice.currentPrompt,
                        isUser: false,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Suggestion ─────────────────────────────



                  const SizedBox(height: 30),
                  // ── Tap instruction ───────────────────────
                  AnimatedOpacity(
                    opacity: voice.isIdle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Tap the orb to speak',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.70),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Mood check-in section ─────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How are you feeling?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _moods
                              .map((m) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              voice.logMood(_moodKeys[m]!);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color:
                                Colors.white.withOpacity(0.18),
                                borderRadius:
                                BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.25)),
                              ),
                              child: Text(
                                m,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Quick actions ─────────────────────────


                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ── State label ────────────────────────────────────────────────────────
class _StateLabel extends StatelessWidget {
  final VoiceState state;
  const _StateLabel({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (state) {
      VoiceState.idle => ('Ready to listen', Icons.mic_none_rounded),
      VoiceState.listening => ('Listening...', Icons.mic_rounded),
      VoiceState.processing => ('Processing...', Icons.hourglass_top_rounded),
      VoiceState.speaking => ('Speaking...', Icons.volume_up_rounded),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(state),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Speech bubble ──────────────────────────────────────────────────────
class _SpeechBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _SpeechBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withOpacity(0.90)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: isUser
            ? null
            : Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: isUser ? AppColors.textPrimary : Colors.white,
          fontWeight:
          isUser ? FontWeight.w600 : FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }
}

// ── Quick voice action button ──────────────────────────────────────────
class _QuickVoiceAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickVoiceAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}