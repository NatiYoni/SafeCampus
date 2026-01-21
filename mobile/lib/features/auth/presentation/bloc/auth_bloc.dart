import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/resend_verification.dart';
import '../../domain/usecases/verify_email.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final VerifyEmail verifyEmail;
  final ResendVerification resendVerification;
  final Logout logout;

  AuthBloc({
    required this.login,
    required this.register,
    required this.verifyEmail,
    required this.resendVerification,
    required this.logout,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationEvent>(_onResendVerification);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await register(event.email, event.password, event.fullName, event.phoneNumber, event.universityId);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(RegistrationSuccess(event.email)),
    );
  }

  Future<void> _onVerifyEmail(VerifyEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyEmail(event.email, event.code);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(VerificationSuccess()),
    );
  }

  Future<void> _onResendVerification(ResendVerificationEvent event, Emitter<AuthState> emit) async {
    // We don't want to change the whole state to Loading because this might happen on the same screen
    // Instead could just show a toast, but here we can just execute the logic.
    // Ideally we might want a different state or handle this in UI with a separate BLoC/Cubit or just future.
    // For simplicity, we just run it and maybe emit error if fail, but keep current state?
    // Let's emit Loading for now.
    emit(AuthLoading());
    final result = await resendVerification(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      // On success, we probably want to go back to "RegistrationSuccess" state or similar to keep the UI there?
      // Or introduce a "CodeSentSuccess" state.
      (_) => emit(RegistrationSuccess(event.email)), // Re-emit success to stay on verification screen
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logout();
    emit(AuthUnauthenticated());
  }
}
