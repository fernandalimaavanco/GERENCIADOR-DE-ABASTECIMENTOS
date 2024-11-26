import 'package:controle_de_abastecimento/components/toast_utils.dart';
import 'package:controle_de_abastecimento/screens/add_vehicle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:controle_de_abastecimento/widgets/animated_drawer_layout.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DatabaseReference vehiclesRef = _database.ref('vehicles');
      DataSnapshot snapshot =
          await vehiclesRef.orderByChild('userId').equalTo(user.uid).get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> vehicles = [];
        snapshot.children.forEach((child) {
          Map<String, dynamic> vehicleData = Map.from(child.value as Map);
          vehicleData['id'] = child.key;
          vehicles.add(vehicleData);
        });

        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      } else {
        setState(() {
          _vehicles = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    await _database.ref('vehicles/$vehicleId').remove();
    showToast("Veículo deletado com sucesso!", isSuccess: true);
    _loadVehicles();
  }

  void _viewVehicleDetails(Map<String, dynamic> vehicle) async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();

    DatabaseReference fuelingsRef =
        database.child('vehicles/${vehicle['id']}/fuelings');

    final DataSnapshot snapshot =
        await fuelingsRef.orderByChild('timestamp').limitToLast(2).get();

    double averageConsumption;

    if (!snapshot.exists) {
      averageConsumption = 0.0;
    } else {
      final List<Map<String, dynamic>> fuelings = [];
      for (var child in snapshot.children) {
        fuelings.add(Map<String, dynamic>.from(child.value as Map));
      }

      if (fuelings.length < 2) {
        averageConsumption = 0.0;
      } else {
        final currentFueling = fuelings[1];
        final previousFueling = fuelings[0];

        final double kilometersCurrent =  double.tryParse(currentFueling['mileage'].toString()) ?? 0.0;
        final double kilometersPrevious = double.tryParse(previousFueling['mileage'].toString()) ?? 0.0;
        final double fuelQuantity =
            double.tryParse(currentFueling['liters'].toString()) ?? 0.0;

        print(kilometersCurrent);
        print(kilometersPrevious);
        print(fuelQuantity);

        if (fuelQuantity <= 0) {
          averageConsumption = 0.0;
        } else {
          averageConsumption =
              (kilometersCurrent - kilometersPrevious) / fuelQuantity;
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 203, 218, 246),
          title: Row(
            children: [
              const Icon(Icons.directions_car,
                  color: Color.fromARGB(255, 0, 62, 177)),
              const SizedBox(width: 8),
              Text(vehicle['vehicle_name'],
                  style:
                      const TextStyle(color: Color.fromARGB(255, 0, 62, 177))),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions,
                      color: Color.fromARGB(255, 0, 62, 177)),
                  const SizedBox(width: 8),
                  Text("Placa: ${vehicle['plate']}",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 2, 0, 39))),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(Icons.model_training,
                      color: Color.fromARGB(255, 0, 62, 177)),
                  const SizedBox(width: 8),
                  Text("Modelo: ${vehicle['model']}",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 2, 0, 39))),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Color.fromARGB(255, 0, 62, 177)),
                  const SizedBox(width: 8),
                  Text("Ano: ${vehicle['year']}",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 2, 0, 39))),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Icon(Icons.color_lens,
                      color: Color.fromARGB(255, 0, 62, 177)),
                  const SizedBox(width: 8),
                  Text("Cor: ${vehicle['color']}",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 2, 0, 39))),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Icon(Icons.local_gas_station,
                      color: Color.fromARGB(255, 0, 62, 177)),
                  const SizedBox(width: 8),
                  Text(
                    "Média de Consumo: ${averageConsumption.toStringAsFixed(2)} km/l",
                    style:
                        const TextStyle(color: Color.fromARGB(255, 2, 0, 39)),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fechar',
                style: TextStyle(color: Color.fromARGB(255, 50, 50, 50)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String vehicleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Tem certeza que deseja excluir este veículo?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _deleteVehicle(vehicleId);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Excluir',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Veículo excluído com sucesso!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDrawerLayout(
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Meus Veículos',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          toolbarHeight: 80,
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/animations/car_loading.json',
                        width: 300, height: 300),
                  ],
                ),
              )
            : _vehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 100,
                          color: Colors.blue.shade200,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sem veículos registrados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _vehicles.map((vehicle) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car,
                                    size: 40, color: Colors.blue),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle['vehicle_name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Placa: ${vehicle['plate']}"),
                                      Text("Modelo: ${vehicle['model']}"),
                                      Text("Ano: ${vehicle['year']}"),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddVehicleScreen(
                                                    vehicle: vehicle),
                                          ),
                                        )
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _showDeleteConfirmDialog(
                                          vehicle['id']),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info,
                                          color: Colors.green),
                                      onPressed: () =>
                                          _viewVehicleDetails(vehicle),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
      ),
    );
  }
}
