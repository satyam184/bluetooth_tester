import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nrf/bloc/scanner_bloc/scanner_bloc.dart';
import 'package:nrf/utils/colors.dart';
import 'package:nrf/utils/enums.dart';
import 'package:nrf/utils/extension/context_extension.dart';
import 'package:nrf/utils/image.dart';
import 'package:nrf/utils/size.dart';
import 'package:nrf/views/detail_screen/detail_screen.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: AppColors.primary,
        onRefresh: () async {
          context.read<ScannerBloc>().add(StartScan());
        },
        child: BlocConsumer<ScannerBloc, ScannerState>(
          listenWhen: (previous, current) {
            return previous.scanStatus != current.scanStatus;
          },
          listener: (context, state) {
            switch (state.scanStatus) {
              case ScanStatus.success:
                state.devices.isEmpty
                    ? context.showDefaultSnackbar(
                      'No device found',
                      AppColors.error,
                    )
                    : context.showDefaultSnackbar(
                      'Scanned Successfully',
                      AppColors.sucess,
                    );
              case ScanStatus.connected:
                Future.microtask(() {
                  if (context.mounted) {
                    Navigator.push(
                      (context),
                      MaterialPageRoute(builder: (context) => DetailScreen()),
                    ).then((result) {
                      if (result == true) {
                        if (context.mounted) {
                          context.read<ScannerBloc>().add(StartScan());
                        }
                      }
                    });
                  }
                });

              case ScanStatus.disconnected:
                context.showDefaultSnackbar('disconnected', AppColors.error);
                break;

              case ScanStatus.error:
                context.showDefaultSnackbar('Failed to scan', AppColors.error);
                break;

              case ScanStatus.failed:
                context.showDefaultSnackbar(
                  'Failed to connect',
                  AppColors.error,
                );
                break;

              case ScanStatus.bluetoothPermissions:
                context.showDefaultSnackbar(
                  'Permission required',
                  AppColors.error,
                );
                break;
              default:
                break;
            }
          },
          builder: (context, state) {
            final devices = state.devices;
            switch (state.scanStatus) {
              case ScanStatus.isConnecting:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.loading),
                      Text('Connecting'),
                    ],
                  ),
                );
              case ScanStatus.isScanning:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.loading),
                      Text('Scanning'),
                    ],
                  ),
                );

              case ScanStatus.success:
                if (devices.isEmpty) {
                  return ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: ScreenUtil.height(5),
                        child: Center(child: Text('No device found!')),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return CustomBluetoothListTIle(device: device);
                  },
                );
              default:
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return CustomBluetoothListTIle(device: device);
                  },
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ScannerBloc>().add(StartScan());
        },
        enableFeedback: true,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.refresh, color: AppColors.textSecondary),
      ),
    );
  }
}

class CustomBluetoothListTIle extends StatelessWidget {
  const CustomBluetoothListTIle({super.key, this.device});

  final ScanResult? device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: SizedBox(
        height: ScreenUtil.height(4),
        width: ScreenUtil.width(7),
        child: SvgPicture.asset(
          bluetooth,
          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        device!.advertisementData.advName.isNotEmpty
            ? device!.advertisementData.advName
            : 'N/A',
        style:
            device!.advertisementData.advName.isNotEmpty
                ? TextStyle(color: AppColors.textPrimary)
                : TextStyle(color: AppColors.textTertiary),
      ),

      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device!.device.remoteId.toString()),
          const Text('Not Bonded'),
        ],
      ),

      trailing: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        icon: InkWell(
          onTap: () async {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;

            final Offset position = button.localToGlobal(
              Offset.zero,
              ancestor: overlay,
            );

            final selected = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx + button.size.width,
                position.dy + ScreenUtil.height(2),
                position.dx + button.size.width,
                position.dy + button.size.height,
              ),
              items: [
                PopupMenuItem(value: 'connect', child: Text('Connect')),
                PopupMenuItem(value: 'disconnect', child: Text('Disconnect')),
              ],
            );
            if (selected == 'connect') {
              // handle connect
            } else if (selected == 'disconnect') {
              // handle disconnect
            }
          },
          child: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
        ),
        onPressed: () {
          context.read<ScannerBloc>().add(ConnectToDevice(device!.device));
        },
        label: Text(
          'Connect',
          style: context.titleSmall!.copyWith(color: AppColors.textSecondary),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }
}
