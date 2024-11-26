import 'package:controle_de_abastecimento/components/toast_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FuelingScreen extends StatefulWidget {
  final Map<String, dynamic>? refueling;

  const FuelingScreen({super.key, this.refueling});

  @override
  State<FuelingScreen> createState() => _FuelingScreenState();
}

class _FuelingScreenState extends State<FuelingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController litersController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? selectedVehicleId;
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.refueling != null) {
      litersController.text = widget.refueling!['liters'] ?? '';
      mileageController.text = widget.refueling!['mileage'] ?? '';
      dateController.text = widget.refueling!['date'] ?? '';
    }

    _loadVehicles(widget.refueling?['vehicleId']);
  }

  Future<void> _loadVehicles(String? vehicleId) async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      showToast('Usuário não está logado.', isSuccess: false);
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      DatabaseReference vehiclesRef = _database.ref('vehicles');
      DataSnapshot snapshot =
          await vehiclesRef.orderByChild('userId').equalTo(user.uid).get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> vehiclesData =
            Map<dynamic, dynamic>.from(snapshot.value as Map);

        setState(() {
          vehicles = vehiclesData.entries.map((entry) {
            final vehicle = Map<String, dynamic>.from(entry.value);
            vehicle['id'] = entry.key;
            return vehicle;
          }).toList();

          selectedVehicleId = vehicleId ?? vehicles.first['id'];
          isLoading = false;
        });
      } else {
        setState(() {
          vehicles = [];
          selectedVehicleId = null;
          isLoading = false;
        });
      }
    } catch (e) {
      showToast('Erro ao carregar veículos.', isSuccess: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveFueling() async {
    if (selectedVehicleId == null) {
      showToast('Por favor, selecione um veículo!', isSuccess: false);
      return;
    }

    final liters = litersController.text.trim();
    final mileage = mileageController.text.trim();
    final date = dateController.text.trim();

    if (liters.isEmpty || mileage.isEmpty || date.isEmpty) {
      showToast("Por favor, preencha todos os campos!", isSuccess: false);
      return;
    }

    try {
      if (widget.refueling != null) {
        String oldVehicleId = widget.refueling!['vehicleId'];
        DatabaseReference oldFuelingRef = _database.ref(
            'vehicles/$oldVehicleId/fuelings/${widget.refueling!['fuelingId']}');

        if (oldVehicleId != selectedVehicleId) {
          DatabaseReference newFuelingRef =
              _database.ref('vehicles/$selectedVehicleId/fuelings').push();
          await newFuelingRef.set({
            'liters': liters,
            'mileage': mileage,
            'date': date,
            'created_at': ServerValue.timestamp,
          });
          await oldFuelingRef.remove();
        } else {
          await oldFuelingRef.update({
            'liters': liters,
            'mileage': mileage,
            'date': date,
          });
        }
      } else {
        DatabaseReference fuelingRef =
            _database.ref('vehicles/$selectedVehicleId/fuelings').push();
        await fuelingRef.set({
          'liters': liters,
          'mileage': mileage,
          'date': date,
          'created_at': ServerValue.timestamp,
        });
      }

      showToast('Abastecimento salvo com sucesso!', isSuccess: true);

      litersController.clear();
      mileageController.clear();
      dateController.clear();
      Navigator.pop(context, true);
    } catch (e) {
      showToast('Erro ao salvar abastecimento.', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          widget.refueling == null
              ? 'Cadastro de Abastecimento'
              : 'Editar Abastecimento',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                  Icons.local_gas_station,
                  color: Colors.blue,
                  size: 100,
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : vehicles.isEmpty
                      ? const Text("Nenhum veículo encontrado.")
                      : InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Selecione um veículo',
                            prefixIcon: const Icon(Icons.directions_car,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedVehicleId,
                              isExpanded: true,
                              items: vehicles.map((vehicle) {
                                return DropdownMenuItem<String>(
                                  value: vehicle['id'],
                                  child: Text(vehicle['vehicle_name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedVehicleId = value;
                                });
                              },
                            ),
                          ),
                        ),
              const SizedBox(height: 20),
              TextField(
                controller: litersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantidade de Litros',
                  prefixIcon: const Icon(Icons.local_drink, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: mileageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quilometragem Atual',
                  prefixIcon: const Icon(Icons.speed, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data do Abastecimento',
                  prefixIcon:
                      const Icon(Icons.calendar_today, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dateController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveFueling,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Salvar',
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
}
