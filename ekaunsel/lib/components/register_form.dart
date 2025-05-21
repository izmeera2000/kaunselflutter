import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Add this package in pubspec.yaml
import 'package:ekaunsel/utils/config.dart';
import 'package:ekaunsel/components/button.dart';

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

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

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

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Prepare multipart request
      final uri = Uri.parse('${Config.base_url}/register');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['user_register'] = '1';
      request.fields['ndp'] = ndp;
      request.fields['fullname'] = fullname;
      request.fields['sem'] = sem;
      request.fields['jantina'] = jantina;
      request.fields['agama'] = agama;
      request.fields['statuskahwin'] = statuskahwin;
      request.fields['bangsa'] = bangsa;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password1'] = password1;
      request.fields['password2'] = password2;

      // Add image file
      request.files
          .add(await http.MultipartFile.fromPath('image', _pickedImage!.path));

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      Navigator.of(context).pop(); // Close loading

      final jsonResp = json.decode(responseBody);
      debugPrint(responseBody);

      if (response.statusCode == 200) {
        if (jsonResp['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResp['message'])),
          );
          Navigator.of(context).pushReplacementNamed('main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(jsonResp['message'] ?? 'Registration failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Please check your internet connection')),
      );
      debugPrint('Error: $e');
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
            hintText: 'Semester',
            labelText: 'Semester',
            alignLabelWithHint: true,
            prefixIconColor: Config.primaryColor,
            prefixIcon: Icon(Icons.school),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your semester';
            }
            return null;
          },
        ),

        // Jantina as text input
        Config.spaceSmall,
        TextFormField(
          controller: _jantinaController,
          decoration: const InputDecoration(
            labelText: 'Jantina',
            prefixIcon: Icon(Icons.person),
            prefixIconColor: Config.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila isi jantina';
            }
            return null;
          },
        ),

        // Agama as text input
        Config.spaceSmall,
        TextFormField(
          controller: _agamaController,
          decoration: const InputDecoration(
            labelText: 'Agama',
            prefixIcon: Icon(Icons.account_balance),
            prefixIconColor: Config.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila isi agama';
            }
            return null;
          },
        ),

        // Status Kahwin as text input
        Config.spaceSmall,
        TextFormField(
          controller: _statuskahwinController,
          decoration: const InputDecoration(
            labelText: 'Status Perkahwinan',
            prefixIcon: Icon(Icons.family_restroom),
            prefixIconColor: Config.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila isi status kahwin';
            }
            return null;
          },
        ),

        // Bangsa as text input (add this since you check it)
        Config.spaceSmall,
        TextFormField(
          controller: _bangsaController,
          decoration: const InputDecoration(
            labelText: 'Bangsa',
            prefixIcon: Icon(Icons.group),
            prefixIconColor: Config.primaryColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Sila isi bangsa';
            }
            return null;
          },
        ),

        // Image picker UI
        Config.spaceSmall,
        if (_pickedImage == null)
          TextButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Pick Profile Image'),
            onPressed: pickImage,
          )
        else
          Column(
            children: [
              Image.file(File(_pickedImage!.path),
                  height: 120, width: 120, fit: BoxFit.cover),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
                onPressed: pickImage,
              ),
            ],
          ),

        Config.spaceSmall,

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
        Button(
          width: double.infinity,
          title: 'Register',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _register();
            }
          },
          disable: false,
        ),
      ],
    ),
  );
}

}
