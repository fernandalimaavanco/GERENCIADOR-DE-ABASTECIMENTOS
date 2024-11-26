import 'package:controle_de_abastecimento/components/toast_utils.dart';
import 'package:controle_de_abastecimento/widgets/animated_drawer_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _vehicleNameController.text = widget.vehicle!['vehicle_name'] ?? '';
      _plateController.text = widget.vehicle!['plate'] ?? '';
      _modelController.text = widget.vehicle!['model'] ?? '';
      _yearController.text = widget.vehicle!['year'] ?? '';
      _colorController.text = widget.vehicle!['color'] ?? '';
    }
  }

  Future<void> _saveVehicle() async {
    User? user = _auth.currentUser;
    if (user == null) {
      showToast("Usuário não logado.", isSuccess: false);
      return;
    }

    try {
      DatabaseReference vehicleRef;
      if (widget.vehicle != null) {
        vehicleRef = _database.ref('vehicles').child(widget.vehicle!['id']);
      } else {
        vehicleRef = _database.ref('vehicles').push();
      }

      await vehicleRef.set({
        'userId': user.uid,
        'vehicle_name': _vehicleNameController.text,
        'plate': _plateController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'color': _colorController.text,
        'created_at': ServerValue.timestamp,
        'abastecimentos': {},
      });

      showToast(
          widget.vehicle == null
              ? "Veículo cadastrado com sucesso!"
              : "Veículo atualizado com sucesso!",
          isSuccess: true);
        Navigator.pop(context);
    } catch (e) {
      showToast("Erro ao salvar veículo!", isSuccess: false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDrawerLayout(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            widget.vehicle == null ? 'Cadastro de Veículo' : 'Editar Veículo',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          toolbarHeight: 80,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[100],
                  ),
                  padding: const EdgeInsets.all(30.0),
                  child: const Icon(
                    Icons.directions_car_filled,
                    color: Colors.blue,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  label: 'Nome do Veículo',
                  controller: _vehicleNameController,
                  prefixIcon: Icons.drive_file_rename_outline,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Placa',
                  controller: _plateController,
                  prefixIcon: Icons.confirmation_number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Modelo',
                  controller: _modelController,
                  prefixIcon: Icons.directions_car_filled,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Ano de Fabricação',
                  controller: _yearController,
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Cor',
                  controller: _colorController,
                  prefixIcon: Icons.color_lens,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Salvar Veículo',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
