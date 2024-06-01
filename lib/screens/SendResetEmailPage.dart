import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendResetEmailPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendResetEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de réinitialisation envoyé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Envoyer email de réinitialisation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendResetEmail(context),
              child: Text('Envoyer email de réinitialisation'),
            ),
          ],
        ),
      ),
    );
  }
}
