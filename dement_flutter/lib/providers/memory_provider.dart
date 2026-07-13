import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/memory_model.dart';
import '../data/services/memory_service.dart';

class MemoryProvider extends ChangeNotifier {

  List<MemoryModel> _memories = [];

  bool _isLoading = false;

  String? _error;

  List<MemoryModel> get memories => _memories;

  bool get isLoading => _isLoading;

  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchMemories() async {

    _setLoading(true);

    _setError(null);

    try {

      _memories =
      await MemoryService.getMemories();

    } catch (e) {

      _setError(_parse(e));

    } finally {

      _setLoading(false);
    }
  }

  Future<bool> addMemory({

    required String title,

    String? description,

    String? relationInfo,

    String? category,

    String? tags,

    XFile? imageFile,

  }) async {

    print('==============================');
    print('ADDING MEMORY STARTED');
    print('TITLE: $title');
    print('CATEGORY: $category');
    print('IMAGE: ${imageFile?.path}');
    print('==============================');

    _setLoading(true);

    _setError(null);

    try {

      final m =
      await MemoryService.createMemory(

        title: title,

        description: description,

        relationInfo: relationInfo,

        category: category,

        tags: tags,

        imageFile: imageFile,
      );

      _memories.insert(0, m);

      notifyListeners();

      return true;

    } catch (e) {

      print('MEMORY ERROR: $e');

      _setError(_parse(e));

      return false;

    } finally {

      _setLoading(false);
    }
  }

  Future<bool> deleteMemory(int id) async {

    _setLoading(true);

    try {

      await MemoryService.deleteMemory(id);

      _memories.removeWhere(
            (m) => m.id == id,
      );

      notifyListeners();

      return true;

    } catch (e) {

      _setError(_parse(e));

      return false;

    } finally {

      _setLoading(false);
    }
  }

  Future<void> updateMemory({

    required int memoryId,

    required String title,

    required String description,

    required String relationInfo,

  }) async {

    _setLoading(true);

    try {

      await MemoryService.updateMemory(

        memoryId: memoryId,

        title: title,

        description: description,

        relationInfo: relationInfo,
      );

      await fetchMemories();

    } catch (e) {

      _setError(_parse(e));

      rethrow;

    } finally {

      _setLoading(false);
    }
  }

  String _parse(Object e) {

    final s = e.toString();

    if (s.contains('Connection refused') ||
        s.contains('SocketException')) {

      return 'Cannot reach server. Is backend running?';
    }

    return 'Something went wrong.';
  }
}