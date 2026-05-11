sealed class Failure {
  final String message;
  const Failure(this.message);
}

class BluetoothOffFailure extends Failure {
  const BluetoothOffFailure() : super('Bluetooth is turned off');
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure() : super('Bluetooth permissions are denied');
}

class BleNotSupportedFailure extends Failure {
  const BleNotSupportedFailure() : super('BLE is not supported on this device');
}

class BleScanFailure extends Failure {
  const BleScanFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ProfileNotFoundFailure extends Failure {
  const ProfileNotFoundFailure() : super('Profile not set, complete onboarding first');
}

