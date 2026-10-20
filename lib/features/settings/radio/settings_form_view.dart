import 'package:flutter/material.dart';

import '../../../data/settings/fields.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';

/// Отрисовка полей [SettingsForm] по их описаниям. Только внешний вид:
/// значения, обрезка и проверка — в форме.
class SettingsFormView extends StatelessWidget {
  const SettingsFormView({super.key, required this.form, this.title});

  final SettingsForm form;
  final String? title;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: form,
    builder: (context, _) => Column(
      children: [
        for (final (group, fields) in form.groups)
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
    DoubleFieldSpec(:final min, :final max, :final unit) => MeshTile(
      title: f.label,
      subtitle: f.help,
      trailing: SizedBox(
        width: 140,
        child: _TextInput(
          key: ValueKey(f.key),
          value: _num(form.value<double>(f.key)),
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
    ChoiceFieldSpec() => _ChoiceTile(
      label: f.label,
      help: f.help,
      value: form.value<int>(f.key),
      options: f.choices(form.values),
      onChanged: form.saving ? null : (v) => form.set(f.key, v),
    ),
  };
}

/// Дробное без лишнего «.0».
String _num(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

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
          DropdownButtonFormField<int>(
            initialValue: value,
            key: ValueKey('$label/$value/${options.length}'),
            isExpanded: true,
            decoration: InputDecoration(labelText: label),
            items: [
              for (final o in options)
                DropdownMenuItem(
                  value: o.value,
                  child: Text(o.label, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: onChanged,
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
    required this.onChanged,
  });

  final bool decimal;

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
    decoration: InputDecoration(
      labelText: widget.label,
      errorText: widget.error,
      suffixText: widget.suffix,
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
