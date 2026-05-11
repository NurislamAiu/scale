import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scale/features/analytics/data/repositories/history_repository_impl.dart';
import 'package:smart_scale/features/analytics/domain/repositories/history_repository.dart';
import 'package:smart_scale/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:smart_scale/features/profile/data/profile_repository_impl.dart';
import 'package:smart_scale/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_scale/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:smart_scale/features/reminders/data/repositories/reminders_repository_impl.dart';
import 'package:smart_scale/features/reminders/domain/repositories/reminders_repository.dart';
import 'package:smart_scale/features/reminders/presentation/bloc/reminders_bloc.dart';
import 'package:smart_scale/features/scale/data/datasources/scale_ble_datasource.dart';
import 'package:smart_scale/features/scale/data/repositories/scale_repository_impl.dart';
import 'package:smart_scale/features/scale/domain/repositories/scale_repository.dart';
import 'package:smart_scale/features/scale/presentation/bloc/scale_bloc.dart';
import 'package:smart_scale/core/notifications/notification_service.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Core Services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Data Sources
  getIt.registerLazySingleton<ScaleBleDataSource>(() => ScaleBleDataSource());

  // Repositories
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<ScaleRepository>(
    () => ScaleRepositoryImpl(getIt()),
  );
   getIt.registerLazySingleton<RemindersRepository>(
    () => RemindersRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(getIt()),
  );

  // BLoCs
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getIt()),
  );
  getIt.registerLazySingleton<ScaleBloc>(
    () => ScaleBloc(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<RemindersBloc>(
    () => RemindersBloc(getIt(), getIt()),
  );
  getIt.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(getIt()),
  );
}
