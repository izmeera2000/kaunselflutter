import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/components/intro_content.dart';
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
  DateTime? _lastPressedAt;

  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to e-Kaunselling Your Path to Mental Wellness",
      "image": "assets/splash-1.png"
    },
    {
      "text":
          "Taking care of your mental health has never been easier. We connect you with experienced counselors for private, secure sessions, available at your convenience. ",
      "image": "assets/splash-2.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
        WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLoginStatus(context);
    });
  }



  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("check");
    String? userId = prefs.getString('user_id');
    String? userRole = prefs.getString('role');
    print(userId);
    print(userRole);

    if (userId != null && userRole != null) {
      // User is logged in, navigate to the appropriate page based on their role
      if (userRole == '1') {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('main2');
          }
        });
        print("admin");
      } else {
        print("user");
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('main');
          }
        });
      }
    }  
  }


  Future<void> loadSavedCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final isRemembered = prefs.getBool('remember_me') ?? false;

    String? userRole = prefs.getString('role');

    if (!mounted) return;

    if (isRemembered && savedEmail != null) {
      if (userRole == '1') {
        Navigator.of(context).pushReplacementNamed('main2');
      } else {
        Navigator.of(context).pushReplacementNamed('main');
      }
    }
  }

  Future<bool> _onWillPop(test, result) async {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: _onWillPop,
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 7,
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
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Button(
                    width: double.infinity,
                    title: 'Continue',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    disable: false,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
