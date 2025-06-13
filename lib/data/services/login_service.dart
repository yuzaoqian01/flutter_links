import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web3_links/main.dart';
import 'package:web3_links/constants/constants.dart';
import 'package:web3_links/utils/app_storage.dart';

Future<AuthResponse> login(String email, String password) async {
  final res = await supabaseClient.auth.signInWithPassword(email: email, password: password);
  if (res.user != null) {
    await AppStorage.setString(StorageKeys.token,res.user.toString());
    return res;
  } else {
    throw Exception('Login failed: user not found');
  }
}