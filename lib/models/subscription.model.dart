class SubscriptionModel {
  final String? id;

  final bool isPremium;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  SubscriptionModel({
    this.id,
    this.isPremium = false,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isPremium': isPremium,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
    };
  }
}
