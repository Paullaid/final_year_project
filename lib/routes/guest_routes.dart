/// Route names for the unauthenticated [Navigator] stack (see [AuthWrapper]).
abstract final class GuestRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  /// Email/password registration (replaces legacy sign-in route name).
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';

  @Deprecated('Use GuestRoutes.signUp')
  static String get signIn => signUp;
}
