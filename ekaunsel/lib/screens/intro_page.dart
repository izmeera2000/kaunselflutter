import 'package:ekaunsel/components/register_form.dart';
import 'package:ekaunsel/screens/login_page.dart';
import 'package:ekaunsel/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/text.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/components/login_form.dart';
import 'package:ekaunsel/components/intro_content.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/components/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  static String routeName = "/intro";

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to e-Kaunselling Your Path to Mental Wellness",
      "image": "assets/splash-1.png"
    },
    {
      "text":
          "Taking care of your mental health has never been easier. We connect you with experienced counselors for private, secure sessions, available at your convenience. Whether you're dealing with stress, anxiety, relationship issues, or just need someone to talk to, we're here to help",
      "image": "assets/splash-2.png"
    },
  ];


  @override
  void initState() {
    super.initState();
 loadSavedCredentials();

 
 


  }

Future<void> loadSavedCredentials() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString('saved_email');
  final isRemembered = prefs.getBool('remember_me') ?? false;

  String? userRole = prefs.getString('role');

  if (isRemembered && savedEmail != null) {
       if (userRole == '1') {
        Navigator.of(context).pushReplacementNamed('main2');
      } else {
        Navigator.of(context).pushReplacementNamed('main');
      }
   }
}




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
