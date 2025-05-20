part of 'scanner_bloc.dart';

class ScannerState extends Equatable {
  const ScannerState({
    this.devices = const [],
    this.scanStatus = ScanStatus.initial,
    this.connectedDevice,
  });

  final List<ScanResult> devices;
  final ScanStatus scanStatus;
  final BluetoothDevice? connectedDevice;

  ScannerState copyWith({
    List<ScanResult>? devices,
    ScanStatus? scanStatus,
    BluetoothDevice? connectedDevice,
  }) {
    return ScannerState(
      devices: devices ?? this.devices,
      scanStatus: scanStatus ?? this.scanStatus,
      connectedDevice: connectedDevice ?? this.connectedDevice,
    );
  }

  @override
  List<Object?> get props => [devices, scanStatus, connectedDevice];
}
