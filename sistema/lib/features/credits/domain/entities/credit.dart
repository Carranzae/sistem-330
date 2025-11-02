class Credit {
  final String id;
  final String clientId;
  final double amount;
  final DateTime date;
  final String status; // 'pending', 'paid', 'overdue'

  Credit({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.date,
    this.status = 'pending',
  });
}
