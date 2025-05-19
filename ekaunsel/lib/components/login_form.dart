import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To decode the JSON response
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/components/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;

  // Function to handle login logic
  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passController.text;

    if (email.isEmpty || password.isEmpty) {
      // Show error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    try {
      // Show loading indicator while the request is being sent
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Send the POST request to the server
      final response = await http.post(
        Uri.parse(
            '${Config.base_url}login'), // Replace with your PHP script URL
        body: {
          'user_login_flutter': '1', // This is the key used in your PHP script
          'login': email,
          'password': password,
        },
      );

      // Navigator.of(context).pop(); // Close the loading indicator
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['status'] == 'success') {
          // Navigate to the main page/dashboard on successful login
          final user = responseBody['user'];
          _saveUserDetails(user);

          String role = user['role'];

          if (role == '1') {
            Navigator.pushNamedAndRemoveUntil(
                context, 'main2', (route) => false);
          }  else {
            Navigator.pushNamedAndRemoveUntil(
                context, 'main', (route) => false);
          }
        } else {
          // Show an error message if login failed, showing the response message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Unknown error')),
          );
          debugPrint(responseBody['message']);
          Navigator.of(context).pop(); // Close the loading indicator
        }
      } else {
        // If the request failed, show the full response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to connect to the server. Response: ${response.body}')),
        );
        debugPrint(responseBody['message']);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Please check your internet connection')),
      );
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIconColor: Config.primaryColor,
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black38,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          Button(
            width: double.infinity,
            title: 'Sign In',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _login(); // Call the login function if form is valid
              }
            },
            disable: false,
          ),
        ],
      ),
    );
  }
}

Future<void> _saveUserDetails(Map<String, dynamic> userDetails) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save user info in SharedPreferences for future use
  prefs.setString('user_id', userDetails['id'].toString());
  prefs.setString('email', userDetails['email']);
  prefs.setString('ndp', userDetails['ndp']);
  prefs.setString('kp', userDetails['kp']);
  prefs.setString('role', userDetails['role']);
  prefs.setString(
      'image_url', userDetails['image_url'] ?? ''); // Store profile image URL
  prefs.setString('status_kahwin',
      userDetails['status_kahwin'] ?? ''); // Store marital status
  prefs.setString('agama', userDetails['agama'] ?? ''); // Store religion
  prefs.setString('jantina', userDetails['jantina'] ?? ''); // Store gender
  prefs.setString('phone', userDetails['phone'] ?? ''); // Store phone number
  prefs.setString('nama', userDetails['nama'] ?? ''); // Store full name
  prefs.setString(
      'sem', userDetails['sem'] ?? ''); // Store semester or other info
  prefs.setString('bangsa', userDetails['bangsa'] ?? ''); // Store ethnicity

  // Optionally, you can add other fields if necessary
}
