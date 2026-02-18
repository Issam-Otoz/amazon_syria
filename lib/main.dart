import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:amazon_syria/core/theme/app_theme.dart';
import 'package:amazon_syria/core/constants/app_constants.dart';
import 'package:amazon_syria/core/di/injection_container.dart';
import 'package:amazon_syria/core/router/app_router.dart';

import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';
import 'package:amazon_syria/features/products/presentation/providers/product_provider.dart';
import 'package:amazon_syria/features/chat/presentation/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running without Firebase — configure it to enable backend features.');
  }

  await initializeDependencies();

  runApp(const AmazonSyriaApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      storageBucket: 'YOUR_STORAGE_BUCKET',
    );
  }
}

class AmazonSyriaApp extends StatelessWidget {
  const AmazonSyriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<AuthProvider>()),
        ChangeNotifierProvider.value(value: sl<ProductProvider>()),
        ChangeNotifierProvider.value(value: sl<ChatProvider>()),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          locale: const Locale('ar'),
        ),
      ),
    );
  }
}
