import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/nutrition_models.dart';
import '../services/nutrition_store.dart';

class UserRegistrationScreen extends StatefulWidget {
  final ChildUser? initialUser;

  const UserRegistrationScreen({super.key, this.initialUser});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  String _activity = 'Media';

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age.toString() ?? '');
    _weightController =
        TextEditingController(text: user?.weightKg.toStringAsFixed(0) ?? '');
    _heightController =
        TextEditingController(text: user?.heightCm.toStringAsFixed(0) ?? '');
    _activity = user?.activityLevel ?? 'Media';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  int _calculateCalories(int age, double weight, String activity) {
    final base = age <= 8 ? 1400 : 1700;
    final weightAdjustment = ((weight - 25) * 18).round();
    final activityAdjustment = switch (activity) {
      'Baja' => -150,
      'Alta' => 250,
      _ => 0,
    };
    return (base + weightAdjustment + activityAdjustment)
        .clamp(1200, 2400)
        .toInt();
  }

  int _calculateWater(double weight) {
    return (weight * 35).round().clamp(1000, 2200).toInt();
  }

  double? _parseNumber(String? value) {
    return double.tryParse((value ?? '').replaceAll(',', '.'));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text);
    final weight = _parseNumber(_weightController.text)!;
    final height = _parseNumber(_heightController.text)!;
    final user = ChildUser(
      id: widget.initialUser?.id ??
          'user_${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      age: age,
      weightKg: weight,
      heightCm: height,
      activityLevel: _activity,
      calorieGoal: _calculateCalories(age, weight, _activity),
      waterGoalMl: _calculateWater(weight),
    );

    try {
      await NutritionStore.saveUser(user).timeout(const Duration(seconds: 3));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el perfil.')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, user);
  }

  String? _numberValidator(String? value, int min, int max, String label) {
    final number = _parseNumber(value);
    if (number == null) return 'Escribe $label';
    if (number < min || number > max) {
      return '$label debe estar entre $min y $max';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialUser != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar perfil' : 'Nuevo perfil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Datos basicos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Usaremos estos datos para calcular metas diarias aproximadas.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.face),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Escribe el nombre'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ageController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Edad (6 a 12 anos)',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _numberValidator(value, 6, 12, 'la edad'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _numberValidator(value, 15, 80, 'el peso'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estatura (cm)',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    _numberValidator(value, 100, 170, 'la estatura'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _activity,
                decoration: const InputDecoration(
                  labelText: 'Actividad diaria',
                  prefixIcon: Icon(Icons.directions_run),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                  DropdownMenuItem(value: 'Media', child: Text('Media')),
                  DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                ],
                onChanged: (value) =>
                    setState(() => _activity = value ?? 'Media'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Guardar cambios' : 'Crear perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
