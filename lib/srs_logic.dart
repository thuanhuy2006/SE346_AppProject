class SrsLogic {
  /// Simple SM-2 algorithm implementation
  /// [quality] should be 0-5
  /// Returns a Map with 'interval' (days) and 'easeFactor'
  static Map<String, dynamic> calculateNextReview(int interval, double easeFactor, int quality) {
    int nextInterval;
    double nextEaseFactor = easeFactor;

    if (quality >= 3) {
      // Correct response
      if (interval == 0) {
        nextInterval = 1;
      } else if (interval == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (interval * easeFactor).round();
      }

      // Update ease factor
      nextEaseFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    } else {
      // Incorrect response
      nextInterval = 1;
    }

    if (nextEaseFactor < 1.3) nextEaseFactor = 1.3;

    return {
      'interval': nextInterval,
      'easeFactor': nextEaseFactor,
    };
  }
}
