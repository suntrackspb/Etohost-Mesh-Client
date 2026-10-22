import 'package:flutter/material.dart';

import '../../core/proto/mesh.dart';
import '../../data/chat_days.dart';
import '../../data/database.dart';

/// Поиск по ленте чата. Возвращает выбранное сообщение.
class ChatSearchDelegate extends SearchDelegate<Message?> {
  ChatSearchDelegate({required this.search, required this.nodes})
    : super(searchFieldLabel: 'Поиск по сообщениям');

  final Future<List<Message>> Function(String query) search;
  final Map<int, Node> nodes;

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Очистить',
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      BackButton(onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final q = query.trim();
    if (q.length < 2) {
      return const Center(child: Text('Введите хотя бы 2 символа'));
    }
    return FutureBuilder<List<Message>>(
      // Ключ — запрос: новый ввод — новый поиск.
      key: ValueKey(q),
      future: search(q),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) return const Center(child: Text('Ничего не найдено'));
        final now = DateTime.now();
        final muted = Theme.of(context).colorScheme.onSurfaceVariant;
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final m = list[i];
            final n = nodes[m.fromNum];
            final author = m.isOutgoing
                ? 'Вы'
                : n?.longName.isNotEmpty == true
                ? n!.longName
                : nodeIdString(m.fromNum);
            final t = m.rxTime;
            final time =
                '${dayLabel(t, now)}, ${t.hour.toString().padLeft(2, '0')}:'
                '${t.minute.toString().padLeft(2, '0')}';
            return ListTile(
              title: Text(m.body, maxLines: 3, overflow: TextOverflow.ellipsis),
              subtitle: Text('$author · $time', style: TextStyle(color: muted)),
              onTap: () => close(context, m),
            );
          },
        );
      },
    );
  }
}
