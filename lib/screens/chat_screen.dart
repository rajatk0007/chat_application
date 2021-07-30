// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:chat_app/screens/registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _cloud = FirebaseFirestore.instance;
  final messageRemover = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late String message;
  bool itsMe = false;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('email');
                _auth.signOut();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }),
        ],
        title: Text('Chat'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        color: Colors.green.shade100,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                  stream: _cloud.collection('chatMessages').orderBy('timestamp',descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.lightBlue),
                      );
                    }

                    final documents = snapshot.data!.docs.reversed;
                    List<Column> messageWidgets = [];
                    for (var message in documents) {
                      final messageText = message.get('message');
                      final sender = message.get('user');
                      final currentUser = loggedInUser.email;
                      itsMe = (currentUser == sender);
                    final messageWidget = Column(
                        crossAxisAlignment: itsMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('$sender',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                          ),
                          Bubble(
                            alignment: itsMe?Alignment.topRight : Alignment.topLeft,
                            radius: Radius.circular(8),
                            nip: itsMe?BubbleNip.rightTop:BubbleNip.leftTop,
                            nipHeight: 20,
                            nipWidth: 15,
                            color: itsMe?Color.fromRGBO(79, 121, 66, 1.0):Color.fromRGBO(255, 255, 255, 1.0),
                            child: Text(
                              '$messageText',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 25,color:itsMe?Colors.white:Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      );
                      messageWidgets.add(messageWidget);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        children: messageWidgets,
                      ),
                    );
                  }),
              Container(

                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: TextField(
                        style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),
                        controller: messageRemover,
                        onChanged: (value) {
                          message = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                     Expanded(
                       flex: 1,
                       child: FlatButton(
                           onPressed: () async{
                               PickedFile? pickedFile = await ImagePicker.getImage(
                                source: ImageSource.camera,
                                maxHeight: 1800,
                                maxWidth: 1800
                              );
                              },
                           child: Icon(
                             Icons.camera_alt,
                             size: 30,
                           )
                       ),
                     ),
                    Expanded(
                      flex: 2,
                      child: FlatButton(
                        onPressed: () async {
                          messageRemover.clear();
                          DocumentReference ref = await _cloud
                              .collection('chatMessages')
                              .add(
                                  {'message': message, 'user': loggedInUser.email,'timestamp':DateTime.now().millisecondsSinceEpoch});
                        },
                        child: Text(
                          'Send',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
