
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<void> sendWelcomeEmail(String email, String password, String nom, String prenom) async {
  final smtpServer = gmail('houilinour@gmail.com', 'jhcb srfj lqva gmaq');

  final message = Message()
    ..from = Address('STB-email@gmail.com', 'RapidBankBooking')
    ..recipients.add(email)
    ..subject = 'Votre mot de passe a été modifié'
    ..text = 'Bonjour $prenom $nom,\n\n'
        'Votre mot de passe a été modifié avec succès.\n\n'
        'Votre adresse e-mail: $email\n'
        'Votre nouveau mot de passe: $password\n\n'
        'Merci d\'utiliser RapidBankBooking.';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } catch (e) {
    print('Error sending email: $e');
  }
}

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _newPassword = '';

  void _changePassword() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(_newPassword);
        await _firestore.collection('users').doc(user.uid).update({
          'password': _newPassword,
        });
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String email = user.email!;
        String nom = userDoc['nom'];
        String prenom = userDoc['prenom'];
        await sendWelcomeEmail(email, _newPassword, nom, prenom);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mot de passe modifié avec succès')),
        );
        Navigator.pop(context);
      } catch (error) {
        print(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification du mot de passe')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non connecté')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Changer le mot de passe'),
      ),
      body: Container(
      width: double.infinity,
        height: double.infinity,
        color: Color.fromARGB(87, 68, 155, 114),
      child :Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: w,
                height: h * 0.3, 
                decoration: BoxDecoration(
                  
                  image: DecorationImage(
                    image: AssetImage("img/pswd.gif"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 50,),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _newPassword = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                    _changePassword();
                  }
                },
                child: Text('Changer le mot de passe'),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChangePasswordScreen(),
  ));
}
