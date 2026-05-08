import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/usecases/view_reviews_usecase.dart';
import 'package:myapp/injection_container.dart';

class UserReviewsSection extends StatefulWidget {
  final String userId;

  const UserReviewsSection({super.key, required this.userId});

  @override
  State<UserReviewsSection> createState() => _UserReviewsSectionState();
}

class _UserReviewsSectionState extends State<UserReviewsSection> {
  Future<Either<Failure, List<FeedbackEntity>>>? _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<Either<Failure, List<FeedbackEntity>>> _loadReviews() {
    return sl<ViewReviewsUseCase>()(ViewReviewsParams(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<Failure, List<FeedbackEntity>>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data;
        if (result == null) return const SizedBox.shrink();

        return result.fold(
          (failure) => const SizedBox.shrink(),
          (reviews) {
            if (reviews.isEmpty) return const SizedBox.shrink();

            final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                Row(
                  children: [
                    const Text(
                      'Reviews',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    _StarRating(
                      rating: avg,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${avg.toStringAsFixed(1)} (${reviews.length})',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...reviews.map((r) => _ReviewCard(feedback: r)),
              ],
            );
          },
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final FeedbackEntity feedback;

  const _ReviewCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StarRating(rating: feedback.rating.toDouble(), size: 16),
                const Spacer(),
                Text(
                  feedback.reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (feedback.review != null && feedback.review!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(feedback.review!),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(feedback.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (feedback.response != null &&
                feedback.response!.isNotEmpty) ...[
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
                          feedback.response!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(feedback.respondedAt!),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.round();
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: size,
          color: filled ? Colors.amber : Colors.grey.shade300,
        );
      }),
    );
  }
}
