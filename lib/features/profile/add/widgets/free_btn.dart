import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vpnchik/core/localization/locale_preferences.dart';
import 'package:vpnchik/core/localization/translations.dart';
import 'package:vpnchik/features/common/custom_text_scroll.dart';
import 'package:vpnchik/features/profile/add/model/free_profiles_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FreeBtn extends ConsumerWidget {
  const FreeBtn({super.key, required this.freeProfile, required this.onTap});

  final FreeProfile freeProfile;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class Feature extends ConsumerWidget {
  const Feature({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.primary),
        const Gap(4),
        Text(title, style: theme.textTheme.labelSmall!.copyWith(color: color)),
      ],
    );
  }
}
