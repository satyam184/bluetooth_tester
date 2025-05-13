import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkBluetoothPermissions() async {
  var status =
      await [
        Permission.locationWhenInUse,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

  if (status.values.any((e) => e != PermissionStatus.granted)) {
    print('Permissions not granted');
    return false;
  }

  final isOn =
      await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  if (!isOn) {
    print('Bluetooth is OFF — please turn it on');
    return false;
  }

  return true;
}
