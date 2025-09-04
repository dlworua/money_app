enum SubscriptionPlan {
  monthly('monthly', 30),
  yearly('yearly', 365);

  const SubscriptionPlan(this.id, this.days);
  final String id;
  final int days;
}