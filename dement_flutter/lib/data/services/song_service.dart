import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import '../models/song_model.dart';
import 'api_client.dart';

class SongService {
  static Future<List<SongModel>> getSongs() async {
    final response = await ApiClient.get('/api/songs');
    final List data = response['data'] ?? [];
    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  static Future<List<SongModel>> getSongsByMood(String mood) async {
    final response = await ApiClient.get('/api/songs/mood/$mood');
    final List data = response['data'] ?? [];
    return data.map((e) => SongModel.fromJson(e)).toList();
  }

  static Future<SongModel> uploadSong({
    required String title,
    String? artist,
    String? moodCategory,
    XFile? audioFile,
  }) async {

    final formData = FormData();

    formData.fields.add(
      MapEntry(
        'data',
        '''
{
  "title": "$title",
  "artist": "${artist ?? ''}",
  "moodCategory": "${moodCategory ?? 'CALM'}"
}
''',
      ),
    );

    if (audioFile != null) {

      print('AUDIO FILE PATH = ${audioFile.path}');

      formData.files.add(
        MapEntry(
          'audio',
          MultipartFile.fromBytes(
            await audioFile.readAsBytes(),
            filename: audioFile.name,
          ),
        ),
      );
    }

    final response =
    await ApiClient.postMultipart('/api/songs', formData);

    return SongModel.fromJson(response['data']);
  }

  static Future<void> deleteSong(int songId) async {
    await ApiClient.delete('/api/songs/$songId');
  }
}