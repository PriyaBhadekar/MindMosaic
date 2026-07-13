// CREATE lib/presentation/screens/patient/patient_music_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/song_model.dart';
import '../../../providers/song_provider.dart';

class PatientMusicScreen extends StatefulWidget {
  const PatientMusicScreen({super.key});

  @override
  State<PatientMusicScreen> createState() => _PatientMusicScreenState();
}

class _PatientMusicScreenState extends State<PatientMusicScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongProvider>().fetchSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SongProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Music', style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                    ]),
                    const SizedBox(height: 12),
                    const Text('Your personal music collection',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),

          // Now playing
          if (prov.nowPlaying != null)
            _NowPlayingBar(prov: prov),

          // Song list
          Expanded(
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : prov.songs.isEmpty
                ? _EmptyMusic()
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: prov.songs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _PatientSongTile(
                song: prov.songs[i],
                isPlaying: prov.nowPlaying?.id == prov.songs[i].id && prov.isPlaying,
                onTap: () => prov.play(prov.songs[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingBar extends StatelessWidget {
  final SongProvider prov;
  const _NowPlayingBar({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient3,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.primaryShadow(AppColors.accent),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prov.nowPlaying!.title, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(prov.nowPlaying!.artist ?? 'Your music',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => prov.play(prov.nowPlaying!),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22), shape: BoxShape.circle,
              ),
              child: Icon(prov.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: prov.stop,
            child: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }
}

class _PatientSongTile extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;
  final VoidCallback onTap;
  const _PatientSongTile({required this.song, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final moodColor = _moodColor(song.moodCategory);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.accent.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
          border: isPlaying ? Border.all(color: AppColors.accent.withOpacity(0.4)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                color: moodColor, size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: isPlaying ? AppColors.accent : AppColors.textPrimary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(song.artist ?? 'Your caregiver', style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary,
                  )),
                ],
              ),
            ),
            if (song.moodCategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(song.moodCategory!, style: TextStyle(
                  fontSize: 11, color: moodColor, fontWeight: FontWeight.w700,
                )),
              ),
          ],
        ),
      ),
    );
  }

  Color _moodColor(String? mood) {
    switch (mood) {
      case 'CALM': return AppColors.secondary;
      case 'HAPPY': return AppColors.success;
      case 'SAD': return AppColors.primary;
      case 'ANXIOUS': return AppColors.warning;
      default: return AppColors.accent;
    }
  }
}

class _EmptyMusic extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_rounded, size: 80, color: AppColors.textHint),
          SizedBox(height: 20),
          Text('No music yet', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          SizedBox(height: 8),
          Text('Ask your caregiver to add some music for you',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
        ],
      ),
    ),
  );
}