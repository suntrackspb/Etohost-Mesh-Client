import 'package:meshex/l10n/l10n.dart';
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
    final strings = context.l10n;
    final url = normalizeMirrorUrl(_address.text);
    if (url == null) {
      setState(() => _error = strings.invalidAddress_e5fb1c);
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
      if (mounted) {
        setState(
          () => _ok = strings.mirrorRespondingNodes_d2a09d((count).toString()),
        );
      }
    } on MirrorApiException catch (e) {
      if (mounted) {
        setState(() => _error = strings.failed_317897((e).toString()));
      }
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
        title: Text(context.l10n.mirror_66ace6),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            footer: context.l10n.mirrorServerAddressChatMessagesAnd_64453e,
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.public),
                title: Text(context.l10n.mirror_66ace6),
                subtitle: Text(
                  enabled ? _stateText(rt) : context.l10n.disabled_d934ae,
                ),
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
                    labelText: context.l10n.address_8db46e,
                    errorText: _address.text.trim().isNotEmpty && draft == null
                        ? context.l10n.invalidAddress_e5fb1c
                        : null,
                    helperText: draft == null
                        ? null
                        : context.l10n.willUse_0a9e87((draft).toString()),
                  ),
                  onChanged: (_) => setState(() {
                    _error = null;
                    _ok = null;
                  }),
                  onSubmitted: (_) => _checkAndEnable(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  Tokens.s16,
                  0,
                  Tokens.s16,
                  Tokens.s16,
                ),
                child: _ServerDisclosure(),
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
                            ? context.l10n.checkAndApply_5b616e
                            : context.l10n.checkAndEnable_38d621,
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
                        child: Text(context.l10n.reconnect_91c240),
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
                    context.builtIn(_error ?? _ok!),
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
              footer: context.l10n.messagesFromHiddenChannelsAreNot_ae5ae7,
              children: [
                for (final k in [...hidden]..sort())
                  ListTile(
                    leading: const Icon(Icons.visibility_off_outlined),
                    title: Text(k),
                    trailing: TextButton(
                      onPressed: () => _db.unhideChannel(k),
                      child: Text(context.l10n.restore_c7aaa9),
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
    null || MirrorState.idle => context.l10n.waiting_5813a9,
    MirrorState.connecting => context.l10n.connecting_40b27e,
    MirrorState.connected => context.l10n.connected_1578f2,
    MirrorState.waiting => context.l10n.disconnectedRetryingInS_c55f01(
      (rt!.retryIn).toString(),
    ),
    MirrorState.outdated =>
      context.l10n.yourApplicationVersionIsOutdatedPlease_d5ccc4,
  };
}

/// Видно до первой проверки адреса: даже она раскрывает IP серверу.
class _ServerDisclosure extends StatelessWidget {
  const _ServerDisclosure();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Tokens.s16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Tokens.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.connectingToACommunityServer_a8bcbd,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: Tokens.s8),
          Text(context.l10n.youChooseTheServerItsOperator_f140c4),
          const SizedBox(height: Tokens.s8),
          Text(context.l10n.whenCheckingAnAddressOrConnecting_ac269f),
          const SizedBox(height: Tokens.s8),
          Text(context.l10n.theServerMayAlsoOfferImage_a319bd),
        ],
      ),
    );
  }
}
