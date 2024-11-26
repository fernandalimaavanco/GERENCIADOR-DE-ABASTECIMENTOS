import 'package:controle_de_abastecimento/components/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userRef = _database.ref('users/${user.uid}');
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        setState(() {
          nameController.text =
              userSnapshot.child('name').value as String? ?? '';
          emailController.text =
              userSnapshot.child('email').value as String? ?? '';
        });
      }
    }
  }

  Future<void> _requestPasswordAndReauthenticate() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Digite sua senha para continuar',
            style: TextStyle(color: Colors.blue),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _reauthenticateUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Reautenticar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reauthenticateUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String password = passwordController.text;
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        Navigator.pop(context);
        await _saveProfileChanges();
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showToast('Erro ao reautenticar usuário.', isSuccess: false);
      }
    }
  }

  Future<void> _saveProfileChanges() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        if (emailController.text != user.email) {
          await user.verifyBeforeUpdateEmail(emailController.text);
          showToast('Verifique o novo e-mail para concluir a alteração.',
              isSuccess: true);
          _monitorEmailVerification(user);
        }

        DatabaseReference userRef = _database.ref('users/${user.uid}');
        await userRef.update({
          'name': nameController.text,
        });

        await user.updateDisplayName(nameController.text);
        showToast('Nome atualizado com sucesso!', isSuccess: true);
      } on FirebaseAuthException catch (e) {
        showToast('Erro ao atualizar usuário.', isSuccess: false);
      }
    }
  }

  void _monitorEmailVerification(User user) async {
    bool emailVerified = false;

    while (!emailVerified) {
      await Future.delayed(const Duration(seconds: 5));
      await user.reload();
      emailVerified = user.emailVerified;

      if (emailVerified) {
        DatabaseReference userRef = _database.ref('users/${user.uid}');
        await userRef.update({
          'email': user.email,
        });

        showToast('Alterações salvas com sucesso!', isSuccess: true);

        Navigator.pop(context, true);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[100],
                ),
                padding: const EdgeInsets.all(30.0),
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: nameController,
                label: 'Nome',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                label: 'E-mail',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPasswordAndReauthenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Salvar Alterações',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
