import 'dart:async';

import 'package:flutter/material.dart';

import '../data/challenges.dart';
import '../models/nutrition_models.dart';
import '../services/nutrition_store.dart';
import '../services/step_counter_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  Set<String> _completed = {};
  ChallengeProgress? _progress;
  StreamSubscription<int>? _stepsSubscription;
  int _stepsToday = 0;
  String _stepsMessage = 'Detectando pasos...';
  bool _loading = true;
  bool _shownCongratulations = false;
  bool _autoCompletingWalk = false;

  DailyChallenge? get _walkingChallenge {
    for (final challenge in dailyChallenges) {
      if (challenge.stepGoal != null) return challenge;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
    _startStepCounter();
  }

  @override
  void dispose() {
    _stepsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load({bool keepCongratulationsFlag = false}) async {
    final alreadyShown = _shownCongratulations;
    try {
      final progress = await NutritionStore.loadChallengeProgress(
        dailyChallenges.length,
      ).timeout(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _completed = progress.completedIds;
        _loading = false;
        _shownCongratulations = keepCongratulationsFlag
            ? alreadyShown
            : progress.earnedTodayMedal;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _completed = {};
        _loading = false;
      });
    }
  }

  Future<void> _startStepCounter() async {
    final walking = _walkingChallenge;
    if (walking == null) return;

    final state = await StepCounterService.startTracking();
    if (!mounted) return;
    setState(() {
      _stepsToday = state.steps;
      _stepsMessage = state.message.isEmpty
          ? 'Pasos detectados por el celular.'
          : state.message;
    });
    await _handleSteps(state.steps);

    _stepsSubscription = StepCounterService.stepsStream().listen(
      (steps) {
        _handleSteps(steps);
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _stepsMessage = 'La caminata automatica requiere Android.';
        });
      },
    );
  }

  Future<void> _handleSteps(int steps) async {
    final walking = _walkingChallenge;
    if (walking == null) return;

    if (mounted) {
      setState(() => _stepsToday = steps);
    }

    final goal = walking.stepGoal ?? 0;
    if (goal <= 0 || steps < goal || _completed.contains(walking.id)) return;
    if (_autoCompletingWalk) return;

    _autoCompletingWalk = true;
    await _completeChallenge(walking.id, true);
    _autoCompletingWalk = false;
  }

  Future<void> _toggle(DailyChallenge challenge, bool value) async {
    await _completeChallenge(challenge.id, value);
  }

  Future<void> _completeChallenge(String id, bool value) async {
    final wasAllComplete = _completed.length >= dailyChallenges.length;
    await NutritionStore.toggleChallenge(
      id,
      value,
      totalChallenges: dailyChallenges.length,
    );
    await _load(keepCongratulationsFlag: true);

    final isAllComplete = _completed.length >= dailyChallenges.length;
    if (!wasAllComplete && isAllComplete) {
      _showCongratulations();
    }
  }

  Future<void> _showCongratulations() async {
    if (_shownCongratulations || !mounted) return;
    setState(() => _shownCongratulations = true);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medalla ganada'),
        content: const Text(
          'Felicitaciones! Cumpliste todos los retos del dia de hoy.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Genial'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completed.length;
    final progress = _progress;
    final earnedToday = progress?.earnedTodayMedal ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Retos diarios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(keepCongratulationsFlag: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ChallengeSummaryCard(
                    completedCount: completedCount,
                    totalCount: dailyChallenges.length,
                    earnedToday: earnedToday,
                    streak: progress?.streak ?? 0,
                    bestStreak: progress?.bestStreak ?? 0,
                    totalMedals: progress?.totalMedals ?? 0,
                    touchedDays: progress?.touchedDates.length ?? 0,
                  ),
                  if (earnedToday) ...[
                    const SizedBox(height: 12),
                    const _TodayMedalCard(),
                  ],
                  const SizedBox(height: 12),
                  ...dailyChallenges.map((challenge) {
                    final done = _completed.contains(challenge.id);
                    return _ChallengeTile(
                      challenge: challenge,
                      done: done,
                      stepsToday: _stepsToday,
                      stepsMessage: _stepsMessage,
                      onChanged: (value) => _toggle(challenge, value),
                    );
                  }),
                  const SizedBox(height: 12),
                  _MedalHistoryCard(progress: progress),
                ],
              ),
            ),
    );
  }
}

class _ChallengeSummaryCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final bool earnedToday;
  final int streak;
  final int bestStreak;
  final int totalMedals;
  final int touchedDays;

  const _ChallengeSummaryCard({
    required this.completedCount,
    required this.totalCount,
    required this.earnedToday,
    required this.streak,
    required this.bestStreak,
    required this.totalMedals,
    required this.touchedDays,
  });

  @override
  Widget build(BuildContext context) {
    final value = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Card(
      color: earnedToday ? Colors.green.shade50 : Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  earnedToday ? Icons.workspace_premium : Icons.emoji_events,
                  color: earnedToday ? Colors.green : Colors.orange,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    earnedToday
                        ? 'Medalla del dia ganada'
                        : '$completedCount de $totalCount retos completados',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 10,
              color: earnedToday ? Colors.green : Colors.orange,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.local_fire_department, size: 18),
                  label: Text('Racha $streak dias'),
                ),
                Chip(
                  avatar: const Icon(Icons.trending_up, size: 18),
                  label: Text('Mejor $bestStreak dias'),
                ),
                Chip(
                  avatar: const Icon(Icons.workspace_premium, size: 18),
                  label: Text('$totalMedals medallas'),
                ),
                Chip(
                  avatar: const Icon(Icons.calendar_month, size: 18),
                  label: Text('$touchedDays dias con avance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMedalCard extends StatelessWidget {
  const _TodayMedalCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade700,
      child: const ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.workspace_premium, color: Colors.green),
        ),
        title: Text(
          'Felicitaciones!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Cumpliste todos los retos del dia de hoy.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  final DailyChallenge challenge;
  final bool done;
  final int stepsToday;
  final String stepsMessage;
  final ValueChanged<bool> onChanged;

  const _ChallengeTile({
    required this.challenge,
    required this.done,
    required this.stepsToday,
    required this.stepsMessage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stepGoal = challenge.stepGoal;
    final isWalking = stepGoal != null;
    final stepProgress = isWalking && stepGoal > 0
        ? (stepsToday / stepGoal).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Card(
      child: CheckboxListTile(
        value: done,
        onChanged: (value) => onChanged(value ?? false),
        secondary: CircleAvatar(
          backgroundColor: done ? Colors.green : Colors.grey.shade200,
          child: Icon(
            done
                ? Icons.check
                : isWalking
                    ? Icons.directions_walk
                    : Icons.flag,
            color: done ? Colors.white : Colors.green,
          ),
        ),
        title: Text(
          challenge.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.description),
            const SizedBox(height: 4),
            Text(challenge.reward),
            if (isWalking) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: stepProgress),
              const SizedBox(height: 4),
              Text('$stepsToday de $stepGoal pasos'),
              Text(
                stepsMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MedalHistoryCard extends StatelessWidget {
  final ChallengeProgress? progress;

  const _MedalHistoryCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final medals = (progress?.medalDates.toList() ?? [])..sort();
    final recent = medals.reversed.take(14).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medallas por dia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              const Text('Aun no hay medallas. Completa todos los retos de hoy.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recent
                    .map(
                      (date) => Chip(
                        avatar: const Icon(Icons.workspace_premium, size: 18),
                        label: Text(date),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
