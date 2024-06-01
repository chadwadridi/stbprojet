import 'package:flutter/material.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';

class CurrentUserProvider extends ChangeNotifier {
  Utilisateur _currentuser =
      Utilisateur(uid: "uid", nom: "nom", prenom: "prenom", role: "role" , photoUrl: "photoUrl" , email: "email");
  Utilisateur get currentuser => _currentuser;
  void updateUser(Utilisateur user) {
    _currentuser = user;
    notifyListeners();
  }
   void updateProfilePicture(String photoUrl) {
    _currentuser = _currentuser.copyWith(photoUrl: photoUrl);
    notifyListeners();
  }
}
