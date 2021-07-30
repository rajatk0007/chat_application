import 'package:flutter/material.dart';
import 'package:chat_app/screens/welcome_page.dart';
import 'package:chat_app/screens/login.dart';
import 'package:chat_app/screens/registration.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  await Firebase.initializeApp();
  runApp(ChatBook(email));
}

class ChatBook extends StatelessWidget {

  ChatBook(this.email);
  String? email;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      initialRoute: email==null?'/':'/chat',
      routes: {
        '/': (context)=> WelcomeScreen(),
        '/login': (context)=> LoginScreen(),
        '/registration': (context)=> RegistrationScreen(),
        '/chat': (context)=> ChatScreen()
      },
    );
  }
}