import '../../domain/entities/score_factor.dart';
import '../../domain/repositories/score_repository.dart';
import '../datasources/score_local_data_source.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreLocalDataSource localDataSource;

  ScoreRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ScoreFactor>> getScoreFactors(String category) async {
    // En un futuro, aquí se decidiría si obtener los datos de una fuente
    // remota o local (cache). Por ahora, solo llamamos a la local.
    return localDataSource.getScoreFactors(category);
  }
}
