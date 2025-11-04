import 'package:flutter/material.dart';
import '../../domain/entities/credit.dart';
import '../../domain/repositories/credit_repository.dart';

class CreditProvider extends ChangeNotifier {
  final CreditRepository creditRepository;

  CreditProvider({required this.creditRepository});

  List<Credit> _credits = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Credit> get credits => _credits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lógica de negocio
  Future<void> fetchCredits() async {
    _setLoading(true);
    try {
      _credits = await creditRepository.getCredits();
    } catch (e) {
      _errorMessage = 'Error al cargar los créditos.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCredit(String clientId, double amount) async {
    _setLoading(true);
    try {
      await creditRepository.addCredit(clientId, amount);
      await fetchCredits(); // Recargar la lista después de añadir
    } catch (e) {
      _errorMessage = 'Error al añadir el crédito.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
