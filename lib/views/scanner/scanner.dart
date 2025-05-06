import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
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
        strokeWidth: 4.0,
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
                context.showDefaultSnackbar(
                  'Scanned Successfully',
                  AppColors.sucess,
                );
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
                  child: LottieBuilder.asset(
                    search,
                    fit: BoxFit.contain,
                    height: ScreenUtil.height(10),
                  ),
                );
              case ScanStatus.success:
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
  const CustomBluetoothListTIle({super.key, required this.device});

  final ScanResult device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        device.advertisementData.advName.isNotEmpty
            ? device.advertisementData.advName
            : 'N/A',
        style:
            device.advertisementData.advName.isNotEmpty
                ? TextStyle(color: AppColors.textPrimary)
                : TextStyle(color: AppColors.textTertiary),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(device.device.remoteId.toString()), Text('Not Bonded')],
      ),
      trailing: ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
        onPressed: () {},
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
