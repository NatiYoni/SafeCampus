import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/constants/constants.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/get_messages.dart';
import 'features/chat/domain/usecases/send_message.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/emergency/data/datasources/emergency_remote_data_source.dart';
import 'features/emergency/data/repositories/emergency_repository_impl.dart';
import 'features/emergency/domain/repositories/emergency_repository.dart';
import 'features/emergency/domain/usecases/trigger_sos.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';
import 'features/friend_walk/data/datasources/friend_walk_remote_data_source.dart';
import 'features/friend_walk/data/repositories/friend_walk_repository_impl.dart';
import 'features/friend_walk/domain/repositories/friend_walk_repository.dart';
import 'features/friend_walk/domain/usecases/start_walk.dart';
import 'features/friend_walk/presentation/bloc/friend_walk_bloc.dart';
import 'features/reporting/data/datasources/reporting_remote_data_source.dart';
import 'features/reporting/data/repositories/reporting_repository_impl.dart';
import 'features/reporting/domain/repositories/reporting_repository.dart';
import 'features/reporting/domain/usecases/submit_report.dart';
import 'features/reporting/presentation/bloc/reporting_bloc.dart';
import 'features/safety_timer/data/datasources/safety_timer_remote_data_source.dart';
import 'features/safety_timer/data/repositories/safety_timer_repository_impl.dart';
import 'features/safety_timer/domain/repositories/safety_timer_repository.dart';
import 'features/safety_timer/domain/usecases/cancel_timer.dart';
import 'features/safety_timer/domain/usecases/set_timer.dart';
import 'features/safety_timer/presentation/bloc/safety_timer_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  sl.registerFactory(() => AuthBloc(loginUser: sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: sl()));

  // Features - Emergency
  sl.registerFactory(() => EmergencyBloc(triggerSos: sl()));
  sl.registerLazySingleton(() => TriggerSos(sl()));
  sl.registerLazySingleton<EmergencyRepository>(() => EmergencyRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<EmergencyRemoteDataSource>(() => EmergencyRemoteDataSourceImpl(client: sl()));

  // Features - Friend Walk
  sl.registerFactory(() => FriendWalkBloc(startWalk: sl()));
  sl.registerLazySingleton(() => StartWalk(sl()));
  sl.registerLazySingleton<FriendWalkRepository>(() => FriendWalkRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<FriendWalkRemoteDataSource>(() => FriendWalkRemoteDataSourceImpl(client: sl()));

  // Features - Reporting
  sl.registerFactory(() => ReportingBloc(submitReport: sl()));
  sl.registerLazySingleton(() => SubmitReport(sl()));
  sl.registerLazySingleton<ReportingRepository>(() => ReportingRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReportingRemoteDataSource>(() => ReportingRemoteDataSourceImpl(client: sl()));

  // Features - Safety Timer
  sl.registerFactory(() => SafetyTimerBloc(setTimer: sl(), cancelTimer: sl()));
  sl.registerLazySingleton(() => SetTimer(sl()));
  sl.registerLazySingleton(() => CancelTimer(sl()));
  sl.registerLazySingleton<SafetyTimerRepository>(() => SafetyTimerRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SafetyTimerRemoteDataSource>(() => SafetyTimerRemoteDataSourceImpl(client: sl()));

  // Features - Chat
  sl.registerFactory(() => ChatBloc(sendMessage: sl(), getMessages: sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: sl()));

  // Core
  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options.baseUrl = apiBaseUrl;
    // Add default headers if needed, e.g., Content-Type: application/json
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return dio;
  });
}
