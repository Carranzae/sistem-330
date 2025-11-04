import '../../domain/entities/credit.dart';
import '../../domain/repositories/credit_repository.dart';
import '../datasources/credit_local_data_source.dart';

class CreditRepositoryImpl implements CreditRepository {
  final CreditLocalDataSource localDataSource;

  CreditRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Credit>> getCredits() {
    return localDataSource.getCredits();
  }

  @override
  Future<void> addCredit(String clientId, double amount) {
    final newCredit = Credit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      amount: amount,
      date: DateTime.now(),
    );
    return localDataSource.addCredit(newCredit);
  }
}
