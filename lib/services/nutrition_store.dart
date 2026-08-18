import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrition_models.dart';

class NutritionStore {
  static const _legacyUserKey = 'child_user';
  static const _usersKey = 'child_users';
  static const _activeUserKey = 'active_child_user_id';
  static const _logsKey = 'food_logs';
  static const _allLogsKey = 'all_food_logs';
  static const _completedChallengesKey = 'completed_challenges';
  static const _challengeDatesKey = 'challenge_dates';
  static const _medalDaysKey = 'challenge_medal_days';
  static const _waterKey = 'water_ml';

  static String get todayKey => dateKey(DateTime.now());

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _dayKey(String base, String userId) =>
      _dayKeyForDate(base, userId, todayKey);

  static String _dayKeyForDate(String base, String userId, String dateKey) =>
      '${base}_${userId}_$dateKey';

  static String _profileKey(String base, String userId) => '${base}_$userId';

  static DateTime? _parseDateKey(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static String _previousDateKey(String value) {
    final date = _parseDateKey(value) ?? DateTime.now();
    return dateKey(date.subtract(const Duration(days: 1)));
  }

  static int _currentStreak(Set<String> medalDates) {
    var cursor = todayKey;
    if (!medalDates.contains(cursor)) {
      cursor = dateKey(DateTime.now().subtract(const Duration(days: 1)));
    }

    var streak = 0;
    while (medalDates.contains(cursor)) {
      streak++;
      cursor = _previousDateKey(cursor);
    }
    return streak;
  }

  static int _bestStreak(Set<String> medalDates) {
    final dates = medalDates
        .map(_parseDateKey)
        .whereType<DateTime>()
        .toList()
      ..sort();
    if (dates.isEmpty) return 0;

    var best = 1;
    var current = 1;
    for (var i = 1; i < dates.length; i++) {
      final difference = dates[i].difference(dates[i - 1]).inDays;
      if (difference == 1) {
        current++;
      } else if (difference > 1) {
        current = 1;
      }
      if (current > best) best = current;
    }
    return best;
  }

  static Future<List<ChildUser>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final users = (prefs.getStringList(_usersKey) ?? [])
        .map((raw) => ChildUser.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();

    if (users.isEmpty) {
      final legacy = prefs.getString(_legacyUserKey);
      if (legacy != null) {
        final user = ChildUser.fromJson(jsonDecode(legacy) as Map<String, dynamic>);
        await prefs.setStringList(_usersKey, [jsonEncode(user.toJson())]);
        await prefs.setString(_activeUserKey, user.id);
        final legacyLogs = prefs.getStringList(_logsKey);
        if (legacyLogs != null) {
          await prefs.setStringList(_dayKey(_logsKey, user.id), legacyLogs);
        }
        final legacyAllLogs = prefs.getStringList(_allLogsKey);
        if (legacyAllLogs != null) {
          await prefs.setStringList(_profileKey(_allLogsKey, user.id), legacyAllLogs);
        }
        final legacyWater = prefs.getInt(_waterKey);
        if (legacyWater != null) {
          await prefs.setInt(_dayKey(_waterKey, user.id), legacyWater);
        }
        final legacyChallenges = prefs.getStringList(_completedChallengesKey);
        if (legacyChallenges != null) {
          await prefs.setStringList(
            _dayKey(_completedChallengesKey, user.id),
            legacyChallenges,
          );
        }
        return [user];
      }
    }

    return users;
  }

  static Future<ChildUser?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final users = await loadUsers();
    if (users.isEmpty) return null;

    final activeId = prefs.getString(_activeUserKey);
    if (activeId != null) {
      for (final user in users) {
        if (user.id == activeId) return user;
      }
    }

    await prefs.setString(_activeUserKey, users.first.id);
    return users.first;
  }

