/// Placeholder notification service. Wire up Firebase Cloud Messaging later.
class NotificationService {
  Future<void> notifyTierUpgrade({
    required String userId,
    required String customerId,
    required String newTier,
  }) async {
    // TODO: integrate FCM push here.
    return;
  }
}
