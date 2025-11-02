import '../../domain/entities/credit.dart';

abstract class CreditRepository {
  Future<List<Credit>> getCredits();
  Future<void> addCredit(String clientId, double amount);
}
