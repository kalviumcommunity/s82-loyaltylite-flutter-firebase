class TierConstants {
  TierConstants._();

  static const int bronzeMax = 100;
  static const int silverMax = 300;
  static const int goldMax = 700;

  static String tierForPoints(int points) {
    if (points <= bronzeMax) return 'Bronze';
    if (points <= silverMax) return 'Silver';
    if (points <= goldMax) return 'Gold';
    return 'Platinum';
  }
}
