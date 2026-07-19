import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vpnchik/core/app_info/app_info_provider.dart';
import 'package:vpnchik/core/localization/translations.dart';
import 'package:vpnchik/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:vpnchik/features/home/widget/anime_background.dart';
import 'package:vpnchik/features/home/widget/connection_button.dart';
import 'package:vpnchik/features/profile/notifier/active_profile_notifier.dart';
import 'package:vpnchik/features/profile/widget/profile_tile.dart';
import 'package:vpnchik/features/proxy/active/active_proxy_card.dart';
import 'package:vpnchik/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:vpnchik/core/theme/theme_switcher.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Text(
              'vpnchik',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3,
                color: const Color(0xFF3D2C2E),
              ),
            ),
            const Gap(6),
            AppVersionLabel(),
          ],
        ),
        actions: [
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          // Floating kawaii background — only in cute mode
          if (ref.watch(isCuteModeProvider)) const AnimeBackground(),
          // Content layer
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(
                slivers: [
                  MultiSliver(
                    children: [
                      const Gap(80), // space for appbar
                      switch (activeProfile) {
                        AsyncData(value: final profile?) => ProfileTile(
                          profile: profile,
                          isMain: true,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: const Color(0xFFFFFAF5).withValues(alpha: 0.85),
                        ),
                        _ => const Text(""),
                      },
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [ConnectionButton(), ActiveProxyDelayIndicator()],
                              ),
                            ),
                            ActiveProxyFooter(),
                            Gap(32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (ref.watch(hasAnyProfileProvider).value ?? false)
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: const Color(0xFFFFFAF5).withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      onTap: () => ref.read(bottomSheetsNotifierProvider.notifier).showQuickSettings(),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsetsDirectional.only(start: 20, end: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.star, size: 14, color: const Color(0xFFF8BBD0)),
                            const Gap(6),
                            Text(
                              t.pages.home.quickSettings,
                              style: TextStyle(
                                color: const Color(0xFF3D2C2E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Gap(4),
                            const Icon(Icons.arrow_drop_up_rounded, size: 18, color: Color(0xFF3D2C2E)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.common.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8BBD0).withValues(alpha: 0.3),
              const Color(0xFFFFD1B3).withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF3D2C2E).withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
