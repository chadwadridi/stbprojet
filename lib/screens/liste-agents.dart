import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/dash_super.dart';
import 'package:stbbankapplication1/screens/edit.dart';

class SuperAdmin extends StatefulWidget {
  const SuperAdmin({Key? key}) : super(key: key);

  @override
  State<SuperAdmin> createState() => SuperAdminState();
}

class SuperAdminState extends State<SuperAdmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  bool isSearchBarOpen = false;

  void toggleSearchBar() {
    setState(() {
      isSearchBarOpen = !isSearchBarOpen;
      if (!isSearchBarOpen) {
        searchQuery = '';
      }
    });
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _auth.currentUser?.delete();
    } catch (e) {
      print("Error deleting user from Firebase Authentication: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: isSearchBarOpen
            ? TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
              )
            : const Text('Liste des Utilisateurs'),
        leading: IconButton(
          icon: Icon(isSearchBarOpen ? Icons.close : Icons.arrow_back),
          onPressed: () {
            if (isSearchBarOpen) {
              toggleSearchBar();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => super_dash()),
              );
            }
          },
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(isSearchBarOpen ? Icons.search : Icons.search_outlined),
            onPressed: toggleSearchBar,
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').where('role', isEqualTo: 'admin').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final users = snapshot.data!.docs;

            final filteredUsers = users
                .where((userDocument) =>
                    (userDocument.data() as Map<String, dynamic>)['nom']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: filteredUsers.map((userDocument) {
                final user = userDocument.data() as Map<String, dynamic>;
                final userId = userDocument.id;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text('${user['nom']} ${user['prenom']}', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Rôle: ${user['role']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUserScreen(userId: userId),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Supprimer cet utilisateur?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Annuler'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Supprimer'),
                                      onPressed: () async {
                                        await deleteUser(userId);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