  static Future<void> saveUser(ChildUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await loadUsers();
    final updated = <ChildUser>[];
    var found = false;

    for (final current in users) {
      if (current.id == user.id) {
        updated.add(user);
        found = true;
      } else {
        updated.add(current);
      }
    }

    if (!found) updated.add(user);

    await prefs.setStringList(
      _usersKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
    await prefs.setString(_activeUserKey, user.id);
  }

  static Future<void> setActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, userId);
  }

  static Future<void> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await loadUsers();
    final remaining = users.where((user) => user.id != userId).toList();
    await prefs.setStringList(
      _usersKey,
      remaining.map((item) => jsonEncode(item.toJson())).toList(),
    );

    final activeId = prefs.getString(_activeUserKey);
    if (activeId == userId) {
      if (remaining.isEmpty) {
        await prefs.remove(_activeUserKey);
      } else {
        await prefs.setString(_activeUserKey, remaining.first.id);
      }
    }
  }

  static Future<String> _activeUserIdOrGuest() async {
    final user = await loadUser();
    return user?.id ?? 'guest';
  }

  static Future<List<FoodLog>> loadFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    return (prefs.getStringList(_dayKey(_logsKey, userId)) ?? [])
        .map(FoodLog.decode)
        .toList()
        .reversed
        .toList();
  }

  static Future<void> addFoodLog(FoodLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();

    final todayKey = _dayKey(_logsKey, userId);
    final logs = prefs.getStringList(todayKey) ?? [];
    logs.add(log.encode());
    await prefs.setStringList(todayKey, logs);

    final historyKey = _profileKey(_allLogsKey, userId);
    final allLogs = prefs.getStringList(historyKey) ?? [];
    allLogs.add(log.encode());
    await prefs.setStringList(historyKey, allLogs);
  }

  static Future<List<FoodLog>> loadAllFoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    return (prefs.getStringList(_profileKey(_allLogsKey, userId)) ?? [])
        .map(FoodLog.decode)
        .toList()
        .reversed
        .toList();
  }

  static Future<int> loadWaterMl() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    return prefs.getInt(_dayKey(_waterKey, userId)) ?? 0;
  }

  static Future<void> saveWaterMl(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    await prefs.setInt(_dayKey(_waterKey, userId), value < 0 ? 0 : value);
  }

  static Future<Set<String>> loadCompletedChallenges({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    final key = date == null
        ? _dayKey(_completedChallengesKey, userId)
        : _dayKeyForDate(_completedChallengesKey, userId, dateKey(date));
    return (prefs.getStringList(key) ?? [])
        .toSet();
  }

  static Future<void> toggleChallenge(
    String id,
    bool completed, {
    int totalChallenges = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    final today = todayKey;
    final key = _dayKeyForDate(_completedChallengesKey, userId, today);
    final ids = (prefs.getStringList(key) ?? []).toSet();
    if (completed) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(key, ids.toList());
    await _saveChallengeDayState(prefs, userId, today, ids, totalChallenges);
  }

  static Future<void> _saveChallengeDayState(
    SharedPreferences prefs,
    String userId,
    String date,
    Set<String> completedIds,
    int totalChallenges,
  ) async {
    final datesKey = _profileKey(_challengeDatesKey, userId);
    final dates = (prefs.getStringList(datesKey) ?? []).toSet();
    if (completedIds.isEmpty) {
      dates.remove(date);
    } else {
      dates.add(date);
    }
    await prefs.setStringList(datesKey, dates.toList()..sort());

    final medalKey = _profileKey(_medalDaysKey, userId);
    final medals = (prefs.getStringList(medalKey) ?? []).toSet();
    if (totalChallenges > 0 && completedIds.length >= totalChallenges) {
      medals.add(date);
    } else {
      medals.remove(date);
    }
    await prefs.setStringList(medalKey, medals.toList()..sort());
  }

  static Future<ChallengeProgress> loadChallengeProgress(
    int totalChallenges,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _activeUserIdOrGuest();
    final today = todayKey;
    final completed = (prefs.getStringList(
              _dayKeyForDate(_completedChallengesKey, userId, today),
            ) ??
            [])
        .toSet();

    await _saveChallengeDayState(
      prefs,
      userId,
      today,
      completed,
      totalChallenges,
    );

    final touchedDates =
        (prefs.getStringList(_profileKey(_challengeDatesKey, userId)) ?? [])
            .toSet();
    final medalDates =
        (prefs.getStringList(_profileKey(_medalDaysKey, userId)) ?? []).toSet();

    return ChallengeProgress(
      dateKey: today,
      completedIds: completed,
      touchedDates: touchedDates,
      medalDates: medalDates,
      streak: _currentStreak(medalDates),
      bestStreak: _bestStreak(medalDates),
    );
  }

  static Future<DailyStats> loadDailyStats() async {
    final logs = await loadFoodLogs();
    final water = await loadWaterMl();
    var stats = DailyStats.empty().copyWith(waterMl: water);
    for (final log in logs) {
      stats = stats.addFood(log);
    }
    return stats;
  }
}
