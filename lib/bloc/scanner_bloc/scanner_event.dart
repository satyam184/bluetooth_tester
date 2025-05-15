part of 'scanner_bloc.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

class StartScan extends ScannerEvent {}

class ConnectToDevice extends ScannerEvent {
  final BluetoothDevice device;
  const ConnectToDevice(this.device);
}

class DisConnectToDevice extends ScannerEvent {}

class BluetoothStateChanged extends ScannerEvent {
  final BluetoothDevice state;
  const BluetoothStateChanged(this.state);
}
