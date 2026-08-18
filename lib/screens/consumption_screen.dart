import 'package:flutter/material.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<ConsumptionScreen> createState() => _ConsumptionScreenState();
}

class _ConsumptionScreenState extends State<ConsumptionScreen> {
  int caloriesBurnt = 0;

  void _addCalories(int value) {
    setState(() {
      caloriesBurnt = (caloriesBurnt + value).clamp(0, 1000).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actividad fisica')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Calorias quemadas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '$caloriesBurnt kcal',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  onPressed: () => _addCalories(-50),
                  child: const Text('-50 kcal'),
                ),
                OutlinedButton(
                  onPressed: () => _addCalories(-100),
                  child: const Text('-100 kcal'),
                ),
                FilledButton(
                  onPressed: () => _addCalories(50),
                  child: const Text('+50 kcal'),
                ),
                FilledButton(
                  onPressed: () => _addCalories(100),
                  child: const Text('+100 kcal'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, caloriesBurnt),
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
