
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/screens/liste-agents.dart';
import 'package:stbbankapplication1/screens/new_agent.dart';
import 'package:stbbankapplication1/services/gestion_profile/changer_password.dart';

class super_dash extends StatefulWidget {
  const super_dash({Key? key}) : super(key: key);

  @override
  _super_dashState createState() => _super_dashState();
}

class _super_dashState extends State<super_dash> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  
  List<Map<String, dynamic>> data = [];
  List<dynamic> agenciesData = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print('Current user: ${_currentUser!.displayName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Data length: ${data.length}");

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20), 
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Colors.blue,
            title: Text('Mon Profil'),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.account_circle),
                onSelected: (value) {
                  switch (value) {
                    case 'Réinitialiser le mot de passe':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Réinitialiser le mot de passe'}
                      .map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => new_agent()));
            },
            child: Image.asset(
              'img/Button.gif',
              width: 300,
              height: 200,
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: () async {
               Navigator.push(context, MaterialPageRoute(builder: (context) => SuperAdmin()));
            },
            child: Image.asset(
              'img/liste.gif',
              width: 200,
              height: 300,
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: Image.asset(
              'img/logout.gif',
              width: 180,
              height: 180,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Color.fromARGB(187, 243, 178, 92),
        backgroundColor: Color.fromARGB(218, 252, 162, 60),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: super_dash(),
  ));
}

