import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nrf/bloc/scanner_bloc/scanner_bloc.dart';
import 'package:nrf/views/advertiser/advertiser.dart';
import 'package:nrf/views/bonded/bonded.dart';
import 'package:nrf/views/scanner/scanner.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = [Scanner(), Bonded(), Advertiser()];

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<ScannerBloc>().add(StartScan());
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      if (_tabController.index == 0) {
        context.read<ScannerBloc>().add(StartScan());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue,
          title: Text('Devices', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.blue.shade100,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Scanner'),
              Tab(text: 'Bonded'),
              Tab(text: 'Advertiser'),
            ],
          ),
        ),
        drawer: Drawer(),
        body: TabBarView(controller: _tabController, children: _tabs),
      ),
    );
  }
}
