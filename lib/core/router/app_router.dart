import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/permission_screen.dart';
import '../../features/auth/screens/terms_screen.dart';
import '../../features/car/screens/car_list_screen.dart';
import '../../features/car/screens/car_form_screen.dart';
import '../../features/scan/screens/scan_screen.dart';
import '../../features/scan/screens/analysis_result_screen.dart';
import '../../features/maintenance/screens/maintenance_list_screen.dart';
import '../../features/maintenance/screens/maintenance_detail_screen.dart';
import '../../features/maintenance/screens/work_description_screen.dart';
import '../../models/maintenance_item_model.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/garage/screens/garage_screen.dart';
import '../../features/garage/screens/garage_detail_screen.dart';
import '../../features/garage/screens/region_search_screen.dart';
import '../../core/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authService = ref.read(authServiceProvider);
      final isAuthenticated = authService.currentUser != null;
      final location = state.matchedLocation;

      // 스플래시, 권한 화면은 항상 허용
      if (location == '/' || location == '/terms' || location == '/permission') return null;

      // 비인증 상태에서 보호된 페이지 접근 시 스플래시로
      if (!isAuthenticated) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/permission',
        builder: (context, state) => const PermissionScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/maintenance',
            builder: (context, state) => const MaintenanceListScreen(),
          ),
          GoRoute(
            path: '/garage',
            builder: (context, state) => const GarageScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/cars',
        builder: (context, state) => const CarListScreen(),
      ),
      GoRoute(
        path: '/cars/add',
        builder: (context, state) => const CarFormScreen(),
      ),
      GoRoute(
        path: '/cars/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CarFormScreen(carId: id);
        },
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/scan/result',
        builder: (context, state) => const AnalysisResultScreen(),
      ),
      GoRoute(
        path: '/maintenance/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaintenanceDetailScreen(recordId: id);
        },
      ),
      GoRoute(
        path: '/work-description',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WorkDescriptionScreen(
            system: extra['system'] as String,
            items: extra['items'] as List<MaintenanceItemModel>,
            date: extra['date'] as DateTime,
            mileage: extra['mileage'] as int,
          );
        },
      ),
      GoRoute(
        path: '/region-search',
        builder: (context, state) => const RegionSearchScreen(),
      ),
      GoRoute(
        path: '/garage/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GarageDetailScreen(garageId: id);
        },
      ),
    ],
  );
});
