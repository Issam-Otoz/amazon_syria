import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:amazon_syria/firebase_options.dart';
import 'package:amazon_syria/core/theme/app_theme.dart';
import 'package:amazon_syria/core/constants/app_constants.dart';
import 'package:amazon_syria/core/di/injection_container.dart';
import 'package:amazon_syria/core/router/app_router.dart';

import 'package:amazon_syria/core/services/ad_service.dart';
import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';
import 'package:amazon_syria/features/products/presentation/providers/product_provider.dart';
import 'package:amazon_syria/features/chat/presentation/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AdService().initialize();
  await initializeDependencies();

  runApp(const AmazonSyriaApp());
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
