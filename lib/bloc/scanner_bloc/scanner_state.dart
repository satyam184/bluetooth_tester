part of 'scanner_bloc.dart';

class ScannerState extends Equatable {
  const ScannerState({
    this.devices = const [],
    this.scanStatus = ScanStatus.initial,
    this.connectedDevice,

    this.rssi,
  });

  final List<ScanResult> devices;
  final ScanStatus scanStatus;
  final BluetoothDevice? connectedDevice;

  final int? rssi;

  ScannerState copyWith({
    List<ScanResult>? devices,
    ScanStatus? scanStatus,
    BluetoothDevice? connectedDevice,

    int? rssi,
  }) {
    return ScannerState(
      devices: devices ?? this.devices,
      scanStatus: scanStatus ?? this.scanStatus,
      connectedDevice: connectedDevice ?? this.connectedDevice,

      rssi: rssi ?? this.rssi,
    );
  }

  @override
  List<Object?> get props => [devices, scanStatus, connectedDevice, rssi];
}
