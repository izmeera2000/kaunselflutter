import 'package:doctor_appointment_app/components/register_form.dart';
import 'package:doctor_appointment_app/screens/login_page.dart';
import 'package:doctor_appointment_app/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment_app/utils/text.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/components/login_form.dart';
import 'package:doctor_appointment_app/components/intro_content.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/components/button.dart';

class IntroScreen extends StatefulWidget {
  static String routeName = "/intro";

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {"text": "Test1", "image": "assets/splash-1.png"},
    {"text": "test2", "image": "assets/splash-2.png"},
   ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 5),
                            height: 6,
                            width: currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? Config.primaryColor
                                  : const Color(0xFFD8D8D8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
           
                      Button(
                        width: double.infinity,
                        title: 'Continue',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        disable: false,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
