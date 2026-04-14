import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. تسمية الملف: auth_provider.dart
// 2. مكانه: lib/providers/auth_provider.dart

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<Session?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<Session?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _checkCurrentSession();
  }

  final _supabase = Supabase.instance.client;

  void _checkCurrentSession() {
    final session = _supabase.auth.currentSession;
    state = AsyncValue.data(session);
  }

  // تسجيل الدخول (كما هو)
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      state = AsyncValue.data(response.session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // تحديث دالة SignUp لتشمل حفظ البيانات في جدول الـ profiles
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType, // 'driver' أو 'rider'
  }) async {
    state = const AsyncValue.loading();
    try {
      // أ- إنشاء الحساب في نظام الـ Authentication
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;

      // ب- إذا نجح الإنشاء، نقوم بعمل Insert في جدول profiles فوراً
      if (user != null) {
        await _supabase.from('profiles').insert({
          'id': user.id, // نربطه بـ ID الأوث
          'full_name': fullName,
          'email': email.trim(),
          'user_type': userType,
          'onboarding_completed': false,
        });
      }

      state = AsyncValue.data(response.session);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}