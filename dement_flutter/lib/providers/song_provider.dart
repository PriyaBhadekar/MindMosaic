// CREATE lib/providers/song_provider.dart
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/song_model.dart';
import '../data/services/song_service.dart';

class SongProvider extends ChangeNotifier {
  List<SongModel> _songs = [];
  bool _isLoading = false;
  String? _error;

  // Playback state
  final AudioPlayer _player = AudioPlayer();
  SongModel? _nowPlaying;
  bool _isPlaying = false;

  List<SongModel> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SongModel? get nowPlaying => _nowPlaying;
  bool get isPlaying => _isPlaying;
  AudioPlayer get player => _player;

  SongProvider() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  Future<void> fetchSongs() async {
    _setLoading(true);
    _setError(null);
    try {
      _songs = await SongService.getSongs();
    } catch (e) {
      _setError(_parse(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadSong({
    required String title,
    String? artist,
    String? moodCategory,
    XFile? audioFile,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final s = await SongService.uploadSong(
        title: title,
        artist: artist,
        moodCategory: moodCategory,
        audioFile: audioFile,
      );
      _songs.insert(0, s);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSong(int id) async {
    try {
      await SongService.deleteSong(id);
      if (_nowPlaying?.id == id) await stop();
      _songs.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_parse(e));
      return false;
    }
  }

  Future<void> play(SongModel song) async {
    try {
      final url =
          'http://localhost:8080/${song.audioPath?.replaceAll('\\', '/') ?? ''}';
      print('PLAYING URL: $url');
      if (_nowPlaying?.id == song.id) {
        if (_isPlaying) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }
      _nowPlaying = song;
      notifyListeners();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      // Audio playback error — gracefully fail
      _nowPlaying = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _nowPlaying = null;
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _parse(Object e) {
    final s = e.toString();
    if (s.contains('Connection refused') || s.contains('SocketException')) {
      return 'Cannot reach server. Is the backend running?';
    }
    return 'Something went wrong. Please try again.';
  }
}