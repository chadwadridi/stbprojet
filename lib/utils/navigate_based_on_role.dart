import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/admin/dash_admin.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/screens/dash_super.dart';
import 'package:stbbankapplication1/screens/user.dart';

Widget widgetByRole(String userRole) {
  switch (userRole) {
    case 'admin':
      return const AdminDash();
    case 'superAdmin':
      return const super_dash();
    case 'user':
      return const UserScreen();
    default:
      return const Login();
  }
}
