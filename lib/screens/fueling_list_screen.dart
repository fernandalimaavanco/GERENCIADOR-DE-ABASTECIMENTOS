import 'package:controle_de_abastecimento/components/toast_utils.dart';
import 'package:controle_de_abastecimento/screens/fueling_screen.dart';
import 'package:controle_de_abastecimento/widgets/animated_drawer_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FuelingListScreen extends StatefulWidget {
  const FuelingListScreen({super.key});

  @override
  State<FuelingListScreen> createState() => _FuelingListScreenState();
}

class _FuelingListScreenState extends State<FuelingListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Map<String, dynamic>> refuelingData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFuelings();
  }

  Future<void> _loadFuelings() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    DatabaseReference vehiclesRef = _database.ref('vehicles');
    DataSnapshot snapshot =
        await vehiclesRef.orderByChild('userId').equalTo(user.uid).get();

    if (snapshot.exists) {
      List<Map<String, dynamic>> fuelings = [];
      final vehicles = Map<String, dynamic>.from(snapshot.value as Map);

      vehicles.forEach((vehicleId, vehicleData) {
        final fuelingsData = vehicleData['fuelings'];
        if (fuelingsData != null) {
          final fuelingsMap = Map<String, dynamic>.from(fuelingsData);

          fuelingsMap.forEach((fuelingId, fuelingData) {
            fuelings.add({
              'vehicleId': vehicleId,
              'fuelingId': fuelingId,
              'carName': vehicleData['vehicle_name'],
              'carImage': vehicleData['carImage'],
              'liters': fuelingData['liters'],
              'date': fuelingData['date'],
              'mileage': fuelingData['mileage'],
            });
          });
        }
      });

      setState(() {
        refuelingData = fuelings;
        isLoading = false;
      });
    } else {
      setState(() {
        refuelingData = [];
        isLoading = false;
      });
    }
  }

  Future<void> _deleteFueling(String vehicleId, String fuelingId) async {
    try {
      DatabaseReference fuelingRef =
          _database.ref('vehicles/$vehicleId/fuelings/$fuelingId');
      await fuelingRef.remove();

      showToast("Abastecimento excluído com sucesso!", isSuccess: true);
      _loadFuelings();
    } catch (e) {
      showToast("Erro ao excluir abastecimento.", isSuccess: false);
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
            'Abastecimentos',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(
                  child: Lottie.asset(
                    'assets/animations/car_loading.json',
                    width: 300,
                    height: 300,
                  ),
                )
              : refuelingData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            color: Colors.blue.shade200,
                            size: 100,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sem abastecimentos registrados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: refuelingData.length,
                      itemBuilder: (context, index) {
                        final refueling = refuelingData[index];
                        final vehicleId = refueling['vehicleId'];
                        final fuelingId = refueling['fuelingId'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.shade100,
                                  ),
                                  child: refueling['carImage'] != null
                                      ? ClipOval(
                                          child: Image.network(
                                            refueling['carImage'],
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.directions_car,
                                          color: Colors.blue, size: 40),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        refueling['carName'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Litros: ${refueling['liters']}"),
                                      Text("Data: ${refueling['date']}"),
                                      Text(
                                          "Quilometragem: ${refueling['mileage']} km"),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        bool? updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FuelingScreen(
                                                refueling: refueling),
                                          ),
                                        );

                                        if (updated == true) {
                                          _loadFuelings();
                                        }
                                      },
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(
                                            context, vehicleId, fuelingId);
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () async {
            bool? updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FuelingScreen(),
              ),
            );

            if (updated == true) {
              _loadFuelings();
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String vehicleId, String fuelingId) {
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
                'Tem certeza que deseja excluir este abastecimento?',
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
                      _deleteFueling(vehicleId, fuelingId);
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
}
