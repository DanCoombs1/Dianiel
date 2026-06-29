import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/repositories/auth_repository.dart';

void main() {
  test('AppAuthUser holds uid and name', () {
    const u = AppAuthUser(uid: 'abc', displayName: 'Diana');
    expect(u.uid, 'abc');
    expect(u.displayName, 'Diana');
  });
}
