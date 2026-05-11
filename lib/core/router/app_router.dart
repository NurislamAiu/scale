import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scale/core/di/injection.dart';
import 'package:smart_scale/core/presentation/pages/main_shell.dart';
import 'package:smart_scale/core/router/go_router_refresh_stream.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:smart_scale/features/profile/presentation/pages/onboarding_page.dart';
import 'package:smart_scale/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_scale/features/profile/presentation/pages/profile_page.dart';
import 'package:smart_scale/features/profile/presentation/pages/reminders_page.dart';
import 'package:smart_scale/features/reminders/presentation/bloc/reminders_bloc.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';
import 'package:smart_scale/features/scale/presentation/pages/home_page.dart';
import 'package:smart_scale/features/scale/presentation/pages/my_devices_page.dart';
import 'package:smart_scale/features/workouts/presentation/pages/workouts_page.dart';
import 'package:smart_scale/features/workouts/presentation/pages/workout_detail_page.dart';
import 'package:smart_scale/features/workouts/presentation/pages/workout_execute_page.dart';
import 'package:smart_scale/features/workouts/presentation/pages/workout_history_page.dart';
import 'package:smart_scale/features/analytics/presentation/pages/analytics_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static GoRouter createRouter(ProfileBloc profileBloc) {
    // Фильтруем поток состояний.
    // Роутеру не нужно перестраивать все приложение при каждом чихе (например, при статусе saving или error).
    // Ему важны только глобальные переходы: Загрузка -> Онбординг -> Приложение.
    // Это избавляет от ошибки "Duplicate GlobalKey" при закрытии страниц с одновременным обновлением BLoC.
    final authStream = profileBloc.stream.map((state) {
      switch (state.status) {
        case ProfileStatus.initial:
        case ProfileStatus.loading:
          return 0; // Splash
        case ProfileStatus.missing:
          return 1; // Onboarding
        case ProfileStatus.loaded:
        case ProfileStatus.saving:
        case ProfileStatus.saved:
        case ProfileStatus.error:
          return 2; // Основное приложение
      }
    }).distinct();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authStream),
      redirect: (context, state) {
        final profileState = profileBloc.state;
        
        final isSplash = state.matchedLocation == '/splash';
        final isOnboarding = state.matchedLocation == '/onboarding';
        
        // Если данные еще грузятся
        if (profileState.status == ProfileStatus.initial || 
            profileState.status == ProfileStatus.loading) {
          return '/splash';
        }
        
        // Если профиля нет
        if (profileState.status == ProfileStatus.missing) {
          return '/onboarding';
        }
        
        // Если профиль есть (или сохраняется) -> Пускаем в приложение
        if (profileState.status == ProfileStatus.loaded || 
            profileState.status == ProfileStatus.saved || 
            profileState.status == ProfileStatus.saving) {
          if (isSplash || isOnboarding) {
            return '/dashboard';
          }
        }
        
        return null; // Никакой редирект не нужен, остаемся там где были
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const _SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BlocProvider(
              create: (context) => getIt<ScaleBloc>(),
              child: MainShell(navigationShell: navigationShell),
            );
          },
          branches: [
            // Branch 0: Dashboard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            // Branch 1: Insights
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/insights',
                  builder: (context, state) => BlocProvider(
                    create: (context) => getIt<AnalyticsBloc>()..add(const AnalyticsLoadRequested()),
                    child: const AnalyticsPage(),
                  ),
                ),
              ],
            ),
            // Branch 2: Workouts
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/workouts',
                  builder: (context, state) => const WorkoutsPage(),
                  routes: [
                    GoRoute(
                      path: 'detail/:programIndex',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final index = state.pathParameters['programIndex'] ?? '0';
                        return WorkoutDetailPage(programIndex: index);
                      },
                    ),
                    GoRoute(
                      path: 'execute/:programIndex/:dayIndex',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final pIndex = state.pathParameters['programIndex'] ?? '0';
                        final dIndex = state.pathParameters['dayIndex'] ?? '0';
                        return WorkoutExecutePage(
                          programIndex: pIndex,
                          dayIndex: dIndex,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'history',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const WorkoutHistoryPage(),
                    ),
                  ],
                ),
              ],
            ),
            // Branch 3: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey, // Overlay bottom nav
                      builder: (context, state) {
                        final profile = state.extra as UserProfile?;
                        if (profile == null) return const SizedBox.shrink();
                        return EditProfilePage(profile: profile);
                      },
                    ),
                    GoRoute(
                      path: 'my-devices',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        return BlocProvider.value(
                          value: getIt<ScaleBloc>(),
                          child: const MyDevicesPage(),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'reminders',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => BlocProvider(
                        create: (context) => getIt<RemindersBloc>()..add(const RemindersLoadRequested()),
                        child: const RemindersPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// Temporary Splash Page
class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF141414),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFD4FF45)),
      ),
    );
  }
}

// Placeholder Page
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text(
          "Раздел \"$title\" в разработке",
          style: const TextStyle(color: Color(0xFFA0A0A5), fontSize: 16),
        ),
      ),
    );
  }
}
