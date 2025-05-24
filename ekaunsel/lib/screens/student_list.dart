import 'package:ekaunsel/components/date_parse.dart';
import 'package:ekaunsel/screens/chatbot_admin_page.dart';
import 'package:ekaunsel/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  // List to hold chat data
  List<Map<String, dynamic>> StudentList = [];

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        centerTitle: true,
      ),
      body:  Center(child: Text("data"),)
    );
  }
}
