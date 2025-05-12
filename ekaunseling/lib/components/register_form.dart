import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To decode the JSON response
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/components/button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _ndpController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _semController = TextEditingController();
  final _jantinaController = TextEditingController();
  final _agamaController = TextEditingController();
  final _statuskahwinController = TextEditingController();
  final _bangsaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool obsecurePass = true;
  bool obsecureConfirmPass = true;

  // Function to handle register logic
  Future<void> _register() async {
    final String ndp = _ndpController.text;
    final String fullname = _fullnameController.text;
    final String sem = _semController.text;
    final String jantina = _jantinaController.text;
    final String agama = _agamaController.text;
    final String statuskahwin = _statuskahwinController.text;
    final String bangsa = _bangsaController.text;
    final String email = _emailController.text;
    final String phone = _phoneController.text;
    final String password1 = _passController.text;
    final String password2 = _confirmPassController.text;

    if (ndp.isEmpty ||
        fullname.isEmpty ||
        sem.isEmpty ||
        jantina.isEmpty ||
        agama.isEmpty ||
        statuskahwin.isEmpty ||
        bangsa.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password1.isEmpty ||
        password2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password1 != password2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
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
            'http://192.168.0.103/ADTEC-EKaunsel/register'), // Your registration PHP script URL
        body: {
          'user_register': '1', // This is the key used in your PHP script
          'ndp': ndp,
          'fullname': fullname,
          'sem': sem,
          'jantina': jantina,
          'agama': agama,
          'statuskahwin': statuskahwin,
          'bangsa': bangsa,
          'email': email,
          'phone': phone,
          'password1': password1,
          'password2': password2,
        },
      );

      Navigator.of(context).pop(); // Close the loading indicator

      final responseBody = json.decode(response.body);
      debugPrint(responseBody);

      if (response.statusCode == 200) {
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
          // Navigate to the main page/dashboard on successful registration
          // Navigator.of(context).pushReplacementNamed('main');
        } else {
          // Show an error message if registration failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
        }
      } else {
        // If the request failed, show the full response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to connect to the server. Response: ${response.body}')),
        );
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
            controller: _ndpController,
            decoration: const InputDecoration(
              hintText: 'NDP',
              labelText: 'NDP',
                            alignLabelWithHint: true,
               prefixIconColor: Config.primaryColor,
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your NDP';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _fullnameController,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              labelText: 'Full Name',
                alignLabelWithHint: true,
              prefixIconColor: Config.primaryColor,
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
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
          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Phone Number',
              labelText: 'Phone',
                alignLabelWithHint: true,
              prefixIconColor: Config.primaryColor,
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          Config.spaceSmall,
                    TextFormField(
            controller: _semController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: 'Sem',
              labelText: 'Semester',
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
            controller: _bangsaController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: 'Bangsa',
              labelText: 'Bangsa',
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
          // Password
          TextFormField(
            controller: _passController,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
                alignLabelWithHint: true,
              prefixIconColor: Config.primaryColor,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: obsecurePass
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
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
          // Confirm Password
          TextFormField(
            controller: _confirmPassController,
            obscureText: obsecureConfirmPass,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock),
                alignLabelWithHint: true,
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                icon: obsecureConfirmPass
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obsecureConfirmPass = !obsecureConfirmPass;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              return null;
            },
          ),
          Config.spaceSmall,
          // Register button
          Button(
            width: double.infinity,
            title: 'Register',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _register(); // Call the register function if form is valid
              }
            },
            disable: false,
          ),
        ],
      ),
    );
  }
}
