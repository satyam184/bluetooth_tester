part of 'scanner_bloc.dart';

class ScannerState extends Equatable {
  const ScannerState({
    this.devices = const [],
    this.scanStatus = ScanStatus.inital,
  });

  final List<ScanResult> devices;
  final ScanStatus scanStatus;

  ScannerState copyWith({List<ScanResult>? devices, ScanStatus? scanStatus}) {
    return ScannerState(
      devices: devices ?? this.devices,
      scanStatus: scanStatus ?? this.scanStatus,
    );
  }

  @override
  List<Object> get props => [devices, scanStatus];
}
