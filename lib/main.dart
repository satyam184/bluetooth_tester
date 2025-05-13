import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:nrf/bloc/scanner_bloc/scanner_bloc.dart';
import 'package:nrf/utils/colors.dart';
import 'package:nrf/utils/size.dart';
import 'package:nrf/views/dashborad_screen/dashboard.dart';

void main() {
  // FlutterBluePlus.setLogLevel(LogLevel.verbose);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => ScannerBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          iconTheme: IconThemeData(color: Colors.white),
          fontFamily: 'Poppins',
          listTileTheme: ListTileThemeData(iconColor: Colors.white),
        ),
        home: DashBoard(),
      ),
    );
  }
}
