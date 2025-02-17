import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '/helpers/database_helper.dart';  // Import the DatabaseHelper class

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  String? email, password, username;
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pageBackground(),
          Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _registerFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _wazitoTitle(),
                  _usernameTextField(),
                  SizedBox(height: 20),
                  _emailTextField(),
                  SizedBox(height: 20),
                  _passwordTextField(),
                  SizedBox(height: 20),
                  _registerButton(context),
                  _loginPage(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/bg.jpg"),
        ),
      ),
    );
  }

  Widget _wazitoTitle() {
    return Text(
      "Mazinga App",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email, color: Colors.black),
        hintText: "Email...",
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
      onSaved: (value) => email = value,
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.black),
        hintText: "Password...",
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      validator: (value) => value!.length >= 6 ? null : 'Password must be at least 6 characters',
      onSaved: (value) => password = value,
    );
  }

  Widget _registerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _registerUser(context),
      child: Text('Register'),
    );
  }

  Widget _loginPage(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Text(
        "Already have an account? Login",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _usernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Colors.black),
          hintText: "Username...",
          filled: true,
          fillColor: Colors.grey.shade200,
      ),
      validator: (value) => value!.isNotEmpty ? null : "Enter a username",
      onSaved: (value) => username = value,
    );
  }

  void _registerUser(BuildContext context) async {
    if (!_registerFormKey.currentState!.validate()) {
      return;      
    }

    _registerFormKey.currentState!.save();     

    try {
    // Get the form values
    Map<String, dynamic> userData = {
      'username': username!,
      'email': email!,
      'password': password!
    };

    print("Attempting to register user: ${userData}");

    await dbHelper.insertUser(userData);

    print("User successfully registered");    
   
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Registered")));
    Navigator.pushNamed(context, '/login');      
    } catch (e) {
    print("Registration failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }
}

