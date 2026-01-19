import 'package:dio/dio.dart';
import '../models/safety_timer_model.dart';
import '../../domain/entities/safety_timer.dart';

abstract class SafetyTimerRemoteDataSource {
  Future<SafetyTimerModel> setTimer(String userId, int durationMinutes, List<String> guardians);
  Future<void> cancelTimer(String timerId);
}

class SafetyTimerRemoteDataSourceImpl implements SafetyTimerRemoteDataSource {
  final Dio client;

  SafetyTimerRemoteDataSourceImpl({required this.client});

  @override
  Future<SafetyTimerModel> setTimer(String userId, int durationMinutes, List<String> guardians) async {
    final response = await client.post(
      '/timers',
      data: {
        'user_id': userId,
        'duration_minutes': durationMinutes,
        'guardians': guardians,
      },
    );
    return SafetyTimerModel.fromJson(response.data);
  }

  @override
  Future<void> cancelTimer(String timerId) async {
    await client.post('/timers/$timerId/cancel');
  }
}
