import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nrf/service/bluetooth_helper.dart';
import 'package:nrf/utils/enums.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  StreamSubscription? _scanSubscription;
  late StreamSubscription<BluetoothConnectionState> _deviceStateSubscription;
  final List<ScanResult> devicesList = [];

  ScannerBloc() : super(ScannerState()) {
    on<StartScan>(_onStartScan);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisConnectToDevice>(_onDisConnectToDevice);
    on<BluetoothStateChanged>(_bluetoothStateChanged);
  }

  void _bluetoothStateChanged(
    BluetoothStateChanged event,
    Emitter<ScannerState> emit,
  ) {
    emit(
      state.copyWith(
        connectedDevice: null,
        scanStatus: ScanStatus.disconnected,
      ),
    );
    print('device disconnected');
  }

  Future<void> _onStartScan(StartScan event, Emitter<ScannerState> emit) async {
    final hasPermission = await checkBluetoothPermissions();
    if (!hasPermission) {
      emit(state.copyWith(scanStatus: ScanStatus.bluetoothPermissions));
      return;
    }

    try {
      emit(state.copyWith(scanStatus: ScanStatus.loading));
      devicesList.clear();

      FlutterBluePlus.startScan(timeout: Duration(seconds: 3));

      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
        bool newDeviceFound = false;

        for (final r in results) {
          final alreadyExists = devicesList.any(
            (d) => d.device.remoteId == r.device.remoteId,
          );
          if (!alreadyExists) {
            devicesList.add(r);
            newDeviceFound = true;
          }
        }

        if (newDeviceFound && !emit.isDone) {
          emit(
            state.copyWith(
              devices: List<ScanResult>.from(devicesList),
              scanStatus: ScanStatus.success,
            ),
          );
        }
      });

      await Future.delayed(Duration(seconds: 5));
      FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      _scanSubscription = null;
      if (!emit.isDone) {
        emit(
          state.copyWith(
            devices: List<ScanResult>.from(devicesList),
            scanStatus: ScanStatus.success,
          ),
        );
      }
      print('devices: $devicesList');
    } catch (e) {
      emit(state.copyWith(scanStatus: ScanStatus.error));
    }
  }

  Future<void> _onConnectToDevice(
    ConnectToDevice event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await FlutterBluePlus.stopScan();
      emit(state.copyWith(scanStatus: ScanStatus.loading));
      if (state.connectedDevice != null && state.connectedDevice!.isConnected) {
        try {
          await state.connectedDevice!.disconnect();
          print('Disconnected from previous device');
        } catch (e) {
          // emit(state.copyWith(scanStatus: ScanStatus.error));
          print('Error disconnecting previous device: $e');
        }
      }
      if (!event.device.isConnected) {
        await event.device.connect(timeout: Duration(seconds: 10));
      }
      bool isConnected = event.device.isConnected;
      if (isConnected) {
        emit(
          state.copyWith(
            connectedDevice: event.device,
            scanStatus: ScanStatus.connected,
          ),
        );
        _deviceStateSubscription = event.device.connectionState.listen((
          connectionState,
        ) {
          if (connectionState != BluetoothConnectionState.connected) {
            add(BluetoothStateChanged(event.device));
          }
        });
        print('Connected device: ${state.connectedDevice!.advName}');
      }
    } catch (e) {
      emit(state.copyWith(scanStatus: ScanStatus.failed));
      print('Connection error: $e');
    }
  }

  Future<void> _onDisConnectToDevice(
    DisConnectToDevice event,
    Emitter<ScannerState> emit,
  ) async {
    emit(state.copyWith(scanStatus: ScanStatus.loading));
    Future.delayed(Duration(seconds: 2));
    if (state.connectedDevice == null) return;
    if (state.connectedDevice!.isConnected) {
      await state.connectedDevice!.disconnect();
      if (state.connectedDevice!.isDisconnected) {
        emit(
          state.copyWith(
            connectedDevice: null,
            scanStatus: ScanStatus.disconnected,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    // TODO: implement close
    await _scanSubscription?.cancel();
    return super.close();
  }
}
