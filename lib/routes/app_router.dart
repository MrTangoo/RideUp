import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/home/presentation/screens/main_screen.dart';
import '../features/horses/presentation/screens/horses_list_screen.dart';
import '../features/horses/presentation/screens/horse_detail_screen.dart';
import '../features/horses/presentation/screens/horse_form_screen.dart';
import '../features/tracking/presentation/screens/tracking_screen.dart';
import '../features/stats/presentation/screens/stats_screen.dart';
import '../features/health/presentation/screens/health_screen.dart';
import '../features/planning/presentation/screens/planning_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');

      // If authenticated and trying to access auth routes, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // If not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),

      // Horses routes
      GoRoute(
        path: '/horses',
        builder: (context, state) => const HorsesListScreen(),
      ),
      GoRoute(
        path: '/horses/add',
        builder: (context, state) => const HorseFormScreen(),
      ),
      GoRoute(
        path: '/horses/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return HorseFormScreen(horseId: id);
        },
      ),
      GoRoute(
        path: '/horses/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return HorseDetailScreen(horseId: id);
        },
      ),
      GoRoute(
        path: '/horses/:id/health',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return HealthScreen(horseId: id);
        },
      ),

      // Tracking routes
      GoRoute(
        path: '/tracking/start',
        builder: (context, state) {
          final horseId = state.uri.queryParameters['horseId']!;
          return TrackingScreen(horseId: horseId);
        },
      ),

      // Stats route
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),

      // Planning route
      GoRoute(
        path: '/planning',
        builder: (context, state) => const PlanningScreen(),
      ),

      // Premium route
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80),
            const SizedBox(height: 16),
            const Text('Page non trouvée'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});
