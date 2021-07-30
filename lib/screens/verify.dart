import 'dart:async';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {

  final _auth = FirebaseAuth.instance;
  late User user;
  late Timer timer;
  @override
  void initState() {
    user = _auth.currentUser!;
    user.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkVerification();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade300,
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 30,
                color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10,horizontal: 40),
                child: ListTile(

                  title: Text(
                    'A verification email has been sent please verify your email to continue..',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'SourceSansPro',
                        fontSize: 30,
                        color: Colors.teal.shade900,

                    ),
                  ),
                )
            ),
              SizedBox(height: 40,),
              Card(
                elevation: 40,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10,horizontal: 40),
                  child: ListTile(
                    leading: Icon(
                      Icons.mail,
                      color: Colors.teal.shade900,
                    ),
                    title: Text(
                      '${user.email}',
                      style: TextStyle(
                          fontFamily: 'SourceSansPro',
                          fontSize: 15,
                          color: Colors.teal.shade900
                      ),
                    ),
                  )
              ),
          ]
          )
        ),

    );
  }


  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }

  Future<void> checkVerification() async{
    user = _auth.currentUser!;
    await user.reload();
    if(user.emailVerified){
      timer.cancel();
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatScreen()));
    }
  }
}
