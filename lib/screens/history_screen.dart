import 'package:flutter/material.dart';

import '../models/nutrition_models.dart';
import '../services/nutrition_store.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FoodLog> _logs = [];
  int _waterMl = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await NutritionStore.loadAllFoodLogs();
    final water = await NutritionStore.loadWaterMl();
    setState(() {
      _logs = logs;
      _waterMl = water;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial del dia')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.water_drop)),
                    title: const Text('Agua registrada'),
                    subtitle: Text('$_waterMl ml'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alimentos registrados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_logs.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Aun no hay alimentos registrados.'),
                    ),
                  )
                else
                  ..._logs.map(
                    (log) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              log.healthy ? Colors.green.shade100 : Colors.orange.shade100,
                          child: Icon(
                            log.healthy ? Icons.favorite : Icons.warning_amber,
                            color: log.healthy ? Colors.green : Colors.orange,
                          ),
                        ),
                        title:
                            Text('${log.foodName} - ${log.grams.toStringAsFixed(0)} g'),
                        subtitle: Text(
                          '${log.calories.toStringAsFixed(0)} kcal | '
                          'Proteina ${log.protein.toStringAsFixed(1)} g | '
                          'Azucar ${log.sugar.toStringAsFixed(1)} g',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
