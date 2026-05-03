import 'package:flutter/material.dart';
import 'package:myapp/core/data/models/session_material.dart';
import 'package:myapp/core/data/repositories/material_repository.dart';
import 'package:myapp/core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class MaterialViewModel extends ChangeNotifier {
  final MaterialRepository _materialRepo;
  final AuthService? _auth;
  final Future<String?> Function()? _currentUidProvider;
  final String sessionId;

  MaterialViewModel({
    required this.sessionId,
    MaterialRepository? materialRepo,
    AuthService? auth,
    Future<String?> Function()? currentUidProvider,
  }) : _materialRepo = materialRepo ?? MaterialRepository(),
       _auth = auth,
       _currentUidProvider = currentUidProvider;

  List<SessionMaterial> _materials = [];
  List<SessionMaterial> get materials => _materials;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> loadMaterials() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _materials = await _materialRepo.getSessionMaterials(sessionId);
    } catch (e) {
      _errorMessage = 'Could not load materials';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> shareMaterial({
    required String name,
    required String url,
    SessionMaterialType type = SessionMaterialType.document,
    int fileSize = 0,
  }) async {
    _clearError();
    if (!_validateInput(name, url)) return;

    _isUploading = true;
    notifyListeners();

    final uid = await _currentUid();
    if (uid == null) {
      _isUploading = false;
      _setError('You must be signed in to share materials');
      notifyListeners();
      return;
    }

    try {
      final material = SessionMaterial(
        id: const Uuid().v4(),
        sessionId: sessionId,
        name: name.trim(),
        url: url.trim(),
        type: type,
        uploadedBy: uid,
        uploadedAt: DateTime.now(),
        fileSize: fileSize,
      );

      await _materialRepo.uploadMaterial(material);
      await loadMaterials();
    } catch (e) {
      _errorMessage = 'Could not upload material';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMaterial(SessionMaterial material) async {
    _clearError();
    final uid = await _currentUid();
    if (uid == null) {
      _setError('You must be signed in to delete materials');
      return;
    }
    if (material.uploadedBy != uid) {
      _setError('You can only delete materials you uploaded');
      return;
    }

    try {
      await _materialRepo.deleteMaterial(material.sessionId, material.id);
      await loadMaterials();
    } catch (e) {
      _errorMessage = 'Could not delete material';
    }
  }

  bool _validateInput(String name, String url) {
    if (name.trim().isEmpty) {
      _setError('Material name is required');
      return false;
    }
    if (url.trim().isEmpty) {
      _setError('Material URL is required');
      return false;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) {
      _setError('Material URL must be a valid URL');
      return false;
    }
    return true;
  }

  Future<String?> _currentUid() async {
    if (_currentUidProvider != null) {
      return _currentUidProvider();
    }
    return (await (_auth ?? AuthService()).getCurrentUser())?.uid;
  }
}
