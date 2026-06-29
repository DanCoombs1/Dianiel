import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/utils/date_utils.dart';

void main() {
  test('dayKey formats date as yyyy-MM-dd', () {
    expect(dayKey(DateTime(2026, 7, 4)), '2026-07-04');
  });

  test('isSameDay returns true for same date different times', () {
    expect(isSameDay(DateTime(2026, 7, 4, 9, 0), DateTime(2026, 7, 4, 18, 0)), isTrue);
  });

  test('isSameDay returns false for different dates', () {
    expect(isSameDay(DateTime(2026, 7, 4), DateTime(2026, 7, 5)), isFalse);
  });

  test('dateOnly strips time component', () {
    expect(dateOnly(DateTime(2026, 7, 4, 18, 30)), DateTime(2026, 7, 4));
  });
}
