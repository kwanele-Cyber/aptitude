import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_block.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/usecases/edit_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/get_session_feedback_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/respond_to_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/submit_rating_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/write_review_usecase.dart';
import 'package:myapp/injection_container.dart';

class SessionReviewSection extends StatefulWidget {
  final String sessionId;
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;

  const SessionReviewSection({
    super.key,
    required this.sessionId,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<SessionReviewSection> createState() => _SessionReviewSectionState();
}

class _SessionReviewSectionState extends State<SessionReviewSection> {
  bool _loading = true;
  bool _submitting = false;

  FeedbackEntity? _myFeedback;
  FeedbackEntity? _theirFeedback;

  int _selectedRating = 0;
  final _reviewController = TextEditingController();
  final _responseController = TextEditingController();
  bool _editing = false;
  bool _responding = false;

  String get _userName =>
      widget.currentUserName.isNotEmpty
          ? widget.currentUserName
          : _resolveNameFromAuth();

  String _resolveNameFromAuth() {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final name = authState.userEntity.name;
        if (name.trim().isNotEmpty) return name;
      }
    } catch (_) {}
    return 'You';
  }

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback() async {
    setState(() => _loading = true);
    final result = await sl<GetSessionFeedbackUseCase>()(
      GetSessionFeedbackParams(sessionId: widget.sessionId),
    );

    result.fold(
      (_) {},
      (feedbacks) {
        for (final fb in feedbacks) {
          if (fb.reviewerId == widget.currentUserId) {
            _myFeedback = fb;
            _selectedRating = fb.rating;
            _reviewController.text = fb.review ?? '';
          } else {
            _theirFeedback = fb;
            _responseController.text = fb.response ?? '';
          }
        }
      },
    );

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) return;
    setState(() => _submitting = true);

    final result = await sl<SubmitRatingUseCase>()(SubmitRatingParams(
      sessionId: widget.sessionId,
      reviewerId: widget.currentUserId,
      reviewerName: _userName,
      revieweeId: widget.otherUserId,
      revieweeName: widget.otherUserName,
      rating: _selectedRating,
    ));

    result.fold(
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit rating'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (feedback) {
        _myFeedback = feedback;
        // If there's a review text, write it now
        if (_reviewController.text.trim().isNotEmpty) {
          _writeReview(feedback.id);
        } else {
          if (mounted) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rating submitted!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _writeReview(String feedbackId) async {
    final result = await sl<WriteReviewUseCase>()(WriteReviewParams(
      feedbackId: feedbackId,
      review: _reviewController.text.trim(),
    ));

    result.fold(
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit review'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (feedback) {
        _myFeedback = feedback;
        if (mounted) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Future<void> _editReview() async {
    if (_myFeedback == null) return;
    setState(() => _submitting = true);

    final result = await sl<EditReviewUseCase>()(EditReviewParams(
      feedbackId: _myFeedback!.id,
      review: _reviewController.text.trim(),
    ));

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _editing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? 'Failed to edit review'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (feedback) {
        _myFeedback = feedback;
        if (mounted) {
          setState(() {
            _submitting = false;
            _editing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Future<void> _respondToReview() async {
    if (_theirFeedback == null) return;
    setState(() => _submitting = true);

    final result = await sl<RespondToReviewUseCase>()(RespondToReviewParams(
      feedbackId: _theirFeedback!.id,
      response: _responseController.text.trim(),
    ));

    result.fold(
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit response'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (feedback) {
        _theirFeedback = feedback;
        if (mounted) {
          setState(() {
            _submitting = false;
            _responding = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Response submitted!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          'Feedback',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_myFeedback == null) _buildRatePrompt(),
        if (_myFeedback != null) _buildMyReview(),
        const SizedBox(height: 16),
        if (_theirFeedback != null) _buildTheirReview(),
      ],
    );
  }

  Widget _buildRatePrompt() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your session with ${widget.otherUserName}?',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < _selectedRating;
                  return IconButton(
                    icon: Icon(
                      filled ? Icons.star : Icons.star_border,
                      size: 36,
                      color: filled ? Colors.amber : Colors.grey.shade300,
                    ),
                    onPressed:
                        _submitting ? null : () => setState(() => _selectedRating = i + 1),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: 'Write a review (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedRating == 0 || _submitting
                    ? null
                    : _submitRating,
                icon: const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting...' : 'Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReview() {
    final canEdit = _myFeedback!.canEditReview;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Your review:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < _myFeedback!.rating ? Icons.star : Icons.star_border,
                      size: 18,
                      color: i < _myFeedback!.rating
                          ? Colors.amber
                          : Colors.grey.shade300,
                    );
                  }),
                ),
              ],
            ),
            if (_editing) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  hintText: 'Update your review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitting ? null : _editReview,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ] else ...[
              if (_myFeedback!.review != null &&
                  _myFeedback!.review!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_myFeedback!.review!),
              ],
              if (canEdit) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTheirReview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Review from ${_theirFeedback!.reviewerName}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < _theirFeedback!.rating
                          ? Icons.star
                          : Icons.star_border,
                      size: 18,
                      color: i < _theirFeedback!.rating
                          ? Colors.amber
                          : Colors.grey.shade300,
                    );
                  }),
                ),
              ],
            ),
            if (_theirFeedback!.review != null &&
                _theirFeedback!.review!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_theirFeedback!.review!),
            ],
            if (_theirFeedback!.response != null &&
                _theirFeedback!.response!.isNotEmpty) ...[
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _theirFeedback!.response!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (_responding) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _responseController,
                decoration: const InputDecoration(
                  hintText: 'Write your response...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _responding = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitting ? null : _respondToReview,
                    child: const Text('Respond'),
                  ),
                ],
              ),
            ] else if (_theirFeedback!.response == null ||
                _theirFeedback!.response!.isEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _responding = true),
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Respond'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
