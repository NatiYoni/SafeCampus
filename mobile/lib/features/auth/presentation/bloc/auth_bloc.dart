import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/resend_verification.dart';
import '../../domain/usecases/verify_email.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/update_profile.dart'; // Add
import '../../domain/usecases/change_password.dart'; // Add

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final VerifyEmail verifyEmail;
  final ResendVerification resendVerification;
  final Logout logout;
  final CheckAuthStatus checkAuthStatus;
  final UpdateProfile updateProfile; // Add
  final ChangePassword changePassword; // Add
  
  StreamSubscription? _sessionExpiredSubscription;

  AuthBloc({
    required this.login,
    required this.register,
    required this.verifyEmail,
    required this.resendVerification,
    required this.logout,
    required this.checkAuthStatus,
    required this.updateProfile, // Add
    required this.changePassword, // Add
    Stream<void>? sessionExpiredStream, // Optional dependency
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<ResendVerificationEvent>(_onResendVerification);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);

    if (sessionExpiredStream != null) {
      _sessionExpiredSubscription = sessionExpiredStream.listen((_) {
        add(LogoutEvent());
      });
    }
  }

  @override
  Future<void> close() {
    _sessionExpiredSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    // Don't emit loading here to avoid screen flicker if possible, or do if needed.
    // emit(AuthLoading()); 
    final result = await checkAuthStatus();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
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

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    // Ideally use current user to avoid wiping out fields if event.user is partial
    // emit(AuthLoading()); // Optional: loading indicator
    final result = await updateProfile(event.user);
    result.fold(
      (failure) => emit(AuthError(failure.message)), 
      (user) => emit(AuthAuthenticated(user)),
    );
  }

    Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<AuthState> emit) async {
    final currentState = state;
    // emit(AuthLoading()); // If we emit loading, UI might flicker or navigate away if routes depend on Authenticated
    
    final result = await changePassword(event.oldPassword, event.newPassword);
    result.fold(
      (failure) {
         // If we allow "Error" state, it replaces "Authenticated". This kicks user out of Dashboard in current routing logic!
         // We should use a side-effect (event stream) or a composite state. 
         // For now, let's keep it risky (Error state) or handle in UI as a separate bloc/provider.
         // Better: emit AuthError, but AuthError usually means "Not Authenticated".
         // Solution: Add an `AuthActionError` or similar that extends Authenticated?
         // Simplest fix for now: Emit AuthError, catch it in listener, then re-emit Authenticated? messy.
         // Let's assume AuthError doesn't log them out immediately unless the Router checks `state is AuthAuthenticated`.
         // Router DOES check `state is AuthAuthenticated`. So AuthError -> Redirect to /login.
         // We must NOT emit AuthError for password failure if we want them to stay logged in.
         // Correct approach: Separate View State or Action State. 
         // Or: emit(AuthPasswordChangeFailure(message, currentUser))
          if (currentState is AuthAuthenticated) {
             emit(AuthPasswordChangeFailure(failure.message, currentState.user));
             // Revert to Authenticated? The UI needs to see the error.
          } else {
             emit(AuthError(failure.message));
          }
      },
      (_) {
        // Force relogin?
        emit(AuthPasswordChangedSuccess()); // UI should navigate to Login
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logout();
    emit(AuthUnauthenticated());
  }
}
