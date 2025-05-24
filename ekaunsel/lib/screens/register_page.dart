import 'package:ekaunsel/components/register_form.dart';
import 'package:ekaunsel/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:ekaunsel/utils/text.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/cupertino.dart';
 
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {




  DateTime? _lastPressedAt;


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
          child: SingleChildScrollView(
            // Wrap with SingleChildScrollView for scrolling
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    AppText.enText['welcome_text']!,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Config.spaceSmall,
                Text(
                  AppText.enText['register_text']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                const RegisterForm(),
                Config.spaceSmall,
                // const Spacer(),
                TextButton(
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
