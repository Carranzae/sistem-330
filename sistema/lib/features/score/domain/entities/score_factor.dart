import 'package:flutter/widgets.dart';

class ScoreFactor {
  final String title;
  final int score;
  final int maxScore;
  final String description;
  final Trend trend;
  final IconData icon;
  final Color color;

  ScoreFactor({
    required this.title,
    required this.score,
    required this.maxScore,
    required this.description,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

enum Trend {
  up,
  down,
  stable,
}
