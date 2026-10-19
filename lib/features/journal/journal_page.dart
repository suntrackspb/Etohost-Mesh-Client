import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/radio/journal.dart';
import '../../ui/kit/kit.dart';

/// Журнал соединения — наследник экрана прототипа.
class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  final _scroll = ScrollController();
  bool _follow = true;
  bool _onlyNode = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _ts(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final journal = ref.watch(journalProvider);
    final cs = Theme.of(context).colorScheme;
    final all = journal.lines;
    final lines = _onlyNode
        ? all.where((l) => l.kind == JournalKind.node).toList()
        : all;

    if (_follow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал'),
        actions: [
          IconButton(
            tooltip: 'Копировать',
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: all.map((l) => '${_ts(l.time)} ${l.text}').join('\n'),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Журнал скопирован')),
              );
            },
          ),
          IconButton(
            tooltip: 'Очистить',
            icon: const Icon(Icons.delete_outline),
            onPressed: journal.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                final atEnd =
                    _scroll.position.pixels >=
                    _scroll.position.maxScrollExtent - 24;
                if (_follow != atEnd) setState(() => _follow = atEnd);
                return false;
              },
              child: SelectionArea(
                child: ListView.builder(
                  controller: _scroll,
                  itemCount: lines.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Tokens.s8,
                    vertical: Tokens.s4,
                  ),
                  itemBuilder: (_, i) {
                    final l = lines[i];
                    final color = switch (l.kind) {
                      JournalKind.app => cs.primary,
                      JournalKind.radio => cs.onSurfaceVariant,
                      JournalKind.node => cs.onSurface,
                    };
                    return Text(
                      '${_ts(l.time)} ${l.text}',
                      style: Tokens.mono.copyWith(color: color),
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s8),
              child: Wrap(
                spacing: Tokens.s8,
                children: [
                  FilterChip(
                    label: const Text('Только лог ноды'),
                    selected: _onlyNode,
                    onSelected: (v) => setState(() => _onlyNode = v),
                  ),
                  FilterChip(
                    label: const Text('Следить'),
                    selected: _follow,
                    onSelected: (v) => setState(() => _follow = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
