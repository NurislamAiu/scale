import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_scale/core/error/failures.dart';
import 'package:smart_scale/features/profile/domain/entities/user_profile.dart';
import 'package:smart_scale/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_scale/features/analytics/domain/repositories/history_repository.dart';
import 'package:smart_scale/features/scale/domain/entities/body_composition.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';
import 'package:smart_scale/features/scale/domain/repositories/scale_repository.dart';
import 'package:smart_scale/features/scale/domain/usecases/body_composition_calculator.dart';
import 'package:smart_scale/features/scale/domain/usecases/measurement_stabilizer.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

part 'scale_event.dart';
part 'scale_state.dart';

class ScaleBloc extends Bloc<ScaleEvent, ScaleState> {
  final ScaleRepository _scaleRepository;
  final ProfileRepository _profileRepository;
  final HistoryRepository _historyRepository;
  final SharedPreferences _prefs;

  StreamSubscription? _measurementSubscription;
  StreamSubscription? _scanResultSubscription;
  UserProfile? _cachedProfile;

  static const String _lastMeasurementKey = 'last_scale_measurement';

  ScaleBloc(this._scaleRepository, this._profileRepository, this._historyRepository, this._prefs) : super(const ScaleState()) {
    on<ScaleStarted>(_onScaleStarted);
    on<ScaleMeasurementReceived>(_onMeasurementReceived);
    on<ScaleErrored>(_onScaleErrored);
    on<ScaleScanStarted>(_onScanStarted);
    on<ScaleScanStopped>(_onScanStopped);
    on<_ScaleScanResultsUpdated>(_onScanResultsUpdated);
    on<ScaleDeviceSelected>(_onDeviceSelected);
    on<ScaleMeasurementSaved>(_onMeasurementSaved);

    _loadInitialMeasurementIfAvailable();
  }

  void _loadInitialMeasurementIfAvailable() {
    final jsonString = _prefs.getString(_lastMeasurementKey);
    if (jsonString != null) {
      try {
        final measurement = ScaleMeasurement.fromJson(jsonDecode(jsonString));
        add(ScaleMeasurementReceived(measurement));
      } catch (e) {
        _prefs.remove(_lastMeasurementKey);
      }
    }
  }

  Future<void> _onScaleStarted(ScaleStarted event, Emitter<ScaleState> emit) async {
    emit(state.copyWith(status: ScaleStatus.requestingPermissions));

    final profileResult = await _profileRepository.getProfile();
    profileResult.fold((_) {}, (profile) => _cachedProfile = profile);

    if (_cachedProfile != null && state.lastMeasurement != null && state.bodyComposition == null) {
      final composition = BodyCompositionCalculator.calculate(
        weightKg: state.lastMeasurement!.weightKg,
        profile: _cachedProfile!,
      );
      emit(state.copyWith(bodyComposition: composition));
    }

    final permResult = await _scaleRepository.ensurePermissions();
    await permResult.fold(
      (failure) async {
        emit(state.copyWith(
            status: failure is PermissionDeniedFailure ? ScaleStatus.permissionDenied : ScaleStatus.error,
            errorMessage: failure.message));
      },
      (_) async {
        emit(state.copyWith(status: ScaleStatus.ready));
        // Force restart the stream to wake up BLE after app resume
        await _measurementSubscription?.cancel();
        _measurementSubscription = null;
        _listenToWeightStream();
      },
    );
  }
  
  void _listenToWeightStream() {
    if (_measurementSubscription != null) return; // Already listening

    _measurementSubscription = _scaleRepository
        .watchMeasurements()
        .where((either) => either.isRight())
        .map((either) => either.getOrElse(() => throw Exception('Impossible')))
        .stabilized(windowSize: 6, toleranceKg: 0.15)
        .listen(
          (measurement) => add(ScaleMeasurementReceived(measurement)),
          onError: (e) => add(ScaleErrored(e.toString())),
        );
  }

  void _onMeasurementReceived(ScaleMeasurementReceived event, Emitter<ScaleState> emit) {
    final measurement = event.measurement;
    BodyComposition? composition;
    if (_cachedProfile != null) {
      composition = BodyCompositionCalculator.calculate(
        weightKg: measurement.weightKg,
        profile: _cachedProfile!,
      );
    }
    emit(state.copyWith(
      status: measurement.isStabilized ? ScaleStatus.stabilized : ScaleStatus.weighing,
      lastMeasurement: measurement,
      bodyComposition: composition,
    ));
    if (measurement.isStabilized) {
      final jsonString = jsonEncode(measurement.toJson());
      _prefs.setString(_lastMeasurementKey, jsonString);
    }
  }

  void _onScaleErrored(ScaleErrored event, Emitter<ScaleState> emit) {
    emit(state.copyWith(status: ScaleStatus.error, errorMessage: event.message));
  }

  Future<void> _onScanStarted(ScaleScanStarted event, Emitter<ScaleState> emit) async {
    // Stop listening to weight stream before starting a new scan
    await _measurementSubscription?.cancel();
    _measurementSubscription = null;

    emit(state.copyWith(status: ScaleStatus.scanning, scanResults: [], clearErrorMessage: true));

    final permResult = await _scaleRepository.ensurePermissions();
    await permResult.fold(
      (failure) async => add(ScaleErrored(failure.message)),
      (_) async {
        await _scanResultSubscription?.cancel();
        _scanResultSubscription = _scaleRepository.scanResults.listen(
          (results) => add(_ScaleScanResultsUpdated(results)),
        );
        await _scaleRepository.startScan();
      },
    );
  }

  Future<void> _onScanStopped(ScaleScanStopped event, Emitter<ScaleState> emit) async {
    await _scaleRepository.stopScan();
    await _scanResultSubscription?.cancel();
    _scanResultSubscription = null;
    
    emit(state.copyWith(status: ScaleStatus.ready));
    _listenToWeightStream(); // Resume listening to weight
  }

  void _onScanResultsUpdated(_ScaleScanResultsUpdated event, Emitter<ScaleState> emit) {
    final namedDevices = event.results.where((r) => r.device.platformName.isNotEmpty).toList();
    emit(state.copyWith(scanResults: namedDevices));
  }

  Future<void> _onDeviceSelected(ScaleDeviceSelected event, Emitter<ScaleState> emit) async {
    await _scaleRepository.stopScan();
    await _scanResultSubscription?.cancel();
    _scanResultSubscription = null;

    await _scaleRepository.connectToDevice(event.device);
    emit(state.copyWith(status: ScaleStatus.ready));
    
    _listenToWeightStream(); // Resume listening to weight
  }

  Future<void> _onMeasurementSaved(ScaleMeasurementSaved event, Emitter<ScaleState> emit) async {
    // Не меняем UI состояние, просто сохраняем в фоне
    await _historyRepository.addMeasurement(event.measurement);
  }

  @override
  Future<void> close() {
    _measurementSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _scaleRepository.stopScan();
    return super.close();
  }
}
