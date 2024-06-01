import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/models/operation_type.dart';
import 'package:stbbankapplication1/providers/current_user.dart';
import 'package:stbbankapplication1/screens/mapPage/map_page.dart';
import 'package:stbbankapplication1/services/auth/auth.dart';
import 'package:stbbankapplication1/services/gestion_profile/ChangeProfilePicturePage.dart';
import 'package:stbbankapplication1/services/gestion_profile/changer_password.dart';
import 'package:stbbankapplication1/services/location_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _notificationCount = 0;
  int minutesLeft = 0;
  bool dataFound = false;
  String operation = "Loading";
  late Timer _timer;
  String code = "";
  String notificationShown = "";
  int waitingTime = 10;
  int showNotificationWhen = 8;
  int timestamp = 0;
  bool loading = false;
  String? profileImageUrl;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> loadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final profileImageUrl = userDocument.get('profilePicture');
        if (profileImageUrl != null) {
          setState(() {
            this.profileImageUrl = profileImageUrl;
          });
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error loading user profile image URL: $error');
      }
    }
  }

  void listenToRealtimeUpdates() {
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DatabaseReference _databaseReference =
        FirebaseDatabase.instance.ref().child('reservations/$currentDate/');
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print("listening");
      _databaseReference.onValue.listen((event) {
        final data = event.snapshot.value;
        if (mounted) {
          if (data is Map<Object?, Object?>) {
            data.forEach((key, value) {
              if (value is Map<Object?, Object?> &&
                  value['madeBy'] == FirebaseAuth.instance.currentUser!.uid) {
                int deadlineTimestamp =
                    int.parse(value['deadlineTime'].toString());
                DateTime deadlineDateTime =
                    DateTime.fromMillisecondsSinceEpoch(deadlineTimestamp);
                Duration remainingTime =
                    deadlineDateTime.difference(DateTime.now());
                OperationType op = operationTypes.firstWhere(
                  (element) => element.id == value['operationId'],
                  orElse: () => OperationType(id: "id", name: "id Not found"),
                );
                print("remainingTime ${remainingTime.inMinutes}");
                if (remainingTime.inMinutes < showNotificationWhen &&
                    notificationShown != value['madeAt'].toString()) {
                  notificationShown = value['madeAt'].toString();
                  _notificationCount++;
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: 2,
                      channelKey: "cloudsoftware",
                      title: "Rendez vous",
                      body: "vous reste $showNotificationWhen min",
                    ),
                  );
                }
                if (mounted) {
                  updateData(remainingTime, value['code'].toString(), op,
                      deadlineTimestamp);
                }
              }
            });
          } else {
            print('Unexpected data format: $data');
          }
        }
      });
    });
  }

  void updateData(Duration remainingTime, String _code,
      OperationType operationType, int time) {
    setState(() {
      if (remainingTime.inMinutes < 0) {
        dataFound = false;
      } else {
        dataFound = true;
        minutesLeft = remainingTime.inMinutes;
        timestamp = time;
        code = _code;
        operation = operationType.name;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    listenToRealtimeUpdates();
    loadProfileImage(); 
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context).currentuser;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return LoadingOverlay(
      isLoading: loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            'Bienvenue  ${currentUser.nom}',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
           IconButton(
              icon: BadgesPrefix.Badge(
                badgeContent: Text(
                  _notificationCount.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(Icons.notifications),
              ),
              onPressed: () {
              },
            ),
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
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
            GestureDetector(
              onTap: () async {
                setState(() {
                  loading = !loading;
                });
                bool hasPermission =
                    await LocationProvider().handleLocationPermission(context);
                if (!hasPermission) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Allow location permission")));
                  setState(() {
                    loading = !loading;
                  });
                  return;
                }
                LocationInfo locationInfo =
                    await LocationProvider().getLocation();

                setState(() {
                  loading = !loading;
                });
                _timer.cancel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            locationInfo: locationInfo,
                          )),
                );
              },
              child: Container(
                width: w,
                height: h * 0.6,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("img/marker.gif"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    dataFound
                        ? Card(
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  final DatabaseReference databaseRef =
                                      FirebaseDatabase.instance.ref().child(
                                          "reservations/${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(timestamp))}/${FirebaseAuth.instance.currentUser!.uid}/");
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirm Deletion"),
                                        content: Text(
                                            "Are you sure you want to delete?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Delete"),
                                            onPressed: () {
                                              databaseRef.remove().then((_) {
                                                if (mounted) {
                                                  setState(() {
                                                    _timer.cancel();
                                                    dataFound = false;
                                                  });
                                                }
                                                print("Delete succeeded");
                                                Navigator.of(context).pop();
                                              }).catchError((error) {
                                                print("Delete failed: $error");
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(
                                operation,
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text("$minutesLeft min left"),
                              trailing: Text(code),
                            ),
                          )
                        : Text(
                            "Votre Rendez-vous s'affiche ici",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ViewMapButton extends StatefulWidget {
  final VoidCallback onClicked;
  const ViewMapButton({Key? key, required this.onClicked});

  @override
  State<ViewMapButton> createState() => _ViewMapButtonState();
}

class _ViewMapButtonState extends State<ViewMapButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.white,
                Colors.lightBlue,
                Color.fromARGB(255, 8, 57, 143),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            onPressed: widget.onClicked,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "View Full Map",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
