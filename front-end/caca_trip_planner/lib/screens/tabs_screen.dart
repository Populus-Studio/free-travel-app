import 'package:flutter/material.dart';

import 'test_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'select_screen.dart';
import 'plan_screen.dart';
import 'my_screen.dart';
import '../utils.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);
  static const routeName = '/tab_screen';

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late final List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _pages = [
      {
        'name': '主页',
        'page': const MainScreen(),
      },
      {
        'name': '规划',
        'page': const PlanScreen(),
      },
      {
        'name': '我的',
        'page': const MyScreen(),
      },
      {
        'name': '测试页',
        'page': const TestScreen(),
      },
    ];
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => Utils.isAuth
        ? null
        : Navigator.of(context)
            .pushReplacementNamed(LoginViaUsernameScreen.routeName));
    super.initState();
  }

  void selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: selectPage,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedPageIndex,
        items: List.generate(_pages.length, (index) {
          late final Icon icon;
          switch (_pages[index]['name']) {
            case '主页':
              icon = const Icon(Icons.house);
              break;
            case '我的':
              icon = const Icon(Icons.person);
              break;
            case '规划':
              icon = const Icon(Icons.directions);
              break;
            default:
              icon = const Icon(Icons.abc);
          }
          return BottomNavigationBarItem(
              icon: icon, label: _pages[index]['name'] as String);
        }),
      ),
    );
  }
}
