import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/food_catalog.dart';
import '../models/nutrition_models.dart';

class CaloriesScreen extends StatefulWidget {
  const CaloriesScreen({super.key});

  @override
  State<CaloriesScreen> createState() => _CaloriesScreenState();
}

class _CaloriesScreenState extends State<CaloriesScreen> {
  late String _selectedCategory;
  FoodItem? _selectedFood;
  final _quantityController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _selectedCategory = foodCategories.first;
    _selectedFood = foodsForCategory(_selectedCategory).first;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  double get _quantity =>
      double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;

  FoodLog? _previewLog() {
    final food = _selectedFood;
    final grams = _quantity;
    if (food == null || grams <= 0) return null;
    final factor = grams / 100;
    return FoodLog(
      foodName: food.name,
      category: food.category,
      grams: grams,
      calories: food.calories * factor,
      protein: food.protein * factor,
      carbs: food.carbs * factor,
      fat: food.fat * factor,
      sugar: food.sugar * factor,
      fiber: food.fiber * factor,
      healthy: food.healthy,
      createdAt: DateTime.now(),
    );
  }

  void _save() {
    final log = _previewLog();
    if (log == null) return;
    Navigator.pop(context, log);
  }

  @override
  Widget build(BuildContext context) {
    final foods = foodsForCategory(_selectedCategory);
    final selectedFood = _selectedFood;
    final preview = _previewLog();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar alimento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Que comio hoy?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Catalogo con ${foodCatalog.length} alimentos, saludables y ocasionales.',
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: foodCategories
                  .map((category) =>
                      DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value;
                  _selectedFood = foodsForCategory(value).first;
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedFood?.name,
              decoration: const InputDecoration(
                labelText: 'Alimento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              items: foods
                  .map((food) =>
                      DropdownMenuItem(value: food.name, child: Text(food.name)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedFood = findFood(value));
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*([.,]?\d*)?')),
              ],
              decoration: const InputDecoration(
                labelText: 'Cantidad en gramos',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            if (selectedFood != null)
              Card(
                color: selectedFood.healthy
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedFood.healthy
                                ? Icons.favorite
                                : Icons.warning_amber,
                            color: selectedFood.healthy
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedFood.healthy
                                  ? 'Alimento saludable'
                                  : 'Mejor consumir ocasionalmente',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(selectedFood.message),
                      const SizedBox(height: 12),
                      const Text(
                        'Mejores opciones:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: selectedFood.betterOptions
                            .map((option) => Chip(label: Text(option)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            if (preview != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculo aproximado',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _NutrientRow(
                        label: 'Calorias',
                        value: '${preview.calories.toStringAsFixed(0)} kcal',
                      ),
                      _NutrientRow(
                        label: 'Proteina',
                        value: '${preview.protein.toStringAsFixed(1)} g',
                      ),
                      _NutrientRow(
                        label: 'Carbohidratos',
                        value: '${preview.carbs.toStringAsFixed(1)} g',
                      ),
                      _NutrientRow(
                        label: 'Grasa',
                        value: '${preview.fat.toStringAsFixed(1)} g',
                      ),
                      _NutrientRow(
                        label: 'Fibra',
                        value: '${preview.fiber.toStringAsFixed(1)} g',
                      ),
                      _NutrientRow(
                        label: 'Azucar',
                        value: '${preview.sugar.toStringAsFixed(1)} g',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: preview == null ? null : _save,
              icon: const Icon(Icons.check),
              label: const Text('Guardar alimento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutrientRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
