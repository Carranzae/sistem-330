import '../entities/score_factor.dart';
import '../repositories/score_repository.dart';

class GetScoreFactors {
  final ScoreRepository repository;

  GetScoreFactors(this.repository);

  Future<List<ScoreFactor>> call(String category) {
    return repository.getScoreFactors(category);
  }
}
