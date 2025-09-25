
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalivery_application/firebase_options.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:dalivery_application/pages/user/user_register.dart';
=======
=======
>>>>>>> Stashed changes
import 'package:dalivery_application/pages/homepage.dart';
import 'package:dalivery_application/pages/rider/rider_homepage.dart';
>>>>>>> Stashed changes
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD

      home: Homepage(),
      
=======
      home: UserRegisterPage(),
>>>>>>> main
    );
  }
}
