// ignore_for_file: depend_on_referenced_packages

import 'package:doctor_appointment_app/screens/chatbot_page.dart';
import 'package:doctor_appointment_app/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/screens/appointment_page.dart';
import 'package:doctor_appointment_app/screens/profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _page = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),

        controller: _page,
        onPageChanged: ((value) {
          setState(() {
            //Actualiza pagina del index cuando el tab es presionado
            currentPage = value;
          });
        }),
        children: <Widget>[HomePage(), ChatbotPage(), AppointmentPage(),ProfilePage()],
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),

        controller: _page,
        onPageChanged: ((value) {
          setState(() {
            //Actualiza pagina del index cuando el tab es presionado
            currentPage = value;
          });
        }),
        children: <Widget>[HomePage(), ChatbotPage(), AppointmentPage(),ProfilePage()],
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
            label: 'Home2',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.message),
            label: 'Chat2',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidCalendarCheck),
            label: 'Schedule2',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile2',
          ),
        ],
      ),
    );
  }
}
