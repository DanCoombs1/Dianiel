enum EventOwner {
  diana, dan, together;
  bool get isTogether => this == EventOwner.together;
  String get label => switch (this) {
        EventOwner.diana => 'Diana',
        EventOwner.dan => 'Dan',
        EventOwner.together => 'Together',
      };
}

enum ReminderOption {
  none, atTime, tenMin, oneHour, oneDay;
  Duration? get leadTime => switch (this) {
        ReminderOption.none => null,
        ReminderOption.atTime => Duration.zero,
        ReminderOption.tenMin => const Duration(minutes: 10),
        ReminderOption.oneHour => const Duration(hours: 1),
        ReminderOption.oneDay => const Duration(days: 1),
      };
  String get label => switch (this) {
        ReminderOption.none => 'No reminder',
        ReminderOption.atTime => 'At time of event',
        ReminderOption.tenMin => '10 minutes before',
        ReminderOption.oneHour => '1 hour before',
        ReminderOption.oneDay => '1 day before',
      };
}

enum Recurrence {
  none, weekly, monthly, yearly;
  String get label => switch (this) {
        Recurrence.none => 'Does not repeat',
        Recurrence.weekly => 'Weekly',
        Recurrence.monthly => 'Monthly',
        Recurrence.yearly => 'Yearly',
      };
}
