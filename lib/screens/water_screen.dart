import 'package:flutter/material.dart';

class WaterScreen extends StatefulWidget {
  final int initialWaterMl;
  final int goalMl;

  const WaterScreen({
    super.key,
    this.initialWaterMl = 0,
    this.goalMl = 1500,
  });

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  late int waterIntake;

  @override
  void initState() {
    super.initState();
    waterIntake = widget.initialWaterMl;
  }

  void _addWater(int value) {
    setState(() {
      waterIntake = (waterIntake + value).clamp(0, widget.goalMl * 2).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (waterIntake / widget.goalMl).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar agua')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Hidratacion del dia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Suma los vasos de agua que tomaste hoy.'),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 16,
                        backgroundColor: Colors.blue.shade50,
                        color: Colors.blue,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$waterIntake',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('de ${widget.goalMl} ml'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  onPressed: () => _addWater(-250),
                  child: const Text('-250 ml'),
                ),
                OutlinedButton(
                  onPressed: () => _addWater(-100),
                  child: const Text('-100 ml'),
                ),
                FilledButton(
                  onPressed: () => _addWater(100),
                  child: const Text('+100 ml'),
                ),
                FilledButton(
                  onPressed: () => _addWater(250),
                  child: const Text('+250 ml'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, waterIntake),
              icon: const Icon(Icons.save),
              label: const Text('Guardar agua'),
            ),
          ],
        ),
      ),
    );
  }
}
