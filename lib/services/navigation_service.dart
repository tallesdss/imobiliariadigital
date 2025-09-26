import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_selection_screen.dart';
import '../screens/user/user_home_screen.dart';
import '../screens/user/property_detail_screen.dart';
import '../screens/user/favorites_screen.dart';
import '../screens/user/alerts_screen.dart';
import '../screens/user/user_chat_screen.dart';
import '../screens/realtor/realtor_home_screen.dart';
import '../screens/realtor/property_form_screen.dart';
import '../screens/realtor/realtor_profile_screen.dart';
import '../screens/realtor/realtor_chat_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_realtors_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_chat_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-selection',
        name: 'profile-selection',
        builder: (context, state) => const ProfileSelectionScreen(),
      ),

      // User Routes
      GoRoute(
        path: '/user',
        name: 'user-home',
        builder: (context, state) => const UserHomeScreen(),
        routes: [
          GoRoute(
            path: '/property/:propertyId',
            name: 'property-detail',
            builder: (context, state) => PropertyDetailScreen(
              propertyId: state.pathParameters['propertyId']!,
            ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/alerts',
            name: 'alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'user-chat',
            builder: (context, state) => const UserChatScreen(),
          ),
        ],
      ),

      // Realtor Routes
      GoRoute(
        path: '/realtor',
        name: 'realtor-home',
        builder: (context, state) => const RealtorHomeScreen(),
        routes: [
          GoRoute(
            path: '/property/new',
            name: 'property-new',
            builder: (context, state) => const PropertyFormScreen(),
          ),
          GoRoute(
            path: '/property/edit/:propertyId',
            name: 'property-edit',
            builder: (context, state) => PropertyFormScreen(
              propertyId: state.pathParameters['propertyId'],
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'realtor-profile',
            builder: (context, state) => const RealtorProfileScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'realtor-chat',
            builder: (context, state) => const RealtorChatScreen(),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin-home',
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: '/realtors',
            name: 'admin-realtors',
            builder: (context, state) => const AdminRealtorsScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/chat',
            name: 'admin-chat',
            builder: (context, state) => const AdminChatScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Rota: ${state.uri}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
}
