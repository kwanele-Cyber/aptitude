import 'package:myapp/core/utils/geo_utils.dart';

String formatTimestamp(DateTime dt) => dt.toIso8601String();

int _levelIndex(String level) {
  switch (level) {
    case 'intermediate':
      return 1;
    case 'advanced':
      return 2;
    default:
      return 0;
  }
}

({double score, double? distance, List<String> commonAvailability})
    calculateMatchScore({
  required String categoryA,
  required String levelA,
  required String formatA,
  required List<String> tagsA,
  required double? latA,
  required double? lngA,
  required List<String> availabilityA,
  required String categoryB,
  required String levelB,
  required String formatB,
  required List<String> tagsB,
  required double? latB,
  required double? lngB,
  required List<String> availabilityB,
}) {
  double score = 0;

  // Category match: up to 30 points
  if (categoryA.toLowerCase() == categoryB.toLowerCase()) {
    score += 30;
  } else if (categoryA.toLowerCase().contains(categoryB.toLowerCase()) ||
      categoryB.toLowerCase().contains(categoryA.toLowerCase())) {
    score += 15;
  }

  // Level compatibility: up to 25 points
  final levelDiff = (_levelIndex(levelA) - _levelIndex(levelB)).abs();
  if (levelDiff == 0) {
    score += 25;
  } else if (levelDiff == 1) {
    score += 15;
  } else {
    score += 5;
  }

  // Format compatibility: up to 20 points
  if (formatA == formatB) {
    score += 20;
  } else if (formatA == 'both' || formatB == 'both') {
    score += 10;
  }

  // Tag overlap: up to 15 points
  final commonTags = tagsA.where((t) => tagsB.contains(t)).length;
  score += (commonTags * 5).clamp(0, 15);

  // Geo-proximity: up to 10 points
  double? distance;
  if (latA != null && lngA != null && latB != null && lngB != null) {
    distance = haversineDistance(latA, lngA, latB, lngB);
    if (distance <= 5) {
      score += 10;
    } else if (distance <= 20) {
      score += 7;
    } else if (distance <= 50) {
      score += 4;
    } else {
      score += 1;
    }
  }

  // Availability overlap: up to 5 points
  final commonA =
      availabilityA.where((slot) => availabilityB.contains(slot)).toList();
  score += (commonA.length * 2).clamp(0, 5);

  return (
    score: score.clamp(0, 100).toDouble(),
    distance: distance,
    commonAvailability: commonA,
  );
}
