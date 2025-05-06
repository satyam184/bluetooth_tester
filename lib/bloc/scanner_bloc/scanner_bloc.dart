import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nrf/utils/enums.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  StreamSubscription? _scanSubscription;
  final List<ScanResult> devicesList = [];

  ScannerBloc() : super(ScannerState()) {
    on<StartScan>(_onStartScan);
  }

  Future<void> _onStartScan(StartScan event, Emitter<ScannerState> emit) async {
    try {
      emit(state.copyWith(scanStatus: ScanStatus.loading));
      devicesList.clear();

      FlutterBluePlus.startScan(timeout: Duration(seconds: 2));

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
      if (!emit.isDone) {
        emit(
          state.copyWith(
            devices: List<ScanResult>.from(devicesList),
            scanStatus: ScanStatus.success,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(scanStatus: ScanStatus.error));
    }
  }
}
