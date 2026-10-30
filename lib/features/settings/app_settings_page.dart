import 'package:meshex/l10n/l10n.dart';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/tile_cache.dart';
import '../../app/locale_provider.dart';
import '../map/map_tiles.dart';
import '../map/offline/offline_map_widgets.dart';
import '../../app/desktop_tray_provider.dart';
import '../../app/notify_providers.dart';
import '../../app/position_service.dart';
import '../../app/providers.dart';
import '../../app/settings_providers.dart';
import '../../core/desktop/desktop_tray.dart';
import '../../core/geo/geo.dart';
import '../../data/appearance.dart';
import '../../data/database.dart';
import '../../data/screen_orientation.dart';
import '../../data/notify/message_alerts.dart';
import '../../data/position_sharer.dart';
import '../../ui/kit/kit.dart';
import '../nodes/nodes_page.dart';
import '../../app/link_badge.dart';

/// Настройки приложения: карта, дальние ноды, позиция телефона.
class AppSettingsPage extends ConsumerWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider).value ?? AppTheme.system;
    final accent = ref.watch(accentProvider).value ?? accents.first;
    final orientation =
        ref.watch(screenOrientationProvider).value ?? ScreenOrientation.auto;
    final mentionAv = ref.watch(mentionColorProvider);
    final mention = mentionAv.hasValue
        ? mentionAv.value
        : parseMentionColor(null);
    final rotate = ref.watch(mapRotateProvider).value ?? false;
    final images = ref.watch(showImagesProvider).value ?? true;
    final areaOn = ref.watch(areaEnabledProvider).value ?? false;
    final km = ref.watch(areaRadiusProvider).value ?? defaultAreaRadiusKm;
    final center = ref.watch(areaCenterProvider).value;
    final share = ref.watch(positionShareProvider).value ?? false;
    final interval =
        ref.watch(positionIntervalProvider).value ?? defaultPositionIntervalMin;
    final alerts =
        ref.watch(alertSettingsProvider).value ?? const AlertSettings();
    final myShort = ref.watch(ownNodeProvider).value?.shortName ?? '';
    void save(String k, String v) => saveSetting(ref, k, v);
    Widget alert(String title, String? sub, String key, bool v) =>
        SwitchListTile(
          title: Text(title),
          subtitle: sub == null ? null : Text(sub),
          value: v,
          onChanged: (on) {
            save(key, '$on');
            if (on) ref.read(localNotifierProvider).requestPermission();
          },
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.app_f9886c),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: context.l10n.language,
            children: [
              for (final (code, title) in [
                ('system', context.l10n.systemLanguage),
                for (final locale in AppLocalizations.supportedLocales)
                  (
                    locale.languageCode,
                    appLanguageNames[locale.languageCode] ??
                        locale.languageCode,
                  ),
              ])
                ListTile(
                  title: Text(title),
                  selected:
                      (ref.watch(appLocaleProvider).value?.languageCode ??
                          'system') ==
                      code,
                  trailing:
                      (ref.watch(appLocaleProvider).value?.languageCode ??
                              'system') ==
                          code
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => save(AppSettingKeys.locale, code),
                ),
            ],
          ),
          SectionCard(
            title: context.l10n.appearance_d206f1,
            children: [
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppTheme>(
                    showSelectedIcon: false,
                    segments: [
                      for (final t in AppTheme.values)
                        ButtonSegment(
                          value: t,
                          label: Text(context.builtIn(t.title)),
                        ),
                    ],
                    selected: {theme},
                    onSelectionChanged: (s) =>
                        save(AppSettingKeys.theme, s.first.name),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Tokens.s16,
                  0,
                  Tokens.s16,
                  Tokens.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.accentColor_ff9b5d,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Tokens.s8),
                    Wrap(
                      spacing: Tokens.s8,
                      runSpacing: Tokens.s8,
                      children: [
                        for (final a in accents)
                          _AccentDot(
                            accent: a,
                            selected: a.id == accent.id,
                            onTap: () => save(AppSettingKeys.accent, a.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: Tokens.s16),
                    Text(
                      context.l10n.mentionsAndReplies_209ee7,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      context.l10n.colorOfMessagesMentioningOrReplying_a39b9c,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Tokens.s8),
                    Wrap(
                      spacing: Tokens.s8,
                      runSpacing: Tokens.s8,
                      children: [
                        for (final a in accents)
                          _AccentDot(
                            accent: a,
                            selected: a.id == mention?.id,
                            onTap: () =>
                                save(AppSettingKeys.mentionColor, a.id),
                          ),
                        _AccentDot(
                          selected: mention == null,
                          onTap: () =>
                              save(AppSettingKeys.mentionColor, mentionOff),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (orientationSupported)
            SectionCard(
              title: context.l10n.screenOrientation_87b383,
              children: [
                for (final o in ScreenOrientation.values)
                  ListTile(
                    title: Text(context.builtIn(o.title)),
                    subtitle: switch (o) {
                      ScreenOrientation.auto => Text(
                        context.l10n.rotatesWithThePhone_3acc7b,
                      ),
                      ScreenOrientation.portraitDown when Platform.isIOS =>
                        Text(context.l10n.notSupportedOnIphonesWithFace_7d312d),
                      _ => null,
                    },
                    trailing: o == orientation
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => save(AppSettingKeys.orientation, o.name),
                  ),
              ],
            ),
          if (DesktopTray.supported)
            SectionCard(
              title: context.l10n.window_f5988f,
              children: [
                SwitchListTile(
                  title: Text(context.l10n.minimizeToTrayOnClose_720ae8),
                  subtitle: Text(
                    context.l10n.theNodeConnectionAndNotificationsKeep_155e05,
                  ),
                  value: ref.watch(closeToTrayProvider).value ?? true,
                  onChanged: (v) => save(AppSettingKeys.closeToTray, '$v'),
                ),
              ],
            ),
          SectionCard(
            title: context.l10n.notifications_ee3c35,
            footer: context.l10n.deliveredWhileTheApplicationIsRunning_ef1ca3,
            children: [
              alert(
                context.l10n.directMessages_6955f3,
                null,
                AppSettingKeys.notifyDirect,
                alerts.direct,
              ),
              alert(
                context.l10n.repliesToMyMessages_2fca62,
                null,
                AppSettingKeys.notifyReply,
                alerts.reply,
              ),
              alert(
                context.l10n.reactionsToMyMessages_3250d9,
                null,
                AppSettingKeys.notifyReaction,
                alerts.reaction,
              ),
              alert(
                context.l10n.mentionsOfMyNode_dfdc0f,
                myShort.isEmpty
                    ? context.l10n.yourNodeShortNameInChannel_7ab080
                    : context.l10n.inChannelMessages_74052f(
                        (myShort).toString(),
                      ),
                AppSettingKeys.notifyMention,
                alerts.mention,
              ),
              alert(
                context.l10n.traceRoute_c2e3ed,
                context.l10n.tracerouteResponseReceived_2f2fbf,
                AppSettingKeys.notifyTraceroute,
                ref.watch(notifyTracerouteProvider).value ?? true,
              ),
            ],
          ),
          SectionCard(
            title: context.l10n.chat_8c77e4,
            children: [
              SwitchListTile(
                title: Text(context.l10n.showImages_436fda),
                subtitle: Text(
                  context.l10n.showPreviewsOfImageServiceLinks_92d5b2,
                ),
                value: images,
                onChanged: (v) => save(AppSettingKeys.showImages, '$v'),
              ),
              SwitchListTile(
                title: Text(context.l10n.showHiddenMessages_4e0ac3),
                subtitle: Text(
                  context.l10n.messagesFromIgnoredNodesAreCollapsed_379dd7,
                ),
                value: ref.watch(showIgnoredMessagesProvider).value ?? false,
                onChanged: (v) =>
                    save(AppSettingKeys.showIgnoredMessages, '$v'),
              ),
            ],
          ),
          SectionCard(
            title: context.l10n.map_5736d0,
            children: [
              SwitchListTile(
                title: Text(context.l10n.mapRotation_8a6270),
                subtitle: Text(
                  context.l10n.rotateWithTwoFingersWhenDisabled_194ca1,
                ),
                value: rotate,
                onChanged: (v) => save(AppSettingKeys.mapRotate, '$v'),
              ),
              const _TileCacheTile(),
              const OfflineMapSettings(),
            ],
          ),
          SectionCard(
            title: context.l10n.distantNodes_c51034,
            children: [
              SwitchListTile(
                title: Text(context.l10n.hideNodesBeyondTheRadius_93e947),
                subtitle: Text(context.l10n.appliesToTheNodeListAnd_f9af88),
                value: areaOn,
                onChanged: (v) => save(AppSettingKeys.areaEnabled, '$v'),
              ),
              MeshTile(
                title: context.l10n.radius_3dfacb,
                trailing: NumberField(
                  value: km.round(),
                  suffix: context.l10n.km_3ced3a,
                  width: 120,
                  onSave: (n) {
                    if (n > 0) save(AppSettingKeys.areaRadiusKm, '$n');
                  },
                ),
              ),
              MeshTile(
                title: context.l10n.center_05b1c1,
                subtitle: center == null
                    ? context.l10n.notSetTheFilterIsInactive_8aa65f
                    : formatLatLon(center),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/app/area'),
              ),
            ],
          ),
          SectionCard(
            title: context.l10n.phonePosition_68a6a2,
            children: [
              SwitchListTile(
                title: Text(context.l10n.sharePositionWithMyNode_acf46e),
                subtitle: Text(
                  context.l10n.forNodesWithoutGpsPhoneCoordinates_e96e7e,
                ),
                value: share,
                onChanged: (v) => save(AppSettingKeys.positionShare, '$v'),
              ),
              if (share) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tokens.s16,
                    vertical: Tokens.s8,
                  ),
                  child: Wrap(
                    spacing: Tokens.s8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(context.l10n.noMoreOftenThanEvery_3389cd),
                      for (final m in positionIntervalOptions)
                        ChoiceChip(
                          label: Text(context.l10n.min_c284de((m).toString())),
                          selected: interval == m,
                          onSelected: (_) =>
                              save(AppSettingKeys.positionIntervalMin, '$m'),
                        ),
                    ],
                  ),
                ),
                const _ShareStatus(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareStatus extends ConsumerWidget {
  const _ShareStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(positionServiceProvider);
    final text = s == null
        ? context.l10n.waitingForANodeConnection_617dba
        : switch (s.status) {
            PositionShareStatus.waiting =>
              context.l10n.waitingForCoordinates_8cafb9,
            PositionShareStatus.active => context.l10n.sent_c9f056(
              (s.lastSentAt == null
                      ? ''
                      : context.builtIn(lastHeardText(s.lastSentAt!)))
                  .toString(),
            ),
            PositionShareStatus.noPermission =>
              context.l10n.locationAccessDeniedAllowItIn_fa90c3,
            PositionShareStatus.serviceOff =>
              context.l10n.locationServicesAreDisabled_34928e,
            PositionShareStatus.error => context.l10n.error_8f7267(
              (s.error).toString(),
            ),
          };
    return MeshTile(title: context.l10n.status_81e4bb, subtitle: text);
  }
}

/// Кружок цвета; выбранный — с галочкой. Без [accent] — «без подсветки».
class _AccentDot extends StatelessWidget {
  const _AccentDot({this.accent, required this.selected, required this.onTap});

  final Accent? accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = accent;
    final scheme = Theme.of(context).colorScheme;
    final title =
        (a == null ? null : context.builtIn(a.title)) ??
        context.l10n.noHighlight_14736b;
    return Tooltip(
      message: title,
      child: Semantics(
        button: true,
        selected: selected,
        label: title,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: a?.color,
              shape: BoxShape.circle,
              border: selected || a == null
                  ? Border.all(
                      color: selected ? scheme.onSurface : scheme.outline,
                      width: selected ? 2 : 1,
                    )
                  : null,
            ),
            child: a == null
                ? Icon(Icons.block, color: scheme.onSurfaceVariant, size: 20)
                : selected
                ? Icon(
                    Icons.check,
                    color:
                        ThemeData.estimateBrightnessForColor(a.color) ==
                            Brightness.light
                        ? const Color(0xFF191D24)
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Размер кэша просмотренных тайлов и его очистка.
class _TileCacheTile extends ConsumerStatefulWidget {
  const _TileCacheTile();

  @override
  ConsumerState<_TileCacheTile> createState() => _TileCacheTileState();
}

class _TileCacheTileState extends ConsumerState<_TileCacheTile> {
  int? _size;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  Future<void> _measure() async {
    final dir = await ref.read(tileCacheDirProvider.future);
    if (mounted) setState(() => _size = tileCacheSize(dir));
  }

  Future<void> _clear() async {
    final dir = await ref.read(tileCacheDirProvider.future);
    if (dir.existsSync()) await dir.delete(recursive: true);
    ref
      ..invalidate(tileProviderProvider)
      ..invalidate(cartoTileProviderProvider);
    await _measure();
  }

  @override
  Widget build(BuildContext context) => MeshTile(
    title: context.l10n.mapCache_fc6703,
    subtitle: context.l10n.viewedTilesAreAvailableOfflineUsing_f4b74a(
      (_size == null ? '…' : context.builtIn(formatBytes(_size!))).toString(),
      (context.builtIn(formatBytes(tileCacheLimitBytes))).toString(),
    ),
    trailing: TextButton(
      onPressed: (_size ?? 0) == 0 ? null : _clear,
      child: Text(context.l10n.clear_98b207),
    ),
  );
}
