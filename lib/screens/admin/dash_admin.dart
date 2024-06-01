import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/providers/current_user.dart';
import 'package:stbbankapplication1/screens/admin_dash.dart';
import 'package:stbbankapplication1/screens/rendez-vous.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({Key? key}) : super(key: key);

  @override
  _AdminDashState createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  final List<Widget> _screens = [RendezVous(), Placeholder()];

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("Salut ${currentUser.currentuser?.nom ?? 'Utilisateur'}"),
        leading:  IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => admin_dash()),
                  );
          },
        ),
        actions: [
          IconButton(
            icon: BadgesPrefix.Badge(
              badgeContent: Text(
                "0",
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {},
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Les rendez-vous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), 
            label: 'Placeholder',
          ),
        ],
      ),
    );
  }
}
