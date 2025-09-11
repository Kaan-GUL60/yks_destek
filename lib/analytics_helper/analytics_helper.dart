import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class AnalyticsService {
  Future<void> trackCount(String tag, String parametre) async {
    // tag olay yani buttonClick parametre ise ahngi butonolduğu
    await analytics.logEvent(name: tag, parameters: {"kaynak": parametre});
  }
}
