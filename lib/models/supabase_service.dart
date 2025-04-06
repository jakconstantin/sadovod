import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _singleton = SupabaseService._internal();

  factory SupabaseService() => _singleton;

  SupabaseService._internal();

  final supabase = Supabase.instance.client;
  User? get currentUser => supabase.auth.currentUser;

  onListenUser(void Function(User?)? doListen) {
    supabase.auth.onAuthStateChange.listen((event) {
      doListen?.call(event.session?.user);
    });
  }

  onLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print(response);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        print('No user found for that email or wrong password.');
      } else {
        print(e.message);
      }
    }
  }

  onRegister({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      print(response);
    } on AuthException catch (e) {
      if (e.message.contains('weak')) {
        print('The password provided is too weak.');
      } else if (e.message.contains('already registered')) {
        print('The account already exists for that email.');
      } else {
        print(e.message);
      }
    } catch (e) {
      print(e);
    }
  }

  logOut() async {
    await supabase.auth.signOut();
  }

  onVerifyEmail() async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: currentUser?.email,
    );
  }
}