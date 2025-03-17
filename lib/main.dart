import 'package:fitness_tracking_app/helpers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracking_app/pages/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mazinga App',
      themeMode: Provider.of<ThemeProvider>(context).currentTheme,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}