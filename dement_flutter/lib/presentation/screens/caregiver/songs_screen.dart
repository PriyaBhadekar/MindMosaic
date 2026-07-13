// CREATE lib/presentation/screens/caregiver/songs_screen.dart
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/song_model.dart';
import '../../../providers/song_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/soft_text_field.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  String _selectedMood = 'ALL';
  final List<String> _moods = [
    'ALL', 'CALM', 'HAPPY', 'SAD', 'ANXIOUS', 'NEUTRAL'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongProvider>().fetchSongs();
    });
  }

  List<SongModel> _filtered(List<SongModel> all) {
    if (_selectedMood == 'ALL') return all;
    return all
        .where((s) => s.moodCategory == _selectedMood)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SongProvider>();
    final filtered = _filtered(prov.songs);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.cardGradient3,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Music Therapy',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Calming music for your patient',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Mood filter chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _moods.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final sel = _moods[i] == _selectedMood;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedMood = _moods[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _moods[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? AppColors.accent
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Now playing mini bar ───────────────────────────────
          if (prov.nowPlaying != null) _NowPlayingBar(prov: prov),

          // ── Song list ──────────────────────────────────────────
          Expanded(
            child: prov.isLoading
                ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
                : filtered.isEmpty
                ? _EmptySongs(onAdd: () => _openUploadSheet(context))
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _SongCard(
                song: filtered[i],
                isPlaying: prov.nowPlaying?.id == filtered[i].id &&
                    prov.isPlaying,
                onTap: () => prov.play(filtered[i]),
                onDelete: () =>
                    _confirmDelete(context, filtered[i].id),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openUploadSheet(context),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.upload_rounded, color: Colors.white),
        label: const Text('Upload Song',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UploadSongSheet(),
    ).then((_) => context.read<SongProvider>().fetchSongs());
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Song'),
        content: const Text('This song will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<SongProvider>().deleteSong(id);
    }
  }
}

class _NowPlayingBar extends StatelessWidget {
  final SongProvider prov;
  const _NowPlayingBar({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient3,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.primaryShadow(AppColors.accent),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.music_note_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prov.nowPlaying!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  prov.nowPlaying!.artist ?? 'Unknown artist',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => prov.play(prov.nowPlaying!),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                prov.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: prov.stop,
            child: const Icon(Icons.close_rounded,
                color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _SongCard({
    required this.song,
    required this.isPlaying,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = _moodColor(song.moodCategory);

    return Dismissible(
      key: Key('song_${song.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPlaying
                ? AppColors.accent.withOpacity(0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
            border: isPlaying
                ? Border.all(color: AppColors.accent.withOpacity(0.4))
                : null,
          ),
          child: Row(
            children: [
              // Album art placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
                  color: moodColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isPlaying
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (song.artist != null && song.artist!.isNotEmpty) ...[
                          Text(
                            song.artist!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (song.moodCategory != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              song.moodCategory!,
                              style: TextStyle(
                                fontSize: 10,
                                color: moodColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (song.durationSeconds != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _formatDuration(song.durationSeconds!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isPlaying)
                _MusicWave(color: moodColor),
            ],
          ),
        ),
      ),
    );
  }

  Color _moodColor(String? mood) {
    switch (mood) {
      case 'CALM':
        return AppColors.secondary;
      case 'HAPPY':
        return AppColors.success;
      case 'SAD':
        return AppColors.primary;
      case 'ANXIOUS':
        return AppColors.warning;
      default:
        return AppColors.accent;
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// Simple animated music wave indicator
class _MusicWave extends StatefulWidget {
  final Color color;
  const _MusicWave({required this.color});

  @override
  State<_MusicWave> createState() => _MusicWaveState();
}

class _MusicWaveState extends State<_MusicWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final h = 8.0 +
              (i == 1 ? 14.0 : 8.0) * _ctrl.value;
          return Container(
            width: 3,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptySongs extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySongs({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.library_music_rounded,
                size: 44, color: AppColors.accent),
          ),
          const SizedBox(height: 20),
          const Text('No songs yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Upload calming music for your patient',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: 'Upload First Song',
            onTap: onAdd,
            gradient: AppColors.cardGradient3,
            height: 52,
          ),
        ],
      ),
    );
  }
}

// ── Upload Song bottom sheet ────────────────────────────────────────────
class _UploadSongSheet extends StatefulWidget {
  const _UploadSongSheet();

  @override
  State<_UploadSongSheet> createState() => _UploadSongSheetState();
}

class _UploadSongSheetState extends State<_UploadSongSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  XFile? _audioFile;
  String? _audioFileName;
  String _selectedMood = 'CALM';

  final List<String> _moods = [
    'CALM', 'HAPPY', 'SAD', 'ANXIOUS', 'NEUTRAL'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;

      setState(() {
        _audioFile = XFile.fromData(
          file.bytes!,
          name: file.name,
          mimeType: 'audio/mpeg',
        );

        _audioFileName = file.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final prov = context.read<SongProvider>();
    final ok = await prov.uploadSong(
      title: _titleCtrl.text.trim(),
      artist: _artistCtrl.text.trim(),
      moodCategory: _selectedMood,
      audioFile: _audioFile,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Failed to upload song'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SongProvider>();
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + kb),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Upload Song',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),

              // Audio file picker
              GestureDetector(
                onTap: _pickAudio,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _audioFile != null
                        ? AppColors.success.withOpacity(0.06)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _audioFile != null
                          ? AppColors.success.withOpacity(0.4)
                          : AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _audioFile != null
                            ? Icons.music_note_rounded
                            : Icons.upload_file_rounded,
                        color: _audioFile != null
                            ? AppColors.success
                            : AppColors.textHint,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _audioFileName ?? 'Tap to select audio file',
                          style: TextStyle(
                            fontSize: 14,
                            color: _audioFile != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                            fontWeight: _audioFile != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SoftTextField(
                hint: 'Song title',
                label: 'Title',
                controller: _titleCtrl,
                prefixIcon: Icons.music_note_rounded,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              SoftTextField(
                hint: 'Artist name (optional)',
                label: 'Artist',
                controller: _artistCtrl,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              const Text('MOOD CATEGORY',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _moods.map((m) {
                  final sel = m == _selectedMood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accent
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppColors.accent
                                : AppColors.border),
                      ),
                      child: Text(m,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              GradientButton(
                text: 'Upload Song',
                onTap: prov.isLoading ? null : _submit,
                isLoading: prov.isLoading,
                gradient: AppColors.cardGradient3,
                height: 54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}