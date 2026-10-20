import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/position_service.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/position_sharer.dart';
import '../../../data/settings/position_section.dart';
import '../../../ui/kit/kit.dart';

/// «Фиксированная позиция»: как в iOS, переключение сразу отправляет
/// set/remove_fixed_position после подтверждения, без кнопки «Сохранить».
class FixedPositionTile extends ConsumerStatefulWidget {
  const FixedPositionTile({super.key, required this.cfg});

  final Config_PositionConfig cfg;

  @override
  ConsumerState<FixedPositionTile> createState() => _FixedPositionTileState();
}

class _FixedPositionTileState extends ConsumerState<FixedPositionTile> {
  bool _busy = false;

  Future<void> _toggle(bool on) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          on ? PositionSection.setFixedTitle : PositionSection.removeFixedTitle,
        ),
        content: Text(
          on ? PositionSection.setFixedText : PositionSection.removeFixedText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(on ? 'Устан' : 'Удалить'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => _busy = true);
    String? error;
    try {
      final pos = on ? positionOf(await phoneFix()) : null;
      final ok = await PositionSection.setFixed(
        ref.read(adminSettingsProvider),
        ref.read(databaseProvider),
        widget.cfg,
        pos,
      );
      if (!ok) error = 'Нода не подтвердила команду';
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
    return SectionCard(
      children: [
        SwitchListTile(
          title: const Text(PositionSection.fixedLabel),
          subtitle: const Text(PositionSection.fixedHelp),
          secondary: _busy
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.push_pin_outlined),
          value: fixed,
          onChanged: _busy || !canSend ? null : _toggle,
        ),
      ],
    );
  }
}
