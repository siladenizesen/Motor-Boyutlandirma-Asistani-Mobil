import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/giris_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MotorAsistaniApp());
}

class MotorAsistaniApp extends StatelessWidget {
  const MotorAsistaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motor Boyutlandırma Asistanı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GirisEkrani(),
    );
  }
}
