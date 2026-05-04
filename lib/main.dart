import 'package:event_app/core/services/notification_service.dart';
import 'package:event_app/core/services/push_notification_service.dart';
import 'package:event_app/core/services/timezone_service.dart';
import 'package:event_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await TimezoneService.init();
  await NotificationService.instance.init();

  await PushNotificationService.instance.init(
    onNotificationTap: (data) async {
      debugPrint('📲 Push tocada');
      debugPrint('📦 DATA: $data');

      // Aquí luego conectamos navegación al evento.
      // final eventId = data['eventId']?.toString();
    },
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
