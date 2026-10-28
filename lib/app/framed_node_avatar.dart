import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/kit/framed_avatar.dart';
import '../ui/kit/kit.dart';
import 'providers.dart';

/// [NodeAvatar] с рамкой из зеркала (топ болтливых или рамка из админки).
/// Зеркало выключено или рамки нет — обычный аватар.
class FramedNodeAvatar extends ConsumerWidget {
  const FramedNodeAvatar({
    super.key,
    required this.nodeNum,
    this.shortName,
    this.size = 40,
  });

  final int nodeNum;
  final String? shortName;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decor = ref.watch(
      avatarFramesProvider.select((f) => f.decorFor(nodeNum)),
    );
    return FramedAvatar(
      size: size,
      decor: decor,
      child: NodeAvatar(nodeNum: nodeNum, shortName: shortName, size: size),
    );
  }
}
