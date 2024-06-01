import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de réinitialisation envoyé')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erreur inconnue')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réinitialiser le mot de passe'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
           Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text('Réinitialiser le mot de passe'),
                  ),
          ],
        ),
      ),
    );
  }
}

