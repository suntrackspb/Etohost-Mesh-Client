import 'dart:convert';

/// Описание поля формы настроек. Подписи и справка — дословно из
/// Meshtastic-Apple (ru-перевод из Localizable.xcstrings, иначе английский).
sealed class FieldSpec<T> {
  const FieldSpec(this.key, this.label, {this.help});

  final String key;
  final String label;
  final String? help;

  /// Ошибка значения или null.
  String? validate(T value) => null;

  /// Привести ввод к допустимому (обрезка, пределы) — как делает iOS при вводе.
  T normalize(T value) => value;
}

class TextFieldSpec extends FieldSpec<String> {
  const TextFieldSpec(
    super.key,
    super.label, {
    super.help,
    required this.maxBytes,
    this.requiredMessage,
  });

  /// Предел в байтах UTF-8 (прошивка режет по байтам).
  final int maxBytes;

  /// Текст ошибки для пустого значения; null — пустое допустимо.
  final String? requiredMessage;

  @override
  String normalize(String value) => trimToBytes(value, maxBytes);

  @override
  String? validate(String value) =>
      requiredMessage != null && value.trim().isEmpty ? requiredMessage : null;
}

class BoolFieldSpec extends FieldSpec<bool> {
  const BoolFieldSpec(super.key, super.label, {super.help});
}

class IntFieldSpec extends FieldSpec<int> {
  const IntFieldSpec(
    super.key,
    super.label, {
    super.help,
    required this.min,
    required this.max,
    this.unit,
  });

  final int min;
  final int max;
  final String? unit;

  @override
  int normalize(int value) => value.clamp(min, max);
}

/// Выбор из списка (перечисления protobuf и фиксированные варианты).
class ChoiceFieldSpec extends FieldSpec<int> {
  const ChoiceFieldSpec(super.key, super.label, this.options, {super.help});

  final List<({int value, String label})> options;
}

/// Обрезать до [maxBytes] UTF-8, не разрывая символ (как NodeNameLimits в iOS).
String trimToBytes(String value, int maxBytes) {
  if (utf8.encode(value).length <= maxBytes) return value;
  final out = StringBuffer();
  var used = 0;
  for (final ch in value.runes.map(String.fromCharCode)) {
    final n = utf8.encode(ch).length;
    if (used + n > maxBytes) break;
    out.write(ch);
    used += n;
  }
  return out.toString();
}
