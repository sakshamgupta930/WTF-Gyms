class Validators {
  static String? validateNote(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Note cannot be empty';
    }
    if (value.length > 140) {
      return 'Note must be less than 140 characters';
    }
    return null;
  }

  static bool isTimeInPast(DateTime time) {
    return time.isBefore(DateTime.now());
  }
}
