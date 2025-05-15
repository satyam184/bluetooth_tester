import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nrf/bloc/scanner_bloc/scanner_bloc.dart';
import 'package:nrf/utils/colors.dart';
import 'package:nrf/utils/enums.dart';
import 'package:nrf/utils/extension/context_extension.dart';
import 'package:nrf/views/scanner/scanner.dart';

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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<ScannerBloc>().add(DisConnectToDevice());
          },
        ),
      ),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listenWhen: (previous, current) {
          return previous.scanStatus != current.scanStatus;
        },
        listener: (context, state) {
          switch (state.scanStatus) {
            case ScanStatus.error:
              return context.showDefaultSnackbar(
                'error occured',
                AppColors.error,
              );
            case ScanStatus.disConnected:
              Navigator.pop(context);

            default:
              const SizedBox.shrink();
          }
        },
        builder: (context, state) {
          switch (state.scanStatus) {
            case ScanStatus.loading:
              return Center(
                child: CircularProgressIndicator(color: AppColors.loading),
              );

            default:
              SizedBox.shrink();
          }

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
        },
      ),
    );
  }
}
