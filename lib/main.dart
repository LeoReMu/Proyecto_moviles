import 'package:flutter/material.dart';
import 'package:moviles/routes/pages.dart';
import 'package:moviles/routes/routes.dart';
import 'package:moviles/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moviles/services/AuthModel.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: routes.SPLASH,
      routes: appRoutes(),
    );
  }
}
