import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:controle_de_abastecimento/screens/add_vehicle.dart';
import 'package:controle_de_abastecimento/screens/fueling_list_screen.dart';
import 'package:controle_de_abastecimento/screens/login_screen.dart';
import 'package:controle_de_abastecimento/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:controle_de_abastecimento/screens/home_screen.dart';
import 'package:controle_de_abastecimento/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:controle_de_abastecimento/screens/welcome_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/welcome' : '/home',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/add-vehicle': (context) => const AddVehicleScreen(),
        '/perfil': (context) => const ProfileScreen(),
        '/abastecimentos': (context) => const FuelingListScreen(),
      },
    );
  }
}
