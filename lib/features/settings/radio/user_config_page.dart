import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../core/proto/mesh.dart';
import '../../../data/settings/settings_form.dart';
import '../../../data/settings/user_section.dart';
import '../../../ui/kit/kit.dart';
import 'settings_form_view.dart';
import '../../../app/link_badge.dart';

/// Настройки пользователя своей ноды.
class UserConfigPage extends ConsumerStatefulWidget {
  const UserConfigPage({super.key});

  @override
  ConsumerState<UserConfigPage> createState() => _UserConfigPageState();
}

class _UserConfigPageState extends ConsumerState<UserConfigPage> {
  SettingsForm? _form;

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(radioProvider.select((r) => r.myNodeNum));
    final nodeAsync = ref.watch(ownNodeProvider);
    final deviceAsync = ref.watch(ownDeviceProvider);
    // Конфиг статуса не обязателен: нет его (или ошибка) — поле просто скрыто.
    final status = ref.watch(moduleConfigProvider('statusmessage'));
    final canSend = ref.watch(canSendProvider);
    final node = nodeAsync.value;
    final device = deviceAsync.value;

    Widget body;
    final problem = me == null
        ? context.l10n.connectToYourOwnNode_d2f276
        : nodeAsync.hasError
        ? context.l10n.couldNotReadOwnNode_d29415((nodeAsync.error).toString())
        : deviceAsync.hasError
        ? context.l10n.couldNotReadFirmwareDetails_b21e3e(
            (deviceAsync.error).toString(),
          )
        : node == null && !nodeAsync.isLoading
        ? context.l10n.ownNodeHasNotLoadedYet_0d7292(
            (nodeIdString(me)).toString(),
          )
        : null;
    if (problem != null) {
      body = EmptyState(icon: Icons.link_off, text: problem);
    } else if (node == null || device == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final statusCfg = status.value;
      final withStatus = UserSection.supportsStatusMessage(
        device.firmware,
        device.metadata,
        statusCfg != null,
      );
      final data = UserSection.read(
        node,
        statusMessage: withStatus ? statusCfg!.statusmessage.nodeStatus : null,
      );
      final form = _form ??= SettingsForm(
        UserSection.fields(device.firmware, statusMessage: withStatus),
        data,
      );
      // Нода прислала новое (после сохранения/перезагрузки) — правки не трогаем.
      if (!mapEquals(form.values, data) && !form.dirty && !form.saving) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) form.reload(data);
        });
      }

      body = ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            children: [
              MeshTile(
                title: context.l10n.nodeId_021568,
                subtitle: nodeIdString(node.num),
              ),
              MeshTile(
                title: context.l10n.hardwareModel_feb4d1,
                subtitle:
                    HardwareModel.valueOf(node.hwModel)?.name ??
                    '${node.hwModel}',
              ),
            ],
          ),
          AbsorbPointer(
            absorbing: !canSend,
            child: SettingsFormView(form: form, title: UserSection.header),
          ),
          SaveBar(
            form: form,
            confirm: context
                .builtIn(UserSection.saveConfirm)
                .replaceFirst(
                  '%s',
                  node.longName.isEmpty
                      ? nodeIdString(node.num)
                      : node.longName,
                ),
            note: UserSection.rebootNote,
            onSave: () async {
              final admin = ref.read(adminSettingsProvider);
              final db = ref.read(databaseProvider);
              await form.submit(
                (v, initial) =>
                    UserSection.save(admin, db, node.num, v, initial: initial),
              );
            },
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.builtIn(UserSection.title)),
        actions: const [LinkBadge()],
      ),
      body: body,
    );
  }
}
