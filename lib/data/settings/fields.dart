import 'dart:convert';

/// Описание поля формы настроек. Подписи и справка — дословно из
/// Meshtastic-Apple (ru-перевод из Localizable.xcstrings, иначе английский).
sealed class FieldSpec<T> {
  const FieldSpec(
    this.key,
    this.label, {
    this.help,
    this.group,
    this.visibleWhen,
    this.enabledWhen,
  });

  final String key;
  final String label;
  final String? help;

  /// Заголовок группы (секции) формы; поля одной группы идут подряд.
  final String? group;

  /// Показывать поле при текущих значениях формы; null — всегда.
  final bool Function(Map<String, Object?> v)? visibleWhen;

  /// Поле доступно для правки; null — всегда.
  final bool Function(Map<String, Object?> v)? enabledWhen;

  bool visible(Map<String, Object?> v) => visibleWhen?.call(v) ?? true;
  bool enabled(Map<String, Object?> v) => enabledWhen?.call(v) ?? true;

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
    super.group,
    super.visibleWhen,
    super.enabledWhen,
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
  const BoolFieldSpec(
    super.key,
    super.label, {
    super.help,
    super.group,
    super.visibleWhen,
    super.enabledWhen,
  });
}

class IntFieldSpec extends FieldSpec<int> {
  const IntFieldSpec(
    super.key,
    super.label, {
    super.help,
    super.group,
    super.visibleWhen,
    super.enabledWhen,
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
  const ChoiceFieldSpec(
    super.key,
    super.label,
    this.options, {
    super.help,
    super.group,
    super.visibleWhen,
    super.enabledWhen,
    this.optionsFor,
    this.unknownLabel,
    this.helpFor,
    this.confirmFor,
  });

  /// Пояснение к выбранному значению (описание роли и т. п.).
  final String? Function(int value)? helpFor;

  /// Предупреждение, которое нужно подтвердить перед выбором значения.
  final String? Function(int value)? confirmFor;

  final List<Choice> options;

  /// Варианты, зависящие от других полей (пресеты региона и т. п.).
  final List<Choice> Function(Map<String, Object?> v)? optionsFor;

  /// Подпись значения, которого нет среди вариантов.
  final String Function(int value)? unknownLabel;

  /// Варианты при текущих значениях; текущее значение всегда остаётся видно
  /// (как в iOS: иначе непонятно, на чём сейчас нода).
  List<Choice> choices(Map<String, Object?> v) {
    final list = optionsFor?.call(v) ?? options;
    final cur = v[key] as int?;
    if (cur == null || list.any((o) => o.value == cur)) return list;
    return [...list, (value: cur, label: unknownLabel?.call(cur) ?? '$cur')];
  }
}

typedef Choice = ({int value, String label});

/// Дробное число (частота в МГц).
class DoubleFieldSpec extends FieldSpec<double> {
  const DoubleFieldSpec(
    super.key,
    super.label, {
    super.help,
    super.group,
    super.visibleWhen,
    super.enabledWhen,
    required this.min,
    required this.max,
    this.unit,
  });

  final double min;
  final double max;
  final String? unit;

  @override
  double normalize(double value) => value.clamp(min, max);
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
