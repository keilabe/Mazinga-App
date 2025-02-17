import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';  // Import the DatabaseHelper class

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  String? email, password;
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
              key: _loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _appTitle(),
                  _emailTextField(),
                  SizedBox(height: 20),
                  _passwordTextField(),
                  SizedBox(height: 20),
                  _loginButton(context),
                  _registerPrompt(context),
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

  Widget _appTitle() {
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

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _loginUser(context),
      child: Text('Login'),
    );
  }

    Widget _registerPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/register'),
      child: Text(
        "Don't have an account? Register",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _loginUser(BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      bool isAuthenticated = await dbHelper.authenticateUser(email!, password!);
      if (!mounted) return;
      if (isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful")));
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => HomePage(
              userEmail: email,
          ),
          ),
          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid credentials")));
      }
    }
  }
}
