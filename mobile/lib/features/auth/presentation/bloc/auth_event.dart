part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String universityId;

  const RegisterEvent(this.email, this.password, this.fullName, this.phoneNumber, this.universityId);

  @override
  List<Object> get props => [email, password, fullName, phoneNumber, universityId];
}

class UpdateProfileEvent extends AuthEvent {
  final User user;
  const UpdateProfileEvent(this.user);
    @override
  List<Object> get props => [user];
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  const ChangePasswordEvent(this.oldPassword, this.newPassword);
    @override
  List<Object> get props => [oldPassword, newPassword];
}

class VerifyEmailEvent extends AuthEvent {
  final String email;
  final String code;

  const VerifyEmailEvent(this.email, this.code);

  @override
  List<Object> get props => [email, code];
}

class ResendVerificationEvent extends AuthEvent {
  final String email;

  const ResendVerificationEvent(this.email);

  @override
  List<Object> get props => [email];
}

class LogoutEvent extends AuthEvent {}
