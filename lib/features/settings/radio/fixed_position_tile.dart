import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../../../app/position_service.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/position_sharer.dart';
import '../../../data/settings/position_section.dart';
import '../../../ui/kit/kit.dart';
import 'fixed_position_picker.dart';

/// «Фиксированная позиция». Включение только открывает выбор позиции
/// («с телефона» или «вручную» на карте) — на ноду уходит
/// set_fixed_position уже с выбранными координатами. Выключение —
/// remove_fixed_position после подтверждения.
class FixedPositionTile extends ConsumerStatefulWidget {
  const FixedPositionTile({super.key, required this.cfg});

  final Config_PositionConfig cfg;

  @override
  ConsumerState<FixedPositionTile> createState() => _FixedPositionTileState();
}

class _FixedPositionTileState extends ConsumerState<FixedPositionTile> {
  bool _busy = false;

  /// Включили, но позицию ещё не выбрали: на ноду ничего не уходило.
  /// Флаг без координат прошивка закрепила бы на старой позиции и сразу
  /// разослала её — а следующую рассылку ждать часами.
  bool _pending = false;

  Future<void> _toggle(bool on) async {
    if (on) {
      setState(() => _pending = true);
      return;
    }
    if (!widget.cfg.fixedPosition) {
      setState(() => _pending = false);
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(PositionSection.removeFixedTitle),
        content: const Text(PositionSection.removeFixedText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (yes == true) await _send(() async => null);
  }

  Future<void> _fromPhone() => _send(() async => positionOf(await phoneFix()));

  Future<void> _manual() async {
    final own = ref.read(ownNodeProvider).value;
    final lat = own?.latitude, lon = own?.longitude;
    final fix = await Navigator.of(context).push<Fix>(
      // Назад — только от края: иначе метку вправо не утащить.
      SwipeablePageRoute(
        canOnlySwipeFromEdge: true,
        builder: (_) => FixedPositionPicker(
          initial: lat == null || lon == null ? null : LatLng(lat, lon),
          altitude: own?.altitude,
        ),
      ),
    );
    if (fix == null) return;
    await _send(
      () async =>
          positionOf(fix)..locationSource = Position_LocSource.LOC_MANUAL,
    );
  }

  /// Отправить позицию (null — снять фиксированную).
  Future<void> _send(Future<Position?> Function() position) async {
    setState(() => _busy = true);
    String? error;
    try {
      final ok = await PositionSection.setFixed(
        ref.read(adminSettingsProvider),
        ref.read(databaseProvider),
        widget.cfg,
        await position(),
      );
      if (ok) {
        _pending = false;
      } else {
        error = 'Нода не подтвердила команду';
      }
    } catch (e) {
      error = '$e';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = ref.watch(canSendProvider);
    final fixed = widget.cfg.fixedPosition;
    final on = fixed || _pending;
    final enabled = !_busy && canSend;
    return SectionCard(
      title: PositionSection.fixedLabel,
      children: [
        SwitchListTile(
          title: const Text(PositionSection.fixedLabel),
          subtitle: Text(
            _pending && !fixed
                ? 'Позиция ещё не задана — выберите, откуда её взять'
                : PositionSection.fixedHelp,
          ),
          secondary: _busy
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.push_pin_outlined),
          value: on,
          onChanged: enabled ? _toggle : null,
        ),
        if (on)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.s16,
              0,
              Tokens.s16,
              Tokens.s12,
            ),
            // Друг под другом и одной ширины — по самой широкой.
            child: Center(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: enabled ? _fromPhone : null,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Установить с телефона'),
                    ),
                    const SizedBox(height: Tokens.s8),
                    FilledButton.tonalIcon(
                      onPressed: enabled ? _manual : null,
                      icon: const Icon(Icons.edit_location_alt_outlined),
                      label: const Text('Установить вручную'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
