import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../mirror/mirror_api.dart';
import '../../mirror/mirror_config.dart';
import '../../mirror/mirror_realtime.dart';
import '../../ui/kit/kit.dart';
import '../../app/link_badge.dart';

/// Настройки → Зеркало. По умолчанию выключено и без адреса;
/// включить можно только после успешной проверки адреса.
class MirrorSettingsPage extends ConsumerStatefulWidget {
  const MirrorSettingsPage({super.key});

  @override
  ConsumerState<MirrorSettingsPage> createState() => _MirrorSettingsPageState();
}

class _MirrorSettingsPageState extends ConsumerState<MirrorSettingsPage> {
  final _address = TextEditingController();
  bool _loaded = false;
  bool _checking = false;
  String? _error;
  String? _ok;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  AppDatabase get _db => ref.read(databaseProvider);

  /// Проверить адрес запросом к API и, если это зеркало, сохранить и включить.
  Future<void> _checkAndEnable() async {
    final url = normalizeMirrorUrl(_address.text);
    if (url == null) {
      setState(() => _error = 'Неверный адрес');
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
      _ok = null;
    });
    final api = MirrorApi(url);
    try {
      final count = await api.probe();
      await _db.setSetting(AppSettingKeys.mirrorAddress, _address.text.trim());
      await _db.setSetting(AppSettingKeys.mirrorEnabled, 'true');
      if (mounted) setState(() => _ok = 'Зеркало отвечает, нод: $count');
    } on MirrorApiException catch (e) {
      if (mounted) setState(() => _error = 'Не удалось: $e');
    } finally {
      api.close();
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _disable() =>
      _db.setSetting(AppSettingKeys.mirrorEnabled, 'false');

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(mirrorConfigProvider).value;
    if (cfg != null && !_loaded) {
      _loaded = true;
      _address.text = cfg.address;
    }
    final enabled = cfg?.enabled ?? false;
    final rt = ref.watch(mirrorRealtimeProvider);
    final draft = normalizeMirrorUrl(_address.text);
    final changed = cfg == null || _address.text.trim() != cfg.address;
    final theme = Theme.of(context);
    final hidden = ref.watch(hiddenChannelsProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Зеркало'),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            footer:
                'Адрес сервера зеркала: с него приходят чат и ноды из MQTT. '
                'Пока зеркало выключено, приложение не обращается ни к каким серверам.',
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.public),
                title: const Text('Зеркало'),
                subtitle: Text(enabled ? _stateText(rt) : 'Выключено'),
                value: enabled,
                // Включение — только через проверку адреса.
                onChanged: _checking
                    ? null
                    : (v) => v ? _checkAndEnable() : _disable(),
              ),
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: TextField(
                  controller: _address,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Адрес',
                    // Только подсказка — не значение по умолчанию.
                    hintText: 'm.etohost.ru',
                    errorText: _address.text.trim().isNotEmpty && draft == null
                        ? 'Неверный адрес'
                        : null,
                    helperText: draft == null
                        ? null
                        : 'Будет использован: $draft',
                  ),
                  onChanged: (_) => setState(() {
                    _error = null;
                    _ok = null;
                  }),
                  onSubmitted: (_) => _checkAndEnable(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Tokens.s16,
                  0,
                  Tokens.s16,
                  Tokens.s16,
                ),
                child: Wrap(
                  spacing: Tokens.s12,
                  runSpacing: Tokens.s8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton(
                      onPressed:
                          _checking || draft == null || (enabled && !changed)
                          ? null
                          : _checkAndEnable,
                      child: Text(
                        enabled && changed
                            ? 'Проверить и применить'
                            : 'Проверить и включить',
                      ),
                    ),
                    if (_checking)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (enabled &&
                        rt != null &&
                        rt.state != MirrorState.connected)
                      TextButton(
                        onPressed: rt.reconnectNow,
                        child: const Text('Переподключить'),
                      ),
                  ],
                ),
              ),
              if (_error != null || _ok != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Tokens.s16,
                    0,
                    Tokens.s16,
                    Tokens.s16,
                  ),
                  child: Text(
                    _error ?? _ok!,
                    style: TextStyle(
                      color: _error != null
                          ? theme.colorScheme.error
                          : StatusColors.ok,
                    ),
                  ),
                ),
            ],
          ),
          if (hidden.isNotEmpty) ...[
            const SizedBox(height: Tokens.s16),
            SectionCard(
              footer:
                  'Сообщения скрытых каналов не загружаются из зеркала. '
                  'Вернёте канал — его лента подгрузится снова.',
              children: [
                for (final k in [...hidden]..sort())
                  ListTile(
                    leading: const Icon(Icons.visibility_off_outlined),
                    title: Text(k),
                    trailing: TextButton(
                      onPressed: () => _db.unhideChannel(k),
                      child: const Text('Вернуть'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _stateText(MirrorRealtime? rt) => switch (rt?.state) {
    null || MirrorState.idle => 'Ожидание',
    MirrorState.connecting => 'Подключение…',
    MirrorState.connected => 'На связи',
    MirrorState.waiting => 'Нет связи, повтор через ${rt!.retryIn} с',
  };
}
