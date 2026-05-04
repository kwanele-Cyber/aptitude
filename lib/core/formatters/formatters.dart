class Formatters {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalize).join(' ');
  }

  static String formatDate(DateTime? date, {String format = 'MMM dd, yyyy'}) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final map = <String, String>{
      'yyyy': date.year.toString().padLeft(4, '0'),
      'MMM': months[date.month - 1],
      'MM': date.month.toString().padLeft(2, '0'),
      'dd': date.day.toString().padLeft(2, '0'),
      'HH': date.hour.toString().padLeft(2, '0'),
      'mm': date.minute.toString().padLeft(2, '0'),
    };
    var result = format;
    map.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  static String truncate(String text, int maxLength,
      {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    // Remove non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return phone;
  }
}
