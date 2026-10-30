import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/id_bug_providers.dart';
import '../../../app/providers.dart';
import '../../../app/toasts.dart';
import '../../../data/id_bug.dart';
import '../../../data/node_actions.dart' show nodeIdOf;
import '../../../ui/kit/kit.dart';

/// Описание проблемы для пользователя — по состоянию ноды.
String idBugText(IdBug b) => switch (b) {
  IdBugPending(idFromKey: true) =>
    'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки '
        '«Отправить NodeInfo» в Meshex 0.1.7–0.1.10. ID на этой '
        'прошивке считается из ключа и не сменится, но MAC стоит вернуть.\n\n'
        'Исправление отправит ноде её настоящий MAC. Перезагрузка не нужна, '
        'ничего не потеряется.',
  IdBugPending(:final num, :final mac) =>
    'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки '
        '«Отправить NodeInfo» в Meshex 0.1.7–0.1.10. Пока нода не '
        'перезагружалась, её ID прежний (${nodeIdOf(num)}). При следующей '
        'перезагрузке ID сменится на случайный: другие увидят её как новую '
        'ноду, переписка и избранное у них разделятся.\n\n'
        '${mac != null ? 'Исправление отправит ноде её настоящий MAC. Перезагрузка не нужна, ничего не потеряется.' : 'Настоящий MAC этой ноды неизвестен ни приложению, ни зеркалу. Перезагрузите ноду: если ID сменится, вернитесь сюда — исправление вернёт прежний ID, ничего не потеряется.'}',
  IdBugChanged(:final original, :final current) =>
    'ID ноды сменился с ${nodeIdOf(original)} на ${nodeIdOf(current)} — '
        'из-за ошибки кнопки «Отправить NodeInfo» в Meshex '
        '0.1.7–0.1.10.\n\n'
        'Исправление вернёт ${nodeIdOf(original)}, ключ шифрования сохранится. '
        'Нода перезагрузится, имя приложение вернёт само. Список нод, '
        'избранное и игнор останутся. У других пользователей '
        '${nodeIdOf(current)} какое-то время будет видна отдельной нодой.',
};

const _rebootNote =
    'Если после перезагрузки телефон не подключается к ноде, '
    'перезагрузите её ещё раз.';

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
    // Без MAC ноду до перезагрузки не чиним: сброс стёр бы список нод.
    final canFix = bug is! IdBugPending || soft;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.repairNodeId_47d759)),
      body: ListView(
        padding: pagePadding(context),
        children: [
          if (bug == null)
            SectionCard(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: Text(context.builtIn(_okText())),
                ),
              ],
            )
          else ...[
            SectionCard(
              footer: bug is IdBugChanged ? context.builtIn(_rebootNote) : null,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: Text(context.builtIn(idBugText(bug))),
                ),
              ],
            ),
            if (canFix)
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: const Icon(Icons.healing),
                  label: Text(
                    soft
                        ? context.l10n.repair_9b1c9a
                        : context.l10n.repairAndRestart_0ef1ee,
                  ),
                  onPressed: _busy ? null : () => _fix(bug),
                ),
              ),
            if (_busy) const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  String _okText() {
    final radio = ref.read(radioProvider);
    final me = radio.myNodeNum;
    if (me == null) return context.l10n.connectToYourOwnNode_cefdf1;
    return context.l10n.nodeId_12da33(
      (nodeIdOf(me)).toString(),
      (idOkReason(
        me: me,
        radio: radio.ownUser,
        firmware: radio.metadata?.firmwareVersion,
      )).toString(),
    );
  }

  Future<void> _fix(IdBug bug) async {
    final strings = context.l10n;
    final actions = ref.read(nodeActionsProvider);
    if (bug case IdBugPending(:final mac?, :final idFromKey)) {
      setState(() => _busy = true);
      try {
        await actions.fixIdBugWithMac(mac, idFromKey: idFromKey);
        // Нода пришлёт свою запись заново — проверка пересчитается.
        ref.read(radioProvider).refreshNodes();
        toasts.show(
          strings.repairedTheNodeMacWasSent_4c3760,
          kind: ToastKind.success,
        );
      } catch (e) {
        toasts.show(
          strings.failed_317897((e).toString()),
          kind: ToastKind.error,
        );
      }
      if (mounted) setState(() => _busy = false);
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(strings.repairNodeId_16de55),
        content: Text(strings.theNodeWillClearItsSaved_7eed33),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(strings.cancel_0ec753),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(strings.repair_9b1c9a),
          ),
        ],
      ),
    );
    if (yes != true) return;
    setState(() => _busy = true);
    try {
      final ok = await actions.fixIdBugByReset(bug as IdBugChanged);
      toasts.show(
        ok
            ? strings.theNodeIsRestartingItsName_f432c3
            : strings.theNodeDidNotAcknowledgeThe_e56f57,
        kind: ok ? ToastKind.success : ToastKind.error,
      );
    } catch (e) {
      toasts.show(strings.failed_317897((e).toString()), kind: ToastKind.error);
    }
    if (mounted) setState(() => _busy = false);
  }
}
