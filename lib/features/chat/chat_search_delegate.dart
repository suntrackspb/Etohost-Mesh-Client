import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../../core/proto/mesh.dart';
import '../../data/database.dart';

/// Поиск по ленте чата. Возвращает выбранное сообщение.
class ChatSearchDelegate extends SearchDelegate<Message?> {
  ChatSearchDelegate({
    required this.search,
    required this.nodes,
    String? searchLabel,
  }) : super(searchFieldLabel: searchLabel);

  final Future<List<Message>> Function(String query) search;
  final Map<int, Node> nodes;

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: context.l10n.clear_98b207,
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
      return Center(child: Text(context.l10n.enterAtLeastCharacters_ffcd3a));
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
        if (list.isEmpty) {
          return Center(child: Text(context.l10n.noResultsFound_1e1b70));
        }
        final now = DateTime.now();
        final muted = Theme.of(context).colorScheme.onSurfaceVariant;
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final m = list[i];
            final n = nodes[m.fromNum];
            final author = m.isOutgoing
                ? context.l10n.you_adb403
                : n?.longName.isNotEmpty == true
                ? n!.longName
                : nodeIdString(m.fromNum);
            final t = m.rxTime;
            final time =
                '${context.dayLabel(t, now)}, ${t.hour.toString().padLeft(2, '0')}:'
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
