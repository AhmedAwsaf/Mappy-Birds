import 'package:flutter/material.dart';
import 'package:mappybirds/screen/components/home.dart';
// Suggested code may be subject to a license. Learn more: ~LicenseLog:870352930.
import 'package:mappybirds/screen/components/tv_show.dart';

class MainHomeScreen extends StatefulWidget {
  MainHomeScreen({Key? key, required this.currentIndex}) : super(key: key);
  int currentIndex = 0;
  static const navigation = <NavigationDestination>[
    NavigationDestination(
      selectedIcon: Icon(
        Icons.map,
        color: Colors.green,
      ),
      icon: Icon(
        Icons.map_outlined,
        color: Colors.white,
      ),
      label: 'Mappy',
    ),
    NavigationDestination(
      selectedIcon: Icon(
        Icons.edit,
        color: Colors.green,
      ),
      icon: Icon(
        Icons.edit_location,
        color: Colors.white,
      ),
      label: 'Birdie',
    ),
  ];

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int drawerIndex = 0;

  final page = [
    HomeScreen(),
    TvShowScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BIG handy " +
            MainHomeScreen.navigation[widget.currentIndex].label),
      ),
      body: page[widget.currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          indicatorColor: Colors.white,
          labelTextStyle: MaterialStatePropertyAll(
              TextStyle(color: Colors.white, fontSize: 11)),
        ),
        child: NavigationBar(
          animationDuration: const Duration(seconds: 1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: widget.currentIndex,
          height: 60,
          elevation: 0,
          backgroundColor: Colors.blueGrey,
          onDestinationSelected: (int index) {
            setState(() {
              widget.currentIndex = index;
            });

            //co.updateIndex(index);
          },
          destinations: MainHomeScreen.navigation,
        ),
      ),
    );
  }
}
