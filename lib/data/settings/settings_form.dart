import 'package:flutter/foundation.dart';

import 'fields.dart';

/// Состояние формы: исходные значения, правки, ошибки. Без виджетов —
/// внешний вид можно менять, не трогая логику.
class SettingsForm extends ChangeNotifier {
  SettingsForm(
    this.fields,
    Map<String, Object?> initial, {
    this.adjust,
    this.check,
  }) : _initial = Map.unmodifiable(initial),
       _values = Map.of(initial);

  final List<FieldSpec<Object?>> fields;

  /// Согласовать связанные поля после правки (например, скорость кодирования
  /// при смене пресета). Получает изменяемую копию значений.
  final void Function(Map<String, Object?> v)? adjust;

  /// Ошибка всей формы (недопустимое сочетание значений) или null.
  final String? Function(Map<String, Object?> v)? check;
  Map<String, Object?> _initial;
  final Map<String, Object?> _values;

  bool saving = false;
  String? saveError;

  T value<T>(String key) => _values[key] as T;

  Map<String, Object?> get values => Map.unmodifiable(_values);

  void set(String key, Object? v) {
    final spec = fields.firstWhere((f) => f.key == key);
    _values[key] = spec.normalize(v);
    adjust?.call(_values);
    saveError = null;
    notifyListeners();
  }

  bool get dirty => fields.any((f) => _values[f.key] != _initial[f.key]);

  String? error(String key) {
    final spec = fields.firstWhere((f) => f.key == key);
    return spec.validate(_values[key]);
  }

  /// Ошибка сочетания значений (показывается у кнопки сохранения).
  String? get formError => check?.call(_values);

  bool get valid =>
      formError == null &&
      fields.every(
        (f) => !f.visible(_values) || f.validate(_values[f.key]) == null,
      );

  /// Видимые поля по группам, в порядке описания.
  List<(String?, List<FieldSpec<Object?>>)> get groups {
    final out = <(String?, List<FieldSpec<Object?>>)>[];
    for (final f in fields) {
      if (!f.visible(_values)) continue;
      if (out.isEmpty || out.last.$1 != f.group) out.add((f.group, []));
      out.last.$2.add(f);
    }
    return out;
  }

  bool get canSave => dirty && valid && !saving;

  /// Сохранить через [save] (новые значения и исходные — чтобы отправить
  /// только изменённое); при успехе правки становятся исходными.
  Future<bool> submit(
    Future<bool> Function(Map<String, Object?> v, Map<String, Object?> initial)
    save,
  ) async {
    if (!canSave) return false;
    saving = true;
    saveError = null;
    notifyListeners();
    try {
      final ok = await save(values, _initial);
      if (ok) {
        _initial = Map.unmodifiable(Map.of(_values));
      } else {
        saveError = 'Нода не подтвердила сохранение';
      }
      return ok;
    } catch (e) {
      saveError = '$e';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  /// Пришли новые данные с ноды: обновить исходные, правки пользователя не трогать.
  void reload(Map<String, Object?> fresh) {
    final wasDirty = {
      for (final f in fields)
        if (_values[f.key] != _initial[f.key]) f.key,
    };
    _initial = Map.unmodifiable(fresh);
    for (final f in fields) {
      if (!wasDirty.contains(f.key)) _values[f.key] = fresh[f.key];
    }
    notifyListeners();
  }
}
