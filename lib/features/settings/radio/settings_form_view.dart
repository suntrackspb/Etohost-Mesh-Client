import 'package:flutter/material.dart';

import '../../../data/settings/fields.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';

/// Отрисовка полей [SettingsForm] по их описаниям. Только внешний вид:
/// значения, обрезка и проверка — в форме.
class SettingsFormView extends StatelessWidget {
  const SettingsFormView({
    super.key,
    required this.form,
    this.title,
    this.after = const {},
  });

  final SettingsForm form;
  final String? title;

  /// Свои блоки сразу после группы с этим заголовком.
  final Map<String, List<Widget>> after;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: form,
    builder: (context, _) => Column(
      children: [
        for (final (group, fields) in form.groups) ...[
          SectionCard(
            title: group ?? title,
            children: [
              for (final f in fields)
                IgnorePointer(
                  ignoring: !f.enabled(form.values),
                  child: Opacity(
                    opacity: f.enabled(form.values) ? 1 : 0.4,
                    child: _field(context, f),
                  ),
                ),
            ],
          ),
          ...?after[group],
        ],
      ],
    ),
  );

  Widget _help(BuildContext context, String? text) => text == null
      ? const SizedBox.shrink()
      : Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        );

  Widget _field(BuildContext context, FieldSpec<Object?> f) => switch (f) {
    TextFieldSpec() => Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s16,
        vertical: Tokens.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TextInput(
            key: ValueKey(f.key),
            label: f.label,
            value: form.value<String>(f.key),
            error: form.error(f.key),
            secure: f.secure,
            onChanged: (v) => form.set(f.key, v),
          ),
          const SizedBox(height: Tokens.s4),
          _help(context, f.help),
        ],
      ),
    ),
    BoolFieldSpec() => SwitchListTile(
      title: Text(f.label),
      subtitle: f.help == null ? null : Text(f.help!),
      value: form.value<bool>(f.key),
      onChanged: form.saving ? null : (v) => form.set(f.key, v),
    ),
    IntFieldSpec(:final min, :final max, :final unit) => MeshTile(
      title: f.label,
      subtitle: f.help,
      trailing: SizedBox(
        width: 120,
        child: _TextInput(
          key: ValueKey(f.key),
          value: '${form.value<int>(f.key)}',
          suffix: unit,
          number: true,
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) form.set(f.key, n.clamp(min, max));
          },
        ),
      ),
    ),
    DoubleFieldSpec(:final min, :final max, :final unit, :final decimals) =>
      MeshTile(
        title: f.label,
        subtitle: f.help,
        trailing: SizedBox(
          width: 140,
          child: _TextInput(
            key: ValueKey(f.key),
            value: _num(form.value<double>(f.key), decimals),
            suffix: unit,
            number: true,
            decimal: true,
            onChanged: (v) {
              final n = double.tryParse(v.replaceAll(',', '.'));
              if (n != null) form.set(f.key, n.clamp(min, max));
            },
          ),
        ),
      ),
    ChoiceFieldSpec(:final helpFor, :final confirmFor) => _ChoiceTile(
      label: f.label,
      help: [
        ?f.help,
        ?helpFor?.call(form.value<int>(f.key)),
      ].join('\n\n').ifEmpty,
      value: form.value<int>(f.key),
      options: f.choices(form.values),
      onChanged: form.saving
          ? null
          : (v) async {
              final warn = v == null ? null : confirmFor?.call(v);
              if (warn != null && !await _confirm(context, warn)) {
                return;
              }
              form.set(f.key, v);
            },
    ),
    PinListFieldSpec() => _PinList(
      spec: f,
      value: form.value<RemotePins>(f.key),
      onChanged: form.saving ? null : (v) => form.set(f.key, v),
    ),
  };
}

extension on String {
  String? get ifEmpty => isEmpty ? null : this;
}

Future<bool> _confirm(BuildContext context, String text) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Вы уверены?'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Подтверждение'),
          ),
        ],
      ),
    ) ==
    true;

/// Дробное без лишнего «.0».
String _num(double v, [int? decimals]) => v == v.roundToDouble()
    ? v.toStringAsFixed(0)
    : decimals != null
    ? v.toStringAsFixed(decimals)
    : '$v';

