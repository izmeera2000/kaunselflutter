// ignore_for_file: depend_on_referenced_packages

import 'package:ekaunsel/screens/appointment_admin_page.dart';
import 'package:ekaunsel/screens/chat_list_page.dart';
import 'package:ekaunsel/screens/chatbot_page.dart';
import 'package:ekaunsel/screens/home_page.dart';
import 'package:ekaunsel/screens/home2_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ekaunsel/screens/appointment_page.dart';
import 'package:ekaunsel/screens/profile_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _page = PageController();
 
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    subkata(

    );
  }
  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // If back button is pressed again within 2 seconds, exit the app
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return Future.value(false); // Prevent default back button action
    }
    return Future.value(true); // Allow exit after second back press
  }

  void subkata() async {
    
    await FirebaseMessaging.instance.subscribeToTopic('katasemangat');


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _page,
          onPageChanged: (value) {
            setState(() {
              currentPage = value;
            });
          },
          children: const <Widget>[
            HomePage(),
            ChatbotPage(),
            AppointmentPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (page) {
            setState(() {
              currentPage = page;
              _page.animateToPage(
                page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCirc,
              );
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.houseChimneyMedical),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.message),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidCalendarCheck),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}




class Main2Layout extends StatefulWidget {
  const Main2Layout({super.key});

  @override
  State<Main2Layout> createState() => _Main2LayoutState();
}



class _Main2LayoutState extends State<Main2Layout> {
  int currentPage = 0;
  final PageController _page = PageController();

  DateTime? _lastPressedAt;


  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // If back button is pressed again within 2 seconds, exit the app
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return Future.value(false); // Prevent default back button action
    }
    return Future.value(true); // Allow exit after second back press
  }

  void subkata() async {
    
    await FirebaseMessaging.instance.subscribeToTopic('katasemangat');


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
          onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _page,
          onPageChanged: ((value) {
            setState(() {
              //Actualiza pagina del index cuando el tab es presionado
              currentPage = value;
            });
          }),
          children: <Widget>[
            Home2Page(),
            ChatListPage(),
            AppointmentAdminPage(),
            ProfilePage()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (page) {
            setState(() {
              currentPage = page;
              _page.animateToPage(
                page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCirc,
              );
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.houseChimneyMedical),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.message),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidCalendarCheck),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
