import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String uid;
  String nom;
  String prenom;
  String role;
  final String photoUrl;
  final String email;

  Utilisateur({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.photoUrl,
    required this.email,
  });

  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Utilisateur(
      uid: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      role: data['role'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Utilisateur copyWith({
    String? nom,
    String? prenom,
    String? role,
    String? photoUrl,
    String? email,
  }) {
    return Utilisateur(
      uid: this.uid,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
    );
  }
}
