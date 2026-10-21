import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../ui/kit/kit.dart';

/// Карточка ноды: на широком экране — во вкладке «Ноды» рядом со списком,
/// на узком — отдельным экраном поверх текущего (назад вернёт туда же).
void openNode(BuildContext context, int num) {
  if (SplitView.isWide(context)) {
    context.go('/nodes/$num');
  } else {
    context.push('/node/$num');
  }
}
