import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/constants.dart';
import 'core/network/auth_interceptor.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/domain/usecases/resend_verification.dart';
import 'features/auth/domain/usecases/verify_email.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
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
import 'features/emergency/domain/usecases/get_alerts.dart';
import 'features/emergency/domain/usecases/cancel_sos.dart';
import 'features/emergency/domain/usecases/get_my_active_alert.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';

import 'features/friend_walk/data/datasources/friend_walk_remote_data_source.dart';
import 'features/friend_walk/data/repositories/friend_walk_repository_impl.dart';
import 'features/friend_walk/domain/repositories/friend_walk_repository.dart';
import 'features/friend_walk/domain/usecases/start_walk.dart';
import 'features/friend_walk/domain/usecases/update_location.dart';
import 'features/friend_walk/domain/usecases/end_walk.dart';
import 'features/friend_walk/domain/usecases/get_all_active_walks.dart';
import 'features/friend_walk/presentation/bloc/friend_walk_bloc.dart';
import 'features/admin/presentation/bloc/admin_walks_bloc.dart';

import 'features/campus_compass/data/datasources/campus_compass_remote_data_source.dart';
import 'features/campus_compass/data/repositories/campus_compass_repository_impl.dart';
import 'features/campus_compass/domain/repositories/campus_compass_repository.dart';
import 'features/campus_compass/domain/usecases/send_heartbeat.dart';
import 'features/campus_compass/domain/usecases/get_campus_status.dart';
import 'features/campus_compass/presentation/bloc/campus_compass_bloc.dart';

import 'features/mental_health/data/datasources/mental_health_remote_data_source.dart';
import 'features/mental_health/data/repositories/mental_health_repository_impl.dart';
import 'features/mental_health/domain/repositories/mental_health_repository.dart';
import 'features/mental_health/domain/usecases/get_mental_health_resources.dart';
import 'features/mental_health/domain/usecases/send_chat_to_companion.dart';
import 'features/mental_health/presentation/bloc/mental_health_bloc.dart';
import 'features/mental_health/presentation/bloc/chat/mental_health_chat_bloc.dart';


import 'features/reporting/data/datasources/reporting_remote_data_source.dart';
import 'features/reporting/data/repositories/reporting_repository_impl.dart';
import 'features/reporting/domain/repositories/reporting_repository.dart';
import 'features/reporting/domain/usecases/submit_report.dart';
import 'features/reporting/domain/usecases/get_reports.dart';
import 'features/reporting/presentation/bloc/reporting_bloc.dart';

import 'features/admin/presentation/bloc/admin_sos_bloc.dart';
import 'features/safety_timer/data/datasources/safety_timer_remote_data_source.dart';
import 'features/safety_timer/data/repositories/safety_timer_repository_impl.dart';
import 'features/safety_timer/domain/repositories/safety_timer_repository.dart';
import 'features/safety_timer/domain/usecases/cancel_timer.dart';
import 'features/safety_timer/domain/usecases/set_timer.dart';
import 'features/safety_timer/presentation/bloc/safety_timer_bloc.dart';


