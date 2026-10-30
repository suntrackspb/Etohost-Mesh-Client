import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/tile_cache.dart';
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
        title: const Text('Приложение'),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            title: 'Оформление',
            children: [
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppTheme>(
                    showSelectedIcon: false,
                    segments: [
                      for (final t in AppTheme.values)
                        ButtonSegment(value: t, label: Text(t.title)),
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
                      'Цвет акцента',
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
                      'Обращения ко мне',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Цвет сообщений с упоминанием или ответом на ваше',
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
              title: 'Ориентация экрана',
              children: [
                for (final o in ScreenOrientation.values)
                  ListTile(
                    title: Text(o.title),
                    subtitle: switch (o) {
                      ScreenOrientation.auto => const Text(
                        'Поворачивается вслед за телефоном',
                      ),
                      ScreenOrientation.portraitDown when Platform.isIOS =>
                        const Text('На iPhone с Face ID не поддерживается'),
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
              title: 'Окно',
              children: [
                SwitchListTile(
                  title: const Text('Сворачивать в трей при закрытии'),
                  subtitle: const Text(
                    'Связь с нодой и уведомления продолжают работать. '
                    'Выключено — крестик закрывает приложение.',
                  ),
                  value: ref.watch(closeToTrayProvider).value ?? true,
                  onChanged: (v) => save(AppSettingKeys.closeToTray, '$v'),
                ),
              ],
            ),
          SectionCard(
            title: 'Уведомления',
            footer:
                'Приходят, пока приложение запущено (в том числе в фоне). '
                'Звук и баннеры — в системных настройках уведомлений.',
            children: [
              alert(
                'Личные сообщения',
                null,
                AppSettingKeys.notifyDirect,
                alerts.direct,
              ),
              alert(
                'Ответы на мои сообщения',
                null,
                AppSettingKeys.notifyReply,
                alerts.reply,
              ),
              alert(
                'Реакции на мои сообщения',
                null,
                AppSettingKeys.notifyReaction,
                alerts.reaction,
              ),
              alert(
                'Упоминания моей ноды',
                myShort.isEmpty
                    ? 'Короткое имя своей ноды в тексте канала'
                    : '«$myShort» в тексте канала',
                AppSettingKeys.notifyMention,
                alerts.mention,
              ),
              alert(
                'Трассировка маршрута',
                'Пришёл ответ на трассировку',
                AppSettingKeys.notifyTraceroute,
                ref.watch(notifyTracerouteProvider).value ?? true,
              ),
            ],
          ),
          SectionCard(
            title: 'Чат',
            children: [
              SwitchListTile(
                title: const Text('Показывать картинки'),
                subtitle: const Text(
                  'Превью ссылок сервиса картинок подключённого сервера '
                  'прямо в ленте',
                ),
                value: images,
                onChanged: (v) => save(AppSettingKeys.showImages, '$v'),
              ),
              SwitchListTile(
                title: const Text('Показывать скрытые сообщения'),
                subtitle: const Text(
                  'Сообщения игнорируемых нод — свёрнутыми, раскрываются '
                  'нажатием. Выключено — их не видно совсем',
                ),
                value: ref.watch(showIgnoredMessagesProvider).value ?? false,
                onChanged: (v) =>
                    save(AppSettingKeys.showIgnoredMessages, '$v'),
              ),
            ],
          ),
          SectionCard(
            title: 'Карта',
            children: [
              SwitchListTile(
                title: const Text('Вращение карты'),
                subtitle: const Text(
                  'Поворот двумя пальцами. Выключено — север всегда сверху.',
                ),
                value: rotate,
                onChanged: (v) => save(AppSettingKeys.mapRotate, '$v'),
              ),
              const _TileCacheTile(),
              const OfflineMapSettings(),
            ],
          ),
          SectionCard(
            title: 'Дальние ноды',
            children: [
              SwitchListTile(
                title: const Text('Скрывать ноды дальше радиуса'),
                subtitle: const Text(
                  'В списке и на карте. Ноды без координат и своя нода '
                  'не скрываются.',
                ),
                value: areaOn,
                onChanged: (v) => save(AppSettingKeys.areaEnabled, '$v'),
              ),
              MeshTile(
                title: 'Радиус',
                trailing: NumberField(
                  value: km.round(),
                  suffix: 'км',
                  width: 120,
                  onSave: (n) {
                    if (n > 0) save(AppSettingKeys.areaRadiusKm, '$n');
                  },
                ),
              ),
              MeshTile(
                title: 'Центр',
                subtitle: center == null
                    ? 'не задан — фильтр не работает'
                    : formatLatLon(center),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/app/area'),
              ),
            ],
          ),
          SectionCard(
            title: 'Позиция телефона',
            children: [
              SwitchListTile(
                title: const Text('Передавать позицию своей ноде'),
                subtitle: const Text(
                  'Для нод без GPS: координаты телефона уходят только своей '
                  'ноде, в сеть их рассылает прошивка по своим настройкам. '
                  'Работает, пока приложение открыто и подключено.',
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
                      const Text('Не чаще чем раз в'),
                      for (final m in positionIntervalOptions)
                        ChoiceChip(
                          label: Text('$m мин'),
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
        ? 'Ждём подключения к ноде'
        : switch (s.status) {
            PositionShareStatus.waiting => 'Ждём координаты',
            PositionShareStatus.active =>
              'Передано ${s.lastSentAt == null ? '' : lastHeardText(s.lastSentAt!)}',
            PositionShareStatus.noPermission =>
              'Нет доступа к геолокации — разрешите в настройках системы',
            PositionShareStatus.serviceOff => 'Геолокация выключена в системе',
            PositionShareStatus.error => 'Ошибка: ${s.error}',
          };
    return MeshTile(title: 'Состояние', subtitle: text);
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
    final title = a?.title ?? 'Без подсветки';
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
            width: 36,
            height: 36,
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
                ? const Icon(Icons.check, color: Colors.white, size: 20)
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
    title: 'Кэш карты',
    subtitle:
        'Просмотренные тайлы, работают без сети. '
        'Занято ${_size == null ? '…' : formatBytes(_size!)} '
        'из ${formatBytes(tileCacheLimitBytes)}.',
    trailing: TextButton(
      onPressed: (_size ?? 0) == 0 ? null : _clear,
      child: const Text('Очистить'),
    ),
  );
}
