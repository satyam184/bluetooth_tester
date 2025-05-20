import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nrf/bloc/scanner_bloc/scanner_bloc.dart';
import 'package:nrf/utils/colors.dart';
import 'package:nrf/utils/enums.dart';
import 'package:nrf/utils/extension/context_extension.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Device info',
          style: context.headlineSmall!.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            context.read<ScannerBloc>().add(DisConnectToDevice());
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listenWhen: (previous, current) {
          return previous.scanStatus != current.scanStatus;
        },
        listener: (context, state) {
          switch (state.scanStatus) {
            case ScanStatus.error:
              context.showDefaultSnackbar('error occured', AppColors.error);
              break;
            case ScanStatus.disconnected:
              Navigator.pop(context, true);
              break;

            case ScanStatus.connected:
              Future.delayed(Duration(seconds: 2), () {
                if (context.mounted) {
                  context.showDefaultSnackbar(
                    'Connected Successfully',
                    AppColors.sucess,
                  );
                }
              });

              break;

            default:
              break;
          }
        },
        builder: (context, state) {
          switch (state.scanStatus) {
            case ScanStatus.loading:
              return Center(
                child: CircularProgressIndicator(color: AppColors.loading),
              );

            case ScanStatus.connected:
              return Column(
                children: [
                  Text(
                    state.connectedDevice!.advName.toString(),
                    style: context.labelLarge,
                  ),
                  Text(
                    state.connectedDevice!.remoteId.toString(),
                    style: context.labelLarge,
                  ),
                ],
              );

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
