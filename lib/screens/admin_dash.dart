
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/providers/current_user.dart';
import 'package:stbbankapplication1/screens/admin/dash_admin.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/services/auth/auth.dart';
import 'package:stbbankapplication1/services/gestion_profile/ChangeProfilePicturePage.dart';
import 'package:stbbankapplication1/services/gestion_profile/changer_password.dart';

class admin_dash extends StatefulWidget {
  const admin_dash({Key? key}) : super(key: key);

  @override
  _admin_dashState createState() => _admin_dashState();
}

class _admin_dashState extends State<admin_dash> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  int _notificationCount = 0;
  List<Map<String, dynamic>> data = [];
  List<dynamic> agenciesData = [];
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initializeNotifications();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print('Current user: ${_currentUser!.displayName}');
    }
  }

  Future<void> _initializeNotifications() async {
    // Initialisation des notifications
  }

  @override
  Widget build(BuildContext context) {
    print("Data length: ${data.length}");

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Mon Profil'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Consumer<CurrentUserProvider>(
              builder: (context, currentUserProvider, _) {
                final currentUser = currentUserProvider.currentuser;
                return UserAccountsDrawerHeader(
                  accountName: Text(currentUser.nom),
                  accountEmail: Text(currentUser.prenom),
                  currentAccountPicture: CircleAvatar(
                    radius: 80.0,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('img/profile.jpg') as ImageProvider,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Réinitialiser le mot de passe'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Modifier la photo de profil'),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePictureChanger()),
                );
                if (result != null && result is String) {
                  setState(() {
                     profileImageUrl = result;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () async {
                await UserAuth().signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: w,
            height: h * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/gestion8.gif"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDash()));
                },
                child: Image.asset(
                  'img/liste.gif',
                  width: 200,
                  height: 200,
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
                  height: 150,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
