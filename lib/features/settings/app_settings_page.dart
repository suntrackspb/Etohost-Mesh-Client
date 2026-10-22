import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/desktop_tray_provider.dart';
import '../../app/notify_providers.dart';
import '../../app/position_service.dart';
import '../../app/providers.dart';
import '../../app/settings_providers.dart';
import '../../core/desktop/desktop_tray.dart';
import '../../core/geo/geo.dart';
import '../../data/database.dart';
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
    final theme = ref.watch(themeModeProvider).value ?? ThemeMode.system;
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
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          SectionCard(
            title: 'Оформление',
            children: [
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Системная'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Светлая'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Тёмная'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {theme},
                  onSelectionChanged: (s) =>
                      save(AppSettingKeys.theme, s.first.name),
                ),
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
            ],
          ),
          SectionCard(
            title: 'Чат',
            children: [
              SwitchListTile(
                title: const Text('Показывать картинки'),
                subtitle: const Text(
                  'Превью ссылок i.jab.su и img.etohost.ru прямо в ленте',
                ),
                value: images,
                onChanged: (v) => save(AppSettingKeys.showImages, '$v'),
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
                trailing: SizedBox(
                  width: 120,
                  child: TextFormField(
                    key: ValueKey(km),
                    initialValue: km.round().toString(),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(suffixText: 'км'),
                    onFieldSubmitted: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n > 0) {
                        save(AppSettingKeys.areaRadiusKm, '$n');
                      }
                    },
                  ),
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
