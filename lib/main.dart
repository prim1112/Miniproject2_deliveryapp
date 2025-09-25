<<<<<<< Updated upstream
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dalivery_application/firebase_options.dart';
import 'package:dalivery_application/pages/rider/rider_homepage.dart';
import 'package:firebase_core/firebase_core.dart';
=======
import 'package:dalivery_application/pages/homepage.dart';
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
      home: RiderHomepage(),
=======
      home: Homepage(),
>>>>>>> Stashed changes
    );
  }
}
