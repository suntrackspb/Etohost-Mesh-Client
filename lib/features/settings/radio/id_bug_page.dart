import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/id_bug_providers.dart';
import '../../../app/providers.dart';
import '../../../app/toasts.dart';
import '../../../data/id_bug.dart';
import '../../../data/node_actions.dart' show nodeIdOf;
import '../../../ui/kit/kit.dart';

/// Описание проблемы для пользователя — по состоянию ноды.
String idBugText(IdBug b) => switch (b) {
  IdBugPending(:final num, :final mac) =>
    'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки '
        '«Отправить NodeInfo» в Etohost Mesh 0.1.10 и раньше. Пока нода не '
        'перезагружалась, её ID прежний (${nodeIdOf(num)}). При следующей '
        'перезагрузке ID сменится на случайный: другие увидят её как новую '
        'ноду, переписка и избранное у них разделятся.\n\n'
        '${mac != null ? 'Исправление отправит ноде её настоящий MAC. Перезагрузка не нужна, ничего не потеряется.' : 'Настоящий MAC этой ноды приложению неизвестен, поэтому нода сбросит сохранённое состояние и перезагрузится. ID и ключ шифрования останутся, имя приложение вернёт само. Список нод соберётся заново, избранное и игнор на самой ноде сбросятся (в приложении останутся).'}',
  IdBugChanged(:final original, :final current) =>
    'ID ноды сменился с ${nodeIdOf(original)} на ${nodeIdOf(current)} — '
        'из-за ошибки кнопки «Отправить NodeInfo» в Etohost Mesh 0.1.10 и '
        'раньше.\n\n'
        'Исправление вернёт ${nodeIdOf(original)}, ключ шифрования сохранится. '
        'Нода сбросит сохранённое состояние и перезагрузится, имя приложение '
        'вернёт само. Список нод соберётся заново, избранное и игнор на самой '
        'ноде сбросятся (в приложении останутся). У других пользователей '
        '${nodeIdOf(current)} какое-то время будет видна отдельной нодой.',
};

const _rebootNote =
    'Если после перезагрузки телефон не подключается к ноде, '
    'перезагрузите её ещё раз.';

/// Красная плашка над всеми экранами, пока подключённую ноду задела ошибка.
class IdBugBanner extends ConsumerWidget {
  const IdBugBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bug = ref.watch(idBugProvider).value;
    if (bug == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final fg = scheme.onErrorContainer;
    final text = switch (bug) {
      IdBugPending() =>
        'Нода сменит ID при перезагрузке. Нажмите, чтобы исправить.',
      IdBugChanged(:final original) =>
        'ID ноды сменился (было ${nodeIdOf(original)}). Нажмите, чтобы исправить.',
    };
    return Material(
      color: scheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: InkWell(
          onTap: () => context.go('/settings/id-fix'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Tokens.s16,
              vertical: Tokens.s12,
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: fg),
                const SizedBox(width: Tokens.s12),
                Expanded(
                  child: Text(text, style: TextStyle(color: fg)),
                ),
                Icon(Icons.chevron_right, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Экран починки ID ноды.
class IdBugPage extends ConsumerStatefulWidget {
  const IdBugPage({super.key});

  @override
  ConsumerState<IdBugPage> createState() => _IdBugPageState();
}

class _IdBugPageState extends ConsumerState<IdBugPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final bug = ref.watch(idBugProvider).value;
    final soft = bug is IdBugPending && bug.mac != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Исправить ID ноды')),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (bug == null)
            const SectionCard(
              children: [
                Padding(
                  padding: EdgeInsets.all(Tokens.s16),
                  child: Text('С ID подключённой ноды всё в порядке.'),
                ),
              ],
            )
          else ...[
            SectionCard(
              footer: soft ? null : _rebootNote,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: Text(idBugText(bug)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.healing),
                label: Text(soft ? 'Исправить' : 'Исправить и перезагрузить'),
                onPressed: _busy ? null : () => _fix(bug),
              ),
            ),
            if (_busy) const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Future<void> _fix(IdBug bug) async {
    final actions = ref.read(nodeActionsProvider);
    if (bug case IdBugPending(:final mac?)) {
      setState(() => _busy = true);
      try {
        await actions.fixIdBugWithMac(mac);
        // Нода пришлёт свою запись заново — проверка пересчитается.
        ref.read(radioProvider).refreshNodes();
        toasts.show(
          'Исправлено: ноде отправлен её MAC',
          kind: ToastKind.success,
        );
      } catch (e) {
        toasts.show('Не удалось: $e', kind: ToastKind.error);
      }
      if (mounted) setState(() => _busy = false);
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Исправить ID ноды?'),
        content: const Text(
          'Нода сбросит сохранённое состояние и перезагрузится. '
          'Ключ шифрования и настройки останутся.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Исправить'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    setState(() => _busy = true);
    try {
      final ok = await actions.fixIdBugByReset();
      toasts.show(
        ok
            ? 'Нода перезагружается. После подключения имя вернётся само.'
            : 'Нода не подтвердила команду',
        kind: ok ? ToastKind.success : ToastKind.error,
      );
    } catch (e) {
      toasts.show('Не удалось: $e', kind: ToastKind.error);
    }
    if (mounted) setState(() => _busy = false);
  }
}
