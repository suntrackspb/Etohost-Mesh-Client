import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../data/settings/ringtone.dart';
import '../../../ui/kit/kit.dart';

/// Рингтон RTTTL (как в Android): при открытии запрашивается у ноды,
/// сохраняется своей кнопкой — это отдельная админ-команда.
class RingtoneTile extends ConsumerStatefulWidget {
  const RingtoneTile({super.key});

  @override
  ConsumerState<RingtoneTile> createState() => _RingtoneTileState();
}

class _RingtoneTileState extends ConsumerState<RingtoneTile> {
  final _text = TextEditingController();
  String? _loaded;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Ringtone.request(ref.read(adminSettingsProvider)).catchError((_) => false);
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
      final ok = await Ringtone.save(
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
    final stored = ref.watch(ringtoneProvider).value;
    if (stored != null && stored != _loaded) {
      _loaded = stored;
      _text.text = stored;
    }
    return SectionCard(
      title: Ringtone.label,
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
                    labelText: Ringtone.label,
                    helperText: Ringtone.help,
                    helperMaxLines: 4,
                    errorText: Ringtone.check(_text.text),
                    counterText: '${_text.text.length}/${Ringtone.maxLength}',
                  ),
                ),
                const SizedBox(height: Tokens.s8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed:
                        _saving ||
                            _text.text == (_loaded ?? '') ||
                            Ringtone.check(_text.text) != null
                        ? null
                        : _save,
                    child: const Text('Сохранить рингтон'),
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
