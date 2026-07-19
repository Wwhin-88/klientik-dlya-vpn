import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:vpnchik/core/localization/translations.dart';
import 'package:vpnchik/core/router/dialog/dialog_notifier.dart';
import 'package:vpnchik/core/router/go_router/helper/active_breakpoint_notifier.dart';
import 'package:vpnchik/features/profile/notifier/active_profile_notifier.dart';
import 'package:vpnchik/features/settings/notifier/config_option/config_option_notifier.dart';
import 'package:vpnchik/features/settings/notifier/reset_tunnel/reset_tunnel_notifier.dart';
import 'package:vpnchik/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ConfigOptionSection {
  warp,
  fragment;

  static final _warpKey = GlobalKey(debugLabel: "warp-section-key");
  static final _fragmentKey = GlobalKey(debugLabel: "fragment-section-key");

  GlobalKey get key => switch (this) {
    ConfigOptionSection.warp => _warpKey,
    ConfigOptionSection.fragment => _fragmentKey,
  };
}

class SettingsPage extends HookConsumerWidget {
  SettingsPage({super.key, String? section})
    : section = section != null ? ConfigOptionSection.values.byName(section) : null;

  final ConfigOptionSection? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    // final scrollController = useScrollController();

    // useMemoized(
    //   () {
    //     if (section != null) {
    //       WidgetsBinding.instance.addPostFrameCallback(
    //         (_) {
    //           final box = section!.key.currentContext?.findRenderObject() as RenderBox?;

    //           final offset = box?.localToGlobal(Offset.zero);
    //           if (offset == null) return;
    //           final height = scrollController.offset + offset.dy - MediaQueryData.fromView(View.of(context)).padding.top - kToolbarHeight;
    //           scrollController.animateTo(
    //             height,
    //             duration: const Duration(milliseconds: 500),
    //             curve: Curves.decelerate,
    //           );
    //         },
    //       );
    //     }
    //   },
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.pages.settings.title),
        actions: [
          const Gap(8),
        ],
      ),
      body: ListView(
        children: [
          // TipCard(message: t.settings.experimentalMsg),
          SettingsSection(
            title: t.pages.settings.general.title,
            icon: Icons.layers_rounded,
            namedLocation: context.namedLocation('general'),
          ),
          if (ref.watch(hasAnyProfileProvider).value ?? false)
            SettingsSection(
              title: t.pages.settings.chain.title,
              icon: Icons.webhook_rounded,
              subtitle: Text(t.pages.settings.chain.subtitle),
              namedLocation: context.namedLocation('chainOptions'),
            ),
          SettingsSection(
            title: t.pages.settings.routing.title,
            icon: Icons.route_rounded,
            namedLocation: context.namedLocation('routingOptions'),
          ),
          // DNS options removed
          // Inbound options removed
          // TLS Tricks removed
          if (PlatformUtils.isIOS)
            Material(
              child: ListTile(
                title: Text(t.pages.settings.resetTunnel),
                leading: const Icon(Icons.autorenew_rounded),
                onTap: () async {
                  await ref.read(resetTunnelNotifierProvider.notifier).run();
                },
              ),
            ),
          if (Breakpoint(context).isMobile()) ...[
            SettingsSection(
              title: t.pages.logs.title,
              icon: Icons.description_rounded,
              namedLocation: context.namedLocation('logs'),
            ),
            SettingsSection(
              title: t.pages.about.title,
              icon: Icons.info_rounded,
              namedLocation: context.namedLocation('about'),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsSection extends HookConsumerWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    required this.namedLocation,
  });

  final String title;
  final Widget? subtitle;
  final IconData icon;
  final String namedLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.go(namedLocation),
    );
  }
}
