import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';
import 'package:amazon_syria/features/auth/presentation/pages/login_page.dart';
import 'package:amazon_syria/features/auth/presentation/pages/register_page.dart';
import 'package:amazon_syria/features/products/presentation/pages/home_page.dart';
import 'package:amazon_syria/features/products/presentation/pages/product_detail_page.dart';
import 'package:amazon_syria/features/products/presentation/pages/add_product_page.dart';
import 'package:amazon_syria/features/chat/presentation/pages/chat_list_page.dart';
import 'package:amazon_syria/features/chat/presentation/pages/chat_page.dart';

class AppRouter {
  AppRouter._();

  static final _authProvider = GetIt.instance<AuthProvider>();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = _authProvider.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/add-product',
        name: 'add-product',
        builder: (context, state) => const AddProductPage(),
      ),
      GoRoute(
        path: '/chats',
        name: 'chats',
        builder: (context, state) => const ChatListPage(),
      ),
      GoRoute(
        path: '/chat/:roomId',
        name: 'chat',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          return ChatPage(roomId: roomId);
        },
      ),
    ],
  );
}
