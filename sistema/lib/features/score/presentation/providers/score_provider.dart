import 'package:flutter/material.dart';
import '../../domain/entities/score_factor.dart';
import '../../domain/usecases/get_score_factors.dart';

class ScoreProvider extends ChangeNotifier {
  final GetScoreFactors getScoreFactors;

  ScoreProvider({required this.getScoreFactors});

  bool _isLoading = false;
  List<ScoreFactor> _factors = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<ScoreFactor> get factors => _factors;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFactors(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _factors = await getScoreFactors(category);
    } catch (e) {
      _errorMessage = 'Ocurrió un error al cargar los factores del score.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
