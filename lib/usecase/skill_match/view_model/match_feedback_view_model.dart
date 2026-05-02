import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/core/data/models/match_feedback.dart';
import 'package:myapp/core/data/repositories/match_feedback_repository.dart';

class MatchFeedbackViewModel extends ChangeNotifier {
  final MatchFeedbackRepository _repo;
  bool submitting = false;

  MatchFeedbackViewModel({MatchFeedbackRepository? repo})
      : _repo = repo ?? MatchFeedbackRepository();

  Future<void> submitFeedback({
    required String fromUid,
    required String toUid,
    required int rating,
    String? note,
  }) async {
    submitting = true;
    notifyListeners();
    try {
      final feedback = MatchFeedback(
        id: const Uuid().v4(),
        fromUid: fromUid,
        toUid: toUid,
        rating: rating.clamp(1, 5),
        note: note,
      );
      await _repo.submit(feedback);
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
