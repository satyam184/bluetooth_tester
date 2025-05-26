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
            case ScanStatus.isDisconnecting:
              return Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.loading),
                    Text('Disconnecting'),
                  ],
                ),
              );

            case ScanStatus.connected:
              return Card(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Name: ${(state.connectedDevice?.advName.isNotEmpty ?? false) ? state.connectedDevice!.advName : 'N/A'}',
                      style: context.displaySmall,
                    ),
                    Divider(),
                    Text(
                      'Remote ID: ${state.connectedDevice?.remoteId ?? 'N/A'}',
                      style: context.labelLarge,
                    ),
                    Divider(),

                    Text(
                      'Connection Status: ${state.connectedDevice?.isConnected == true ? 'Connected' : 'Error'}',
                      style: context.labelLarge,
                    ),
                    Divider(),

                    Text(
                      'RSSI: ${state.rssi ?? 'Unknown'} dbm',
                      style: context.labelLarge,
                    ),
                  ],
                ),
              );

            default:
              return Text('Retry connecting');
          }
        },
      ),
    );
  }
}
