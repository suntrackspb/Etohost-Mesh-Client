import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/diagnostics_providers.dart';
import '../../ui/kit/kit.dart';

/// «Отправить отчёт»: что уходит и чего нет, предпросмотр, комментарий,
/// после отправки — номер отчёта для связи с разработчиком.
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _comment = TextEditingController();
  final _contact = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(reportFlowProvider);
    final configured = ref.watch(reportUploaderProvider) != null;
    final report = flow.report;
    final theme = Theme.of(context);

    if (flow.stage == ReportStage.sent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Отчёт отправлен')),
        body: _SentView(id: flow.reportId!),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Отправить отчёт')),
      body: ListView(
        padding: const EdgeInsets.all(Tokens.s16),
        children: [
          const SectionCard(
            title: 'Что будет отправлено',
            children: [
              _Bullets([
                _Bullet(
                  'Версия приложения, модель телефона, версия ОС, язык '
                  'и часовой пояс',
                ),
                _Bullet(
                  'Своя нода: ID, модель, прошивка, роль, регион, '
                  'пресет, число нод и каналов',
                ),
                _Bullet(
                  'Состояние соединения: способ подключения (имя BLE '
                  'или адрес ноды), попытки и разрывы',
                ),
                _Bullet(
                  'Журнал приложения за последние запуски: события '
                  'соединения, служебные пакеты, лог прошивки ноды, '
                  'ошибки. В журнале есть ID и имена нод из эфира',
                ),
                _Bullet('Ваш комментарий и контакт, если укажете'),
              ]),
            ],
          ),
          const SectionCard(
            title: 'Что НЕ отправляется',
            children: [
              _Bullets([
                _Bullet('Текст сообщений (в журнале — только размер)'),
                _Bullet('Координаты — ни телефона, ни нод'),
                _Bullet('Ключи шифрования, PSK и названия каналов'),
                _Bullet('Адрес и данные зеркала'),
              ]),
            ],
          ),
          SectionCard(
            title: 'Предпросмотр',
            children: [
              if (report == null)
                const Padding(
                  padding: EdgeInsets.all(Tokens.s16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.all(Tokens.s16),
                  child: SelectableText(
                    report.describe(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                MeshTile(
                  title: 'Журнал',
                  subtitle:
                      '${report.logLines} строк, '
                      '${(report.log.length / 1024).toStringAsFixed(0)} КБ',
                  leading: const Icon(Icons.description_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _LogView(log: report.log),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Tokens.s16),
          TextField(
            controller: _comment,
            minLines: 3,
            maxLines: 8,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Что случилось',
              hintText: 'Что делали, что ожидали, что получилось',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Tokens.s8),
          TextField(
            controller: _contact,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Контакт (необязательно)',
              hintText: 'Telegram, почта — если нужен ответ',
              border: OutlineInputBorder(),
            ),
          ),
          if (flow.error != null) ...[
            const SizedBox(height: Tokens.s8),
            Text(
              'Ошибка: ${flow.error}',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          if (!configured) ...[
            const SizedBox(height: Tokens.s8),
            Text(
              'В этой сборке не задан адрес сервера отчётов.',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: Tokens.s16),
          FilledButton.icon(
            onPressed: flow.canSend
                ? () =>
                      flow.send(comment: _comment.text, contact: _contact.text)
                : null,
            icon: flow.stage == ReportStage.sending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<Widget> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Tokens.s8),
    child: Column(children: items),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Tokens.s16,
      vertical: Tokens.s4,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _SentView extends StatelessWidget {
  const _SentView({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: Tokens.s16),
            const Text('Номер отчёта'),
            const SizedBox(height: Tokens.s8),
            SelectableText(
              id,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Tokens.s16),
            const Text(
              'Сообщите этот номер разработчику — по нему он найдёт ваш '
              'отчёт.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Tokens.s16),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Номер скопирован')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Скопировать номер'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Журнал целиком — как он уйдёт на сервер.
class _LogView extends StatelessWidget {
  const _LogView({required this.log});
  final String log;

  @override
  Widget build(BuildContext context) {
    final lines = log.split('\n');
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    return Scaffold(
      appBar: AppBar(title: const Text('Журнал для отчёта')),
      body: ListView.builder(
        padding: const EdgeInsets.all(Tokens.s8),
        itemCount: lines.length,
        itemBuilder: (_, i) => Text(lines[i], style: style),
      ),
    );
  }
}
