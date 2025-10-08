import 'package:flutter_test/flutter_test.dart';
import 'package:cholo/core/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    test('initial state', () {
      final auth = AuthProvider();
      expect(auth.user, isNull);
      expect(auth.isLoading, isFalse);
    });
  });
}
