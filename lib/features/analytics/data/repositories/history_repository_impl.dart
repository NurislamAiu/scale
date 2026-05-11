import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/analytics/domain/repositories/history_repository.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final SharedPreferences _prefs;
  static const String _historyKey = 'scale_measurements_history';

  HistoryRepositoryImpl(this._prefs);

  @override
  Future<Either<Failure, Unit>> addMeasurement(ScaleMeasurement measurement) async {
    try {
      final currentList = await _getRawList();
      
      // Избегаем точных дубликатов (с одинаковым timestamp)
      if (!currentList.any((e) => e.timestamp == measurement.timestamp)) {
        currentList.add(measurement);
        // Сортируем от новых к старым
        currentList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final jsonList = currentList.map((e) => e.toJson()).toList();
        await _prefs.setString(_historyKey, jsonEncode(jsonList));
      }
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ScaleMeasurement>>> getMeasurements() async {
    try {
      return Right(await _getRawList());
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Future<List<ScaleMeasurement>> _getRawList() async {
    final jsonStr = _prefs.getString(_historyKey);
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((e) => ScaleMeasurement.fromJson(e)).toList();
  }

  @override
  Future<Either<Failure, Unit>> clearHistory() async {
    await _prefs.remove(_historyKey);
    return const Right(unit);
  }
}
