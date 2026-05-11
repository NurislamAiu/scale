import 'package:smart_scale/features/scale/domain/entities/scale_measurement.dart';

/// Protocol implementation for Yoda1 BLE scales.
/// 
/// The device broadcasts its data using advertising packets without needing a GATT connection.
/// 
/// Real packet examples:
/// [0, 0, 0, 0, 0, 0, 36, 0, 0, 0, 0, 0, 0] → scale is empty
/// [32, 168, 19, 136, 0, 0, 37, 0, 0, 0, 0, 0, 0] → weight 83.60 kg (person on scale)
/// 
/// True Structure:
/// The manufacturer map key is ignored (random device ID/counter).
/// value[0..1] - weight * 100, big-endian uint16 (0x20A8 = 8360 -> 83.60 kg)
/// value[2..3] - secondary value/flags
/// value[4..5] - impedance placeholder (usually 0)
/// value[6]    - status: 0x24 (36) = empty, 0x25 (37) = occupied
/// value[7+]   - padding
class YodaScaleProtocol {
  static const String deviceName = 'Yoda1';

  /// Extracts the payload buffer.
  /// 
  /// The key is ignored, we just extract the value bytes directly.
  static List<int> reconstructPayload(Map<int, List<int>> manufacturerData) {
    if (manufacturerData.isEmpty) return const [];
    return List.unmodifiable(manufacturerData.values.first);
  }

  /// Parses the raw byte array into a [ScaleMeasurement].
  static ScaleMeasurement? parse(List<int> data) {
    if (data.length < 7) return null;

    final rawWeight = (data[0] << 8) | data[1];
    final weightKg = rawWeight / 100.0;

    // Sanity bounds
    if (weightKg < 0 || weightKg > 180) {
      return null;
    }

    // Status byte at position 6:
    // 0x24 (36) = scale empty
    // 0x25 (37) = person on scale
    final statusByte = data[6];
    
    // We want to return data even if it's 0 to reset the UI
    if (weightKg == 0) {
        return ScaleMeasurement(
        weightKg: weightKg,
        impedanceOhms: null,
        isStabilized: false,
        timestamp: DateTime.now(),
      );
    }
    
    // Do not emit empty weights to avoid flickering
    // if (!isOccupied) return null;

    // Impedance is not available on this model via broadcast
    const impedance = null;

    // Stabilization bit is not yet precisely identified.
    // For now, let's assume if weight is > 0 it's stabilizing
    final isStabilized = weightKg > 0;

    return ScaleMeasurement(
      weightKg: weightKg,
      impedanceOhms: impedance,
      isStabilized: isStabilized,
      timestamp: DateTime.now(),
    );
  }
}
