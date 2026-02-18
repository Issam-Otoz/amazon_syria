import 'package:get_it/get_it.dart';

import 'package:amazon_syria/features/auth/domain/repositories/auth_repository.dart';
import 'package:amazon_syria/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';

import 'package:amazon_syria/features/products/domain/repositories/product_repository.dart';
import 'package:amazon_syria/features/products/data/repositories/product_repository_impl.dart';
import 'package:amazon_syria/features/products/presentation/providers/product_provider.dart';

import 'package:amazon_syria/features/chat/domain/repositories/chat_repository.dart';
import 'package:amazon_syria/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:amazon_syria/features/chat/presentation/providers/chat_provider.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );

  // Providers
  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ProductProvider>(
    () => ProductProvider(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<ChatProvider>(
    () => ChatProvider(sl<ChatRepository>()),
  );
}
