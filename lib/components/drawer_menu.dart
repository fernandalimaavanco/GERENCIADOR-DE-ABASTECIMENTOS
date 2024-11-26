import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:controle_de_abastecimento/widgets/new_row.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'Usuário';
        userEmail = user.email ?? 'Email não disponível';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 0, 80, 145),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 40, bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const Image(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/standard_profile.png'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'Carregando...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userEmail ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Column(
              children: <Widget>[
                NewRow(
                  text: 'Home',
                  icon: Icons.home,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                const SizedBox(height: 30),
                NewRow(
                  text: 'Adicionar Veículo',
                  icon: Icons.add_circle,
                  onTap: () {
                    Navigator.pushNamed(context, '/add-vehicle');
                  },
                ),
                const SizedBox(height: 30),
                NewRow(
                  text: 'Abastecimentos',
                  icon: Icons.local_gas_station,
                  onTap: () {
                    Navigator.pushNamed(context, '/abastecimentos');
                  },
                ),
                const SizedBox(height: 30),
                NewRow(
                  text: 'Perfil',
                  icon: Icons.manage_accounts,
                  onTap: () {
                    Navigator.pushNamed(context, '/perfil');
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),

            Row(
              children: <Widget>[
                Icon(
                  Icons.cancel,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut(); 
                    Navigator.pushReplacementNamed(
                        context, '/welcome');
                  },
                  child: Text(
                    'Sair',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
