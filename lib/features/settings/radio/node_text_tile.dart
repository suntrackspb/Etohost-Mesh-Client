import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/node_text.dart';
import '../../../ui/kit/kit.dart';

/// Текстовая настройка ноды (рингтон, заготовленные сообщения): при
/// открытии запрашивается у ноды, сохраняется своей кнопкой — это отдельная
/// админ-команда.
class NodeTextTile extends ConsumerStatefulWidget {
  const NodeTextTile(this.spec, {super.key});

  final NodeText spec;

  @override
  ConsumerState<NodeTextTile> createState() => _NodeTextTileState();
}

class _NodeTextTileState extends ConsumerState<NodeTextTile> {
  NodeText get _spec => widget.spec;
  final _text = TextEditingController();
  String? _loaded;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _spec.fetch(ref.read(adminSettingsProvider)).catchError((_) => false);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await _spec.save(
        ref.read(adminSettingsProvider),
        ref.read(databaseProvider),
        _text.text,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(ok ? 'Сохранено' : 'Нода не подтвердила')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stored = ref.watch(nodeTextProvider(_spec.key)).value;
    if (stored != null && stored != _loaded) {
      _loaded = stored;
      _text.text = stored;
    }
    return SectionCard(
      title: _spec.label,
      children: [
        Padding(
          padding: const EdgeInsets.all(Tokens.s16),
          child: ListenableBuilder(
            listenable: _text,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _text,
                  enabled: !_saving,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: _spec.label,
                    helperText: _spec.help,
                    helperMaxLines: 4,
                    errorText: _spec.check(_text.text),
                    counterText: '${_spec.lengthOf(_text.text)}/${_spec.max}',
                  ),
                ),
                const SizedBox(height: Tokens.s8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed:
                        _saving ||
                            _text.text == (_loaded ?? '') ||
                            _spec.check(_text.text) != null
                        ? null
                        : _save,
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
