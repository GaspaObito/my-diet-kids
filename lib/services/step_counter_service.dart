import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StepCounterState {
  final bool available;
  final bool permissionGranted;
  final int steps;
  final String message;

  const StepCounterState({
    required this.available,
    required this.permissionGranted,
    required this.steps,
    required this.message,
  });

  factory StepCounterState.unavailable(String message) => StepCounterState(
        available: false,
        permissionGranted: false,
        steps: 0,
        message: message,
      );

  factory StepCounterState.fromMap(Map<dynamic, dynamic> map) =>
      StepCounterState(
        available: map['available'] == true,
        permissionGranted: map['permissionGranted'] == true,
        steps: (map['steps'] as num?)?.toInt() ?? 0,
        message: (map['message'] as String?) ?? '',
      );
}

class StepCounterService {
  static const _method = MethodChannel('mydiet/steps');
  static const _events = EventChannel('mydiet/steps_stream');

  static Future<StepCounterState> startTracking() async {
    if (kIsWeb) {
      return StepCounterState.unavailable(
        'La caminata automatica funciona al instalar la app en Android.',
      );
    }

    try {
      final result = await _method.invokeMapMethod<String, dynamic>(
        'startStepTracking',
      );
      return StepCounterState.fromMap(result ?? const {});
    } on MissingPluginException {
      return StepCounterState.unavailable(
        'El contador de pasos solo esta disponible en Android.',
      );
    } catch (_) {
      return StepCounterState.unavailable(
        'No se pudo iniciar el contador de pasos.',
      );
    }
  }

  static Stream<int> stepsStream() {
    if (kIsWeb) return const Stream<int>.empty();
    return _events.receiveBroadcastStream().map((event) {
      if (event is num) return event.toInt();
      return 0;
    });
  }
}
