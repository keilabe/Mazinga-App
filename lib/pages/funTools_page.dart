import 'package:fitness_tracking_app/pages/dailyActivityInput_page.dart';
import 'package:fitness_tracking_app/pages/homePage.dart';
import 'package:fitness_tracking_app/pages/progress_tracking_page.dart';
import 'package:fitness_tracking_app/pages/settings_page.dart';
import 'package:fitness_tracking_app/pages/userProfile_page.dart';
import 'package:flutter/material.dart';

class FunToolsPage extends StatefulWidget {
  @override
  _FunToolsPageState createState() => _FunToolsPageState();
}

class _FunToolsPageState extends State<FunToolsPage> {
  final TextEditingController _textController = TextEditingController();
  String _result = "";
  int _selectedIndex = 0;
  final List<Widget> Pages = [
    HomePage(),
    DailyActivityInputPage(),
    ProgressTrackingPage(),
    FunToolsPage(),
    SettingsPage(),
    UserProfilePage(),
  ];

  // Function to check if the input is a palindrome
  bool isPalindrome(String text) {
    String cleanedText = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    String reversedText = cleanedText.split('').reversed.join('');
    return cleanedText == reversedText;
  }

  // Function to handle the palindrome check
  void checkPalindrome() {
    String inputText = _textController.text.trim();
    setState(() {
      if (inputText.isEmpty) {
        _result = "Please enter a word or phrase.";
      } else {
        _result = isPalindrome(inputText) ? "It's a palindrome!" : "Not a palindrome.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fun Tools"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Palindrome Checker",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            _inputField(),
            SizedBox(height: 20),
            _checkButton(),
            SizedBox(height: 20),
            _resultDisplay(),
          ],
        ),
      ),
      // bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  // Input field for text input
  Widget _inputField() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: "Enter a word or phrase",
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }

  // Button to trigger palindrome check
  Widget _checkButton() {
    return ElevatedButton(
      onPressed: checkPalindrome,
      child: Text("Check Palindrome"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  // Display area for result
  Widget _resultDisplay() {
    return Text(
      _result,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  // Widget _bottomNavigationBar() {
  //   return BottomNavigationBar(
  //     currentIndex: _selectedIndex,
  //     onTap: (_index){
  //       setState(() {
  //         _selectedIndex = _index;

  //         //Navigates to the selected page
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => Pages[_index]),
  //         );
  //       });
  //     },
  //     items: [
  //         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  //         BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Activity"),
  //         BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
  //         BottomNavigationBarItem(icon: Icon(Icons.games), label: "Fun Tools"),
  //         BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
  //         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  //       ],
  //   );
  // }
}
