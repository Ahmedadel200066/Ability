import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_driver_app/presentation/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> login(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final token = await _repository.login(phone, password);
      state = AsyncValue.data(token);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
