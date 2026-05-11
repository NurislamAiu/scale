import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smart_scale/core/di/injection.dart';
import 'package:smart_scale/core/router/app_router.dart';
import 'package:smart_scale/core/notifications/notification_service.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDi();
  // Инициализация локали для форматирования дат на русском
  await initializeDateFormatting('ru_RU', null); 
  // Инициализация сервиса уведомлений
  await getIt<NotificationService>().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ProfileBloc _profileBloc;
  late final router;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>()..add(const ProfileLoadRequested());
    router = AppRouter.createRouter(_profileBloc);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: MaterialApp.router(
        title: 'Smart Scale',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4FF45),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
