import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/link_badge.dart';
import '../../app/providers.dart';
import '../../app/toasts.dart';
import '../../data/database.dart';
import '../../data/message_filter.dart';
import '../../ui/kit/kit.dart';

/// «Фильтр сообщений» (подписи — из ru Meshtastic-Android).
class MessageFilterPage extends ConsumerStatefulWidget {
  const MessageFilterPage({super.key});

  @override
  ConsumerState<MessageFilterPage> createState() => _MessageFilterPageState();
}

class _MessageFilterPageState extends ConsumerState<MessageFilterPage> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _saveWords(List<String> words) => saveSetting(
    ref,
    AppSettingKeys.messageFilterWords,
    encodeStringList(words),
  );

  void _add(List<String> words) {
    final w = _input.text.trim();
    if (w.isEmpty) return;
    if (compileFilterWord(w) == null) {
      toasts.error(context.l10n.invalidRegularExpression_d0b364);
      return;
    }
    _saveWords(addFilterWord(words, w));
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final f = ref.watch(messageFilterProvider).value ?? MessageFilter();
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.messageFilter_cf2a46),
        actions: const [LinkBadge()],
      ),
      body: ListView(
        padding: pagePadding(context),
        children: [
          SectionCard(
            children: [
              SwitchListTile(
                title: Text(context.l10n.filterAllConversations_0c4f61),
                subtitle: Text(
                  context.l10n.hideMessagesMatchingFiltersInEvery_5d3016,
                ),
                value: f.enabled,
                onChanged: (v) =>
                    saveSetting(ref, AppSettingKeys.messageFilterOn, '$v'),
              ),
            ],
          ),
          SectionCard(
            title: context.l10n.filterWords_42f560,
            children: [
              Padding(
                padding: const EdgeInsets.all(Tokens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.messagesContainingTheseWordsWillBe_3bfbda,
                      style: muted,
                    ),
                    const SizedBox(height: Tokens.s12),
                    TextField(
                      controller: _input,
                      decoration: InputDecoration(
                        hintText: context.l10n.wordOrRegexPattern_d88d91,
                        suffixIcon: IconButton(
                          tooltip: context.l10n.add_559a87,
                          icon: const Icon(Icons.add),
                          onPressed: () => _add(f.words),
                        ),
                      ),
                      onSubmitted: (_) => _add(f.words),
                    ),
                    const SizedBox(height: Tokens.s12),
                    if (f.words.isEmpty)
                      Text(
                        context.l10n.noFilterWordsConfigured_f30bc1,
                        style: muted,
                      )
                    else
                      Wrap(
                        spacing: Tokens.s8,
                        runSpacing: Tokens.s4,
                        children: [
                          for (final w in f.words)
                            InputChip(
                              label: Text(w),
                              avatar: w.startsWith(MessageFilter.regexPrefix)
                                  ? const Icon(Icons.code, size: 16)
                                  : null,
                              onDeleted: () => _saveWords([
                                for (final x in f.words)
                                  if (x != w) x,
                              ]),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
