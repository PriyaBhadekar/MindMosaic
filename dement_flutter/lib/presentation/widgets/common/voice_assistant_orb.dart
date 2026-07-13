// CREATE lib/presentation/widgets/common/voice_assistant_orb.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VoiceAssistantOrb extends StatefulWidget {
  final bool isListening;
  final bool isActive;
  final VoidCallback? onTap;
  final double size;

  const VoiceAssistantOrb({
    super.key,
    this.isListening = false,
    this.isActive = false,
    this.onTap,
    this.size = 120,
  });

  @override
  State<VoiceAssistantOrb> createState() => _VoiceAssistantOrbState();
}

class _VoiceAssistantOrbState extends State<VoiceAssistantOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rippleCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _rippleAnim;
  late Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _rippleAnim = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );

    _rippleOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut),
    );

    _updateListeningState();
  }

  @override
  void didUpdateWidget(VoiceAssistantOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isListening != widget.isListening) {
      _updateListeningState();
    }
  }

  void _updateListeningState() {
    if (widget.isListening) {
      _rippleCtrl.repeat();
    } else {
      _rippleCtrl.stop();
      _rippleCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: s * 1.7,
        height: s * 1.7,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple ring (listening state)
            if (widget.isListening)
              AnimatedBuilder(
                animation: _rippleCtrl,
                builder: (_, __) => Transform.scale(
                  scale: _rippleAnim.value,
                  child: Opacity(
                    opacity: _rippleOpacity.value,
                    child: Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
            // Outer soft glow ring
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: s * 1.2,
                  height: s * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.18),
                        AppColors.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main orb
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: widget.isListening ? _pulseAnim.value : 1.0,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF8B80F0),
                        Color(0xFF6B5FE4),
                        Color(0xFF4A3FBF),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.45),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isListening
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: s * 0.40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}