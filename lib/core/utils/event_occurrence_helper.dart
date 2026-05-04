List<DateTime> buildEventOccurrences({
  required String date,
  required String time,
  required String repeat,
  required String repeatEndDate,
}) {
  final startDateTime = _parseDateTime(date: date, time: time);

  if (startDateTime == null) {
    print('❌ No se pudo convertir la fecha/hora del evento: $date $time');
    return [];
  }

  final normalizedRepeat = repeat.trim().toLowerCase();

  if (normalizedRepeat == 'never') {
    return [startDateTime];
  }

  final endDate = _parseDateOnly(repeatEndDate);

  if (endDate == null) {
    print('❌ No se pudo convertir repeatEndDate: $repeatEndDate');
    return [];
  }

  final endDateTime = DateTime(
    endDate.year,
    endDate.month,
    endDate.day,
    23,
    59,
    59,
  );

  if (endDateTime.isBefore(startDateTime)) {
    print('❌ La fecha fin es menor a la fecha inicio');
    return [];
  }

  final occurrences = <DateTime>[];

  DateTime current = startDateTime;

  while (!current.isAfter(endDateTime)) {
    final shouldAdd = _shouldAddOccurrence(
      dateTime: current,
      repeat: normalizedRepeat,
      startDateTime: startDateTime,
    );

    if (shouldAdd) {
      occurrences.add(current);
    }

    current = _nextOccurrence(
      current: current,
      repeat: normalizedRepeat,
    );

    if (occurrences.length >= 500) {
      print(
          '⚠️ Se detuvo la generación de ocurrencias para evitar demasiadas notificaciones');
      break;
    }
  }

  return occurrences;
}

DateTime? _parseDateOnly(String value) {
  if (value.trim().isEmpty) return null;

  final text = value.trim();

  if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(text)) {
    final parts = text.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(text)) {
    return DateTime.tryParse(text);
  }

  return DateTime.tryParse(text);
}

DateTime? _parseDateTime({
  required String date,
  required String time,
}) {
  final parsedDate = _parseDateOnly(date);

  if (parsedDate == null) return null;

  final parsedTime = _parseTime(time);

  return DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    parsedTime.$1,
    parsedTime.$2,
  );
}

(int, int) _parseTime(String value) {
  final text = value.trim().toUpperCase();

  final match24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);

  if (match24 != null) {
    final hour = int.tryParse(match24.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match24.group(2) ?? '') ?? 0;

    return (hour, minute);
  }

  final match12 =
      RegExp(r'^(\d{1,2})(?::(\d{2}))?\s?(AM|PM)$').firstMatch(text);

  if (match12 != null) {
    var hour = int.tryParse(match12.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match12.group(2) ?? '0') ?? 0;
    final period = match12.group(3);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return (hour, minute);
  }

  return (0, 0);
}

bool _shouldAddOccurrence({
  required DateTime dateTime,
  required String repeat,
  required DateTime startDateTime,
}) {
  switch (repeat) {
    case 'hourly':
      return true;

    case 'daily':
      return true;

    case 'weekdays':
      return dateTime.weekday >= DateTime.monday &&
          dateTime.weekday <= DateTime.friday;

    case 'weekends':
      return dateTime.weekday == DateTime.saturday ||
          dateTime.weekday == DateTime.sunday;

    case 'weekly':
      return true;

    case 'biweekly':
      return true;

    case 'monthly':
      return true;

    case 'quarterly':
      return true;

    case 'semiannual':
      return true;

    case 'yearly':
      return true;

    default:
      return false;
  }
}

DateTime _nextOccurrence({
  required DateTime current,
  required String repeat,
}) {
  switch (repeat) {
    case 'hourly':
      return current.add(const Duration(hours: 1));

    case 'daily':
      return current.add(const Duration(days: 1));

    case 'weekdays':
      return current.add(const Duration(days: 1));

    case 'weekends':
      return current.add(const Duration(days: 1));

    case 'weekly':
      return current.add(const Duration(days: 7));

    case 'biweekly':
      return current.add(const Duration(days: 14));

    case 'monthly':
      return DateTime(
        current.year,
        current.month + 1,
        current.day,
        current.hour,
        current.minute,
      );

    case 'quarterly':
      return DateTime(
        current.year,
        current.month + 3,
        current.day,
        current.hour,
        current.minute,
      );

    case 'semiannual':
      return DateTime(
        current.year,
        current.month + 6,
        current.day,
        current.hour,
        current.minute,
      );

    case 'yearly':
      return DateTime(
        current.year + 1,
        current.month,
        current.day,
        current.hour,
        current.minute,
      );

    default:
      return current.add(const Duration(days: 1));
  }
}
