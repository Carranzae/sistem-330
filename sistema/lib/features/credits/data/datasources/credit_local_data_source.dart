import '../../domain/entities/credit.dart';

abstract class CreditLocalDataSource {
  Future<List<Credit>> getCredits();
  Future<void> addCredit(Credit credit);
}

class CreditLocalDataSourceImpl implements CreditLocalDataSource {
  // Simulación de una base de datos en memoria
  final List<Credit> _credits = [];

  @override
  Future<List<Credit>> getCredits() async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 300));
    return _credits;
  }

  @override
  Future<void> addCredit(Credit credit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _credits.add(credit);
  }
}