final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      login: sl(),
      register: sl(),
      verifyEmail: sl(),
      resendVerification: sl(),
      logout: sl(),
      checkAuthStatus: sl(),
      sessionExpiredStream: sl<AuthInterceptor>().onSessionExpired,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  sl.registerLazySingleton(() => ResendVerification(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl(), secureStorage: sl()),
  );

  //! Features - Chat
  // Bloc
  sl.registerFactory(() => ChatBloc(getMessages: sl(), sendMessage: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  // Repository
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(client: sl()));

  //! Features - Emergency (SOS)
  // Bloc
  sl.registerFactory(() => EmergencyBloc(
        triggerSos: sl(),
        cancelSos: sl(),
        getMyActiveAlert: sl(),
      ));
  // Use cases
  sl.registerLazySingleton(() => TriggerSos(sl()));
  sl.registerLazySingleton(() => CancelSos(sl())); // Added CancelSos
  sl.registerLazySingleton(() => GetMyActiveAlert(sl()));
  sl.registerLazySingleton(() => GetAlerts(sl()));
  // Repository
  sl.registerLazySingleton<EmergencyRepository>(() => EmergencyRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<EmergencyRemoteDataSource>(() => EmergencyRemoteDataSourceImpl(client: sl()));

  //! Features - Friend Walk
  // Bloc
  sl.registerFactory(() => FriendWalkBloc(
        startWalk: sl(),
        updateWalkLocation: sl(),
        endWalk: sl(),
      ));
  // Use cases
  sl.registerLazySingleton(() => StartWalk(sl()));
  sl.registerLazySingleton(() => UpdateWalkLocation(sl()));
  sl.registerLazySingleton(() => EndWalk(sl()));
  sl.registerLazySingleton(() => GetAllActiveWalks(sl()));
  // Repository
  sl.registerLazySingleton<FriendWalkRepository>(() => FriendWalkRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<FriendWalkRemoteDataSource>(() => FriendWalkRemoteDataSourceImpl(client: sl()));

  //! Features - Campus Compass
  // Bloc
  sl.registerFactory(() => CampusCompassBloc(
        sendHeartbeat: sl(),
        getCampusStatus: sl(),
      ));
  // Use cases
  sl.registerLazySingleton(() => SendHeartbeat(sl()));
  sl.registerLazySingleton(() => GetCampusStatus(sl()));
  // Repository
  sl.registerLazySingleton<CampusCompassRepository>(
      () => CampusCompassRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<CampusCompassRemoteDataSource>(
      () => CampusCompassRemoteDataSourceImpl(client: sl()));

  //! Features - Reporting
  // Bloc
  sl.registerFactory(() => ReportingBloc(submitReport: sl(), getReports: sl()));
  // Use cases
  sl.registerLazySingleton(() => SubmitReport(sl()));
  sl.registerLazySingleton(() => GetReports(sl()));
  // Repository
  sl.registerLazySingleton<ReportingRepository>(() => ReportingRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<ReportingRemoteDataSource>(() => ReportingRemoteDataSourceImpl(client: sl()));

  //! Admin Features
  sl.registerFactory(() => AdminWalksBloc(getAllActiveWalks: sl()));
  sl.registerFactory(() => AdminSosBloc(getAlerts: sl()));

  //! Features - Safety Timer
  // Bloc
  sl.registerFactory(() => SafetyTimerBloc(setTimer: sl(), cancelTimer: sl(), triggerSos: sl()));
  // Use cases
  sl.registerLazySingleton(() => SetTimer(sl()));
  sl.registerLazySingleton(() => CancelTimer(sl()));
  // Repository
  sl.registerLazySingleton<SafetyTimerRepository>(() => SafetyTimerRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<SafetyTimerRemoteDataSource>(() => SafetyTimerRemoteDataSourceImpl(client: sl()));

  // Mental Health Feature
  // Bloc
  sl.registerFactory(() => MentalHealthBloc(getResources: sl()));
  sl.registerFactory(() => MentalHealthChatBloc(sendChat: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetMentalHealthResources(sl()));
  sl.registerLazySingleton(() => SendChatToCompanion(sl()));
  // Repository
  sl.registerLazySingleton<MentalHealthRepository>(() => MentalHealthRepositoryImpl(remoteDataSource: sl()));
  // Data sources
  sl.registerLazySingleton<MentalHealthRemoteDataSource>(() => MentalHealthRemoteDataSourceImpl(client: sl()));

  //! Core
  // Secure Storage
  final secureStorage = const FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);

  // Network Client
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));
  sl.registerLazySingleton(() => dio);

  // Interceptor
  // We pass 'dio' instance but handle circularity because 'dio' is already created.
  final authInterceptor = AuthInterceptor(dio, secureStorage);
  sl.registerLazySingleton(() => authInterceptor);
  
  // Add interceptor to dio
  dio.interceptors.add(authInterceptor);
}