/// Выбор из списка: подпись и справка сверху, список на всю ширину —
/// длинные названия регионов и пресетов не помещаются справа.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    this.help,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? help;
  final int value;
  final List<Choice> options;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s16,
        vertical: Tokens.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Управляемый список: значение всегда из формы (откат после
          // отказа в подтверждении виден сразу).
          InputDecorator(
            decoration: InputDecoration(labelText: label),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                isDense: true,
                items: [
                  for (final o in options)
                    DropdownMenuItem(
                      value: o.value,
                      child: Text(o.label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
          if (help != null) ...[
            const SizedBox(height: Tokens.s4),
            Text(
              help!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Поле ввода, которое показывает нормализованное значение формы
/// (обрезку по байтам) и не сбрасывает курсор на каждом символе.
class _TextInput extends StatefulWidget {
  const _TextInput({
    super.key,
    this.label,
    required this.value,
    this.error,
    this.suffix,
    this.number = false,
    this.decimal = false,
    this.secure = false,
    required this.onChanged,
  });

  final bool decimal;
  final bool secure;

  final String? label;
  final String value;
  final String? error;
  final String? suffix;
  final bool number;
  final ValueChanged<String> onChanged;

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late final _c = TextEditingController(text: widget.value);
  bool _shown = false;

  @override
  void didUpdateWidget(_TextInput old) {
    super.didUpdateWidget(old);
    // Число: «869.» и «869» — одно значение, ввод не сбрасываем.
    final same =
        widget.number &&
        double.tryParse(_c.text.replaceAll(',', '.')) ==
            double.tryParse(widget.value);
    if (_c.text != widget.value && !same) {
      _c.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    keyboardType: widget.number
        ? TextInputType.numberWithOptions(decimal: widget.decimal)
        : TextInputType.text,
    textAlign: widget.number ? TextAlign.end : TextAlign.start,
    autocorrect: false,
    obscureText: widget.secure && !_shown,
    enableSuggestions: !widget.secure,
    decoration: InputDecoration(
      labelText: widget.label,
      errorText: widget.error,
      suffixText: widget.suffix,
      suffixIcon: widget.secure
          ? IconButton(
              tooltip: _shown ? 'Скрыть' : 'Показать',
              icon: Icon(_shown ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _shown = !_shown),
            )
          : null,
    ),
    onChanged: widget.onChanged,
  );
}

/// Кнопка «Сохранить» с подтверждением, как в iOS.
class SaveBar extends StatelessWidget {
  const SaveBar({
    super.key,
    required this.form,
    required this.confirm,
    this.note,
    required this.onSave,
  });

  final SettingsForm form;
  final String confirm;
  final String? note;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: form,
    builder: (context, _) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (form.formError != null)
          Padding(
            padding: const EdgeInsets.all(Tokens.s8),
            child: Text(
              form.formError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (form.saveError != null)
          Padding(
            padding: const EdgeInsets.all(Tokens.s8),
            child: Text(
              form.saveError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (form.dirty)
          Padding(
            padding: const EdgeInsets.all(Tokens.s16),
            child: FilledButton.icon(
              icon: form.saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: const Text('Сохранить'),
              onPressed: !form.canSave
                  ? null
                  : () async {
                      final yes = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Вы уверены?'),
                          content: Text([confirm, ?note].join('\n\n')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Отмена'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Сохранить'),
                            ),
                          ],
                        ),
                      );
                      if (yes == true) await onSave();
                    },
            ),
          ),
      ],
    ),
  );
}

/// Список пинов: GPIO, имя, тип; «Добавить» до [PinListFieldSpec.maxCount]
/// (как EditListPreference в Android).
class _PinList extends StatelessWidget {
  const _PinList({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final PinListFieldSpec spec;
  final RemotePins value;
  final ValueChanged<RemotePins>? onChanged;

  void _edit(int i, RemotePin p) =>
      onChanged?.call(RemotePins([...value.items]..[i] = p));

  @override
  Widget build(BuildContext context) {
    final items = value.items;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s16,
        vertical: Tokens.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(spec.label, style: Theme.of(context).textTheme.titleSmall),
          for (var i = 0; i < items.length; i++)
            Padding(
              // Ключ по позиции и длине: после удаления поля ввода берут
              // новые значения.
              key: ValueKey('${spec.key}-$i-${items.length}'),
              padding: const EdgeInsets.only(top: Tokens.s8),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: _TextInput(
                      label: 'Контакт GPIO',
                      value: '${items[i].gpio}',
                      number: true,
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _edit(i, (
                            gpio: n,
                            name: items[i].name,
                            type: items[i].type,
                          ));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: Tokens.s8),
                  Expanded(
                    child: _TextInput(
                      label: 'Имя',
                      value: items[i].name,
                      onChanged: (v) => _edit(i, (
                        gpio: items[i].gpio,
                        name: v,
                        type: items[i].type,
                      )),
                    ),
                  ),
                  const SizedBox(width: Tokens.s8),
                  DropdownButton<int>(
                    value: items[i].type,
                    items: [
                      for (final t in spec.types)
                        DropdownMenuItem(value: t.value, child: Text(t.label)),
                    ],
                    onChanged: onChanged == null
                        ? null
                        : (t) => _edit(i, (
                            gpio: items[i].gpio,
                            name: items[i].name,
                            type: t ?? 0,
                          )),
                  ),
                  IconButton(
                    tooltip: 'Удалить',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onChanged == null
                        ? null
                        : () => onChanged!(RemotePins([...items]..removeAt(i))),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Tokens.s8),
          OutlinedButton(
            onPressed: onChanged == null || items.length >= spec.maxCount
                ? null
                : () => onChanged!(
                    RemotePins([...items, (gpio: 0, name: '', type: 0)]),
                  ),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}
