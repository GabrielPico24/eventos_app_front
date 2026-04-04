// lib/core/services/timezone_service.dart
import 'package:timezone/data/latest_all.dart' as tz;

class TimezoneService {
  static Future<void> init() async {
    tz.initializeTimeZones();
  }
}