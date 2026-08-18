import 'package:flutter/material.dart';

import '../data/challenges.dart';
import '../models/nutrition_models.dart';
import '../services/nutrition_store.dart';
import 'calories_screen.dart';
import 'challenges_screen.dart';
import 'history_screen.dart';
import 'profiles_screen.dart';
import 'settings_screen.dart';
import 'user_registration_screen.dart';
import 'water_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool darkMode;
  final Function(bool) toggleTheme;

  const DashboardScreen({
    super.key,
    required this.darkMode,
    required this.toggleTheme,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ChildUser? _user;
  DailyStats _stats = DailyStats.empty();
  Set<String> _completedChallenges = {};
  ChallengeProgress? _challengeProgress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    ChildUser? user;
    var stats = DailyStats.empty();
    var completed = <String>{};

    try {
      user = await NutritionStore.loadUser().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      user = null;
    }

    try {
      stats = await NutritionStore.loadDailyStats().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      stats = DailyStats.empty();
    }

    ChallengeProgress? challengeProgress;
    try {
      challengeProgress = await NutritionStore.loadChallengeProgress(
        dailyChallenges.length,
      ).timeout(
        const Duration(seconds: 2),
      );
      completed = challengeProgress.completedIds;
    } catch (_) {
      completed = <String>{};
      challengeProgress = null;
    }

    if (!mounted) return;
    setState(() {
      _user = user;
      _stats = stats;
      _completedChallenges = completed;
      _challengeProgress = challengeProgress;
      _loading = false;
    });
  }

  Future<void> _openUserForm() async {
    await Navigator.push<ChildUser>(
      context,
      MaterialPageRoute(
        builder: (_) => UserRegistrationScreen(initialUser: _user),
      ),
    );
    await _load();
  }

  Future<void> _openProfiles() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilesScreen()),
    );
    await _load();
  }

  Future<void> _openFood() async {
    final log = await Navigator.push<FoodLog>(
      context,
      MaterialPageRoute(builder: (_) => const CaloriesScreen()),
    );
    if (log != null) {
      await NutritionStore.addFoodLog(log);
      await _load();
    }
  }

  Future<void> _openWater() async {
    final goal = _user?.waterGoalMl ?? 1500;
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => WaterScreen(
          initialWaterMl: _stats.waterMl,
          goalMl: goal,
        ),
      ),
    );
    if (result != null) {
      await NutritionStore.saveWaterMl(result);
      await _load();
    }
  }

  String _recommendation() {
    if (_user == null) return 'Crea un perfil para ver recomendaciones.';
    if (_stats.waterMl < (_user!.waterGoalMl * 0.5)) {
      return 'Hoy conviene tomar mas agua. Prueba agregar 1 vaso ahora.';
    }
    if (_stats.fiber < 8) {
      return 'Agrega una fruta, avena o lentejas para subir la fibra.';
    }
    if (_stats.sugar > 45) {
      return 'Baja el azucar: cambia dulces o gaseosa por fruta o agua.';
    }
    if (_stats.calories < (_user!.calorieGoal * 0.45)) {
      return 'Falta energia saludable: prueba arroz con pollo, avena o yogur.';
    }
    return 'Buen avance. Manten platos con fruta, verdura, proteina y agua.';
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final calorieGoal = user?.calorieGoal ?? 1800;
    final waterGoal = user?.waterGoalMl ?? 1500;
    final completedCount = _completedChallenges.length;
    final streak = _challengeProgress?.streak ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyDiet Kids'),
        actions: [
          IconButton(
            tooltip: 'Perfiles',
            icon: const Icon(Icons.groups),
            onPressed: _openProfiles,
          ),
          IconButton(
            tooltip: 'Configuracion',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    darkMode: widget.darkMode,
                    toggleTheme: widget.toggleTheme,
                    user: user,
                    onUserChanged: () {
                      _load();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _WelcomeCard(
                    user: user,
                    onRegister: _openUserForm,
                    onProfiles: _openProfiles,
                  ),
                  const SizedBox(height: 16),
                  _RecommendationCard(text: _recommendation()),
                  const SizedBox(height: 16),
                  const Text(
                    'Resumen del dia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _ProgressCard(
                    icon: Icons.local_fire_department,
                    title: 'Calorias',
                    value:
                        '${_stats.calories.toStringAsFixed(0)} / $calorieGoal kcal',
                    progress: _stats.calories / calorieGoal,
                    color: Colors.orange,
                  ),
                  _ProgressCard(
                    icon: Icons.water_drop,
                    title: 'Agua',
                    value: '${_stats.waterMl} / $waterGoal ml',
                    progress: _stats.waterMl / waterGoal,
                    color: Colors.blue,
                  ),
                  _ProgressCard(
                    icon: Icons.flag,
                    title: 'Retos',
                    value:
                        '$completedCount / ${dailyChallenges.length} completados | Racha $streak',
                    progress: completedCount / dailyChallenges.length,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _ActionCard(
                        icon: Icons.groups,
                        title: 'Perfiles',
                        color: Colors.teal,
                        onTap: _openProfiles,
                      ),
                      _ActionCard(
                        icon: Icons.restaurant,
                        title: 'Registrar comida',
                        color: Colors.orange,
                        onTap: _openFood,
                      ),
                      _ActionCard(
                        icon: Icons.water_drop,
                        title: 'Registrar agua',
                        color: Colors.blue,
                        onTap: _openWater,
                      ),
                      _ActionCard(
                        icon: Icons.emoji_events,
                        title: 'Retos diarios',
                        color: Colors.amber.shade800,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChallengesScreen(),
                            ),
                          );
                          await _load();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                      await _load();
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Ver historial'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final ChildUser? user;
  final VoidCallback onRegister;
  final VoidCallback onProfiles;

  const _WelcomeCard({
    required this.user,
    required this.onRegister,
    required this.onProfiles,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user == null ? 'Bienvenido' : 'Hola, ${user!.name}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user == null
                  ? 'Crea un perfil para calcular metas y recomendaciones.'
                  : '${user!.age} anos | Meta ${user!.calorieGoal} kcal | Agua ${user!.waterGoalMl} ml',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onProfiles,
                  icon: const Icon(Icons.groups),
                  label: const Text('Cambiar perfil'),
                ),
                OutlinedButton.icon(
                  onPressed: onRegister,
                  icon: const Icon(Icons.edit),
                  label: Text(user == null ? 'Crear perfil' : 'Editar datos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String text;

  const _RecommendationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.lightGreen.shade100,
          child: const Icon(Icons.tips_and_updates, color: Colors.green),
        ),
        title: const Text('Recomendacion'),
        subtitle: Text(text),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ProgressCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(36),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    color: color,
                    backgroundColor: color.withAlpha(36),
                  ),
                  const SizedBox(height: 4),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withAlpha(36),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
