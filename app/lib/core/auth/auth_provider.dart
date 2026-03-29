import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => ref.read(supabaseClientProvider).auth.currentUser,
  );
});
