import 'package:flutter/material.dart';
import 'package:vpnchik/core/localization/locale_preferences.dart';
import 'package:vpnchik/core/localization/translations.dart';
import 'package:vpnchik/core/model/constants.dart';
import 'package:vpnchik/core/router/dialog/dialog_notifier.dart';
import 'package:vpnchik/features/profile/add/widgets/free_btn.dart';
import 'package:vpnchik/features/profile/model/profile_entity.dart';
import 'package:vpnchik/features/profile/notifier/profile_notifier.dart';
import 'package:vpnchik/features/settings/data/config_option_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FreeBtns extends ConsumerWidget {
  const FreeBtns({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
