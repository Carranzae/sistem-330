import '../entities/score_factor.dart';

abstract class ScoreRepository {
  Future<List<ScoreFactor>> getScoreFactors(String category);
}
