import 'dart:convert';

class ChildUser {
  final String id;
  final String name;
  final int age;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final int calorieGoal;
  final int waterGoalMl;

  const ChildUser({
    required this.id,
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.calorieGoal,
    required this.waterGoalMl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'activityLevel': activityLevel,
        'calorieGoal': calorieGoal,
        'waterGoalMl': waterGoalMl,
      };

  factory ChildUser.fromJson(Map<String, dynamic> json) => ChildUser(
        id: (json['id'] as String?) ??
            'user_${(json['name'] as String? ?? 'nino').hashCode.abs()}',
        name: (json['name'] as String?) ?? 'Nino',
        age: ((json['age'] as num?) ?? 8).toInt(),
        weightKg: ((json['weightKg'] as num?) ?? 25).toDouble(),
        heightCm: ((json['heightCm'] as num?) ?? 125).toDouble(),
        activityLevel: (json['activityLevel'] as String?) ?? 'Media',
        calorieGoal: ((json['calorieGoal'] as num?) ?? 1600).toInt(),
        waterGoalMl: ((json['waterGoalMl'] as num?) ?? 1500).toInt(),
      );

  ChildUser copyWith({
    String? id,
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    int? calorieGoal,
    int? waterGoalMl,
  }) =>
      ChildUser(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        activityLevel: activityLevel ?? this.activityLevel,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      );
}

class FoodItem {
  final String name;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double fiber;
  final bool healthy;
  final String message;
  final List<String> betterOptions;

  const FoodItem({
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.healthy,
    required this.message,
    required this.betterOptions,
  });
}

class FoodLog {
  final String foodName;
  final String category;
  final double grams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double fiber;
  final bool healthy;
  final DateTime createdAt;

  const FoodLog({
    required this.foodName,
    required this.category,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.healthy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'category': category,
        'grams': grams,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'sugar': sugar,
        'fiber': fiber,
        'healthy': healthy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FoodLog.fromJson(Map<String, dynamic> json) => FoodLog(
        foodName: (json['foodName'] as String?) ?? 'Alimento',
        category: (json['category'] as String?) ?? 'Otros',
        grams: ((json['grams'] as num?) ?? 0).toDouble(),
        calories: ((json['calories'] as num?) ?? 0).toDouble(),
        protein: ((json['protein'] as num?) ?? 0).toDouble(),
        carbs: ((json['carbs'] as num?) ?? 0).toDouble(),
        fat: ((json['fat'] as num?) ?? 0).toDouble(),
        sugar: ((json['sugar'] as num?) ?? 0).toDouble(),
        fiber: ((json['fiber'] as num?) ?? 0).toDouble(),
        healthy: (json['healthy'] as bool?) ?? false,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.now(),
      );

  String encode() => jsonEncode(toJson());

  static FoodLog decode(String value) =>
      FoodLog.fromJson(jsonDecode(value) as Map<String, dynamic>);
}

class DailyStats {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double fiber;
  final int waterMl;

  const DailyStats({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.waterMl,
  });

  factory DailyStats.empty() => const DailyStats(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugar: 0,
        fiber: 0,
        waterMl: 0,
      );

  DailyStats addFood(FoodLog log) => DailyStats(
        calories: calories + log.calories,
        protein: protein + log.protein,
        carbs: carbs + log.carbs,
        fat: fat + log.fat,
        sugar: sugar + log.sugar,
        fiber: fiber + log.fiber,
        waterMl: waterMl,
      );

  DailyStats copyWith({int? waterMl}) => DailyStats(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        sugar: sugar,
        fiber: fiber,
        waterMl: waterMl ?? this.waterMl,
      );
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String reward;
  final int? stepGoal;
  final bool completed;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    this.stepGoal,
    this.completed = false,
  });

  DailyChallenge copyWith({bool? completed}) => DailyChallenge(
        id: id,
        title: title,
        description: description,
        reward: reward,
        stepGoal: stepGoal,
        completed: completed ?? this.completed,
      );
}

class ChallengeProgress {
  final String dateKey;
  final Set<String> completedIds;
  final Set<String> touchedDates;
  final Set<String> medalDates;
  final int streak;
  final int bestStreak;

  const ChallengeProgress({
    required this.dateKey,
    required this.completedIds,
    required this.touchedDates,
    required this.medalDates,
    required this.streak,
    required this.bestStreak,
  });

  bool get earnedTodayMedal => medalDates.contains(dateKey);
  int get totalMedals => medalDates.length;
}
