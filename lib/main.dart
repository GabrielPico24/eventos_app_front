import 'package:event_app/core/services/notification_service.dart';
import 'package:event_app/core/services/timezone_service.dart';
import 'package:event_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
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

  await TimezoneService.init();
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
