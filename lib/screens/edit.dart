import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  const EditUserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        _nomController.text = userData['nom'] ?? '';
        _prenomController.text = userData['prenom'] ?? '';
        _roleController.text = userData['role'] ?? '';
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'role': _roleController.text,
      });
      Navigator.pop(context);
    } catch (error) {
      print('Error updating user details: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier l\'utilisateur'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(labelText: 'Nom'),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _prenomController,
                    decoration: InputDecoration(labelText: 'Prénom'),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(labelText: 'Rôle'),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      updateUserDetails();
                    },
                    child: Text('Enregistrer'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _roleController.dispose();
    super.dispose();
  }
}
