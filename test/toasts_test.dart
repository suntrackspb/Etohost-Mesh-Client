import 'package:meshex/app/toasts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'toastDuration: короткий текст — 3 с, длинный — дольше, не больше 8 с',
    () {
      expect(toastDuration(''), const Duration(seconds: 3));
      expect(toastDuration('a' * 50), const Duration(seconds: 5));
      expect(toastDuration('a' * 500), const Duration(seconds: 8));
    },
  );
}
