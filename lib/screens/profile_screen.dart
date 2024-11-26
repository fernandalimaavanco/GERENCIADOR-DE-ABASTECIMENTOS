import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:controle_de_abastecimento/screens/edit_profile_screen.dart';
import 'package:controle_de_abastecimento/widgets/animated_drawer_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String _userName = '';
  String _userLogin = '';
  int _totalVehicles = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DatabaseReference userRef = _database.ref('users/${user.uid}');
      DatabaseReference vehiclesRef = _database.ref('vehicles');

      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        setState(() {
          _userName = userSnapshot.child('name').value as String? ?? 'Usuário';
          _userLogin = userSnapshot.child('email').value as String? ?? '---';
        });
      }

      final vehiclesSnapshot =
          await vehiclesRef.orderByChild('userId').equalTo(user.uid).get();

      if (vehiclesSnapshot.exists) {
        setState(() {
          _totalVehicles = vehiclesSnapshot.children.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDrawerLayout(
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Perfil do Usuário',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          toolbarHeight: 80,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildProfileRow(
                          label: 'Login:',
                          value: _userLogin,
                        ),
                        _buildProfileRow(
                          label: 'Veículos cadastrados:',
                          value: _totalVehicles.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                    if (updated == true) {
                      _loadUserProfile(); 
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Editar Perfil',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
