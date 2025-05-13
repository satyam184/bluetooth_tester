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

class Scanner extends StatelessWidget {
  const Scanner({super.key});

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
                context.showDefaultSnackbar(
                  'Connected Successfully',
                  AppColors.sucess,
                );

              case ScanStatus.disConnected:
                context.showDefaultSnackbar('disConnected', AppColors.error);
              case ScanStatus.error:
                context.showDefaultSnackbar('Failed to scan', AppColors.error);
              default:
            }
          },
          builder: (context, state) {
            final devices = state.devices;
            switch (state.scanStatus) {
              case ScanStatus.loading:
                return Center(
                  child: CircularProgressIndicator(color: AppColors.loading),
                );
              case ScanStatus.success:
                if (devices.isEmpty) {
                  return Center(child: Text('No device found!'));
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
                return SizedBox.shrink();
            }
          },
        ),
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
          Text('Not Bonded'),
        ],
      ),

      trailing: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
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
