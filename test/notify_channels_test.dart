import 'package:meshex/core/notify/notify_channels.dart';
import 'package:meshex/data/notify/message_alerts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('у каждого вида уведомления — свой канал Android', () {
    expect(notifyChannelFor(AlertKind.direct), NotifyChannel.direct);
    expect(notifyChannelFor(AlertKind.reaction), NotifyChannel.reactions);
    expect(notifyChannelFor(AlertKind.reply), NotifyChannel.replies);
    expect(notifyChannelFor(AlertKind.mention), NotifyChannel.replies);
    final ids = NotifyChannel.values.map((c) => c.id).toSet();
    expect(ids.length, NotifyChannel.values.length);
    expect(ids, isNot(contains(NotifyChannel.legacyId)));
    expect(ids, isNot(contains('connection'))); // фоновая служба
  });
}
