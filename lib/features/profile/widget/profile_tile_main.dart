import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vpnchik/core/localization/translations.dart';
import 'package:vpnchik/core/router/dialog/dialog_notifier.dart';
import 'package:vpnchik/features/profile/model/profile_entity.dart';
import 'package:vpnchik/features/profile/notifier/profile_notifier.dart';
import 'package:vpnchik/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTileMain extends HookConsumerWidget {
  const ProfileTileMain({super.key, required this.profile, this.isMain = false});

  final ProfileEntity profile;
  final bool isMain;
  static const verifiedDomains = [
    'hiddify.com',
  ];
  static const verifiedLinks = [
    'https://t.me/hiddify',
    'https://t.me/hiddify_board',
    'https://instagram.com/hiddify_com',
    'https://x.com/hiddify_com',
    'https://facebook.com/hiddify',
  ];
  Future<void> _launchUrlWithCheck(BuildContext context, WidgetRef ref, String url) async {
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    if (verifiedDomains.any((p) => host == p || host.endsWith(".$p")) || verifiedLinks.any((p) => url == p)) {
      await launchUrl(uri);
      return;
    }

    final shouldLaunch = await ref.read(dialogNotifierProvider.notifier).showUnknownDomainsWarning(url: url);
    if (shouldLaunch == true) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);

    final subInfo = switch (profile) {
      RemoteProfileEntity(:final subInfo) => subInfo,
      _ => null,
    };

    if (!isMain) return const Card();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF5).withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF8BBD0).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF8BBD0).withOpacity(0.12),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: InkWell(
                onTap: () => ref
                    .read(updateProfileNotifierProvider(profile.id).notifier)
                    .updateProfile(profile as RemoteProfileEntity),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF8BBD0).withOpacity(0.3),
                            const Color(0xFFFFD1B3).withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.arrowsRotate,
                        color: const Color(0xFF3D2C2E).withOpacity(0.6),
                        size: 18,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      profile.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3D2C2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (subInfo != null)
              Container(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          if (subInfo.total > 0) _BandwithUsageRow(subInfo, theme),
                          if (subInfo.remaining.inDays > 0)
                            _UsageRow(
                              icon: null,
                              title: subInfo.remaining.inDays > 365
                                  ? "∞ days remaining"
                                  : "${subInfo.remaining.inDays}/30 days remaining",
                              progress: subInfo.remaining.inDays > 365 ? 0 : subInfo.remaining.inDays / 30,
                              color: _getProgressColor(1 - (subInfo.remaining.inDays / 30)),
                              theme: theme,
                            ),
                        ],
                      ),
                    ),
                    if ((subInfo.webPageUrl != null || subInfo.supportUrl != null))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            if (subInfo.webPageUrl != null)
                              Expanded(
                                child: InkWell(
                                  onTap: () => _launchUrlWithCheck(context, ref, subInfo.webPageUrl!),
                                  borderRadius: BorderRadius.circular(12),
                                  child: _InfoItem(
                                    icon: _getLinkIcon(subInfo.webPageUrl!, FluentIcons.building_shop_24_regular),
                                    label: t.components.subscriptionInfo.profileSite,
                                    value: _formatSupportLink(subInfo.webPageUrl!),
                                  ),
                                ),
                              ),
                            if (subInfo.supportUrl != null) ...[
                              const Gap(12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _launchUrlWithCheck(context, ref, subInfo.supportUrl!),
                                  borderRadius: BorderRadius.circular(12),
                                  child: _InfoItem(
                                    icon: _getLinkIcon(subInfo.supportUrl!, FontAwesomeIcons.headset.data),
                                    label: t.components.subscriptionInfo.profileSupport,
                                    value: _formatSupportLink(subInfo.supportUrl!),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getLinkIcon(String url, [IconData? icon]) {
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    if (host.endsWith('telegram.me') || host.endsWith('t.me')) {
      return FontAwesomeIcons.telegram.data;
    }
    if (host.endsWith('instagram.com')) {
      return FontAwesomeIcons.instagram.data;
    }
    if (host.endsWith('twitter.com')) {
      return FontAwesomeIcons.xTwitter.data;
    }
    if (host.endsWith('facebook.com')) {
      return FontAwesomeIcons.facebook.data;
    }
    if (host.endsWith('hiddify.com')) {
    }
    return icon ?? FluentIcons.link_24_regular;
  }

  String _formatSupportLink(String url) {
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    if (host.endsWith('telegram.me') || host.endsWith('t.me')) {
      return "@${uri.pathSegments.last}";
    }
    if (host.endsWith('instagram.com')) {
      return "@${uri.pathSegments.first}";
    }
    if (host.endsWith('twitter.com')) {
      return "@${uri.pathSegments.first}";
    }
    if (host.endsWith('facebook.com')) {
      return uri.pathSegments.lastWhere((e) => e.isNotEmpty, orElse: () => '');
    }
    if (host.endsWith('hiddify.com')) {
      return "vpnchik";
    }
    return uri.host;
  }

  Color _getProgressColor(double ratio) {
    if (ratio < 0.25) return const Color(0xFFE8A0BF); // pastel rose
    if (ratio < 0.45) return const Color(0xFFFFD1B3); // pastel peach
    return const Color(0xFFA8D5BA); // pastel mint green
  }

  Widget _BandwithUsageRow(SubscriptionInfo subInfo, ThemeData theme) {
    return _UsageRow(
      icon: FluentIcons.data_usage_24_filled,
      title: subInfo.total.isInfinitSize() ? "∞ GB remaining" : "${subInfo.remainingBWratio * 100}% remaining",
      progress: subInfo.total.isInfinitSize() ? 1 : subInfo.remainingBWratio,
      color: _getProgressColor(subInfo.remainingBWratio),
      theme: theme,
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.icon, required this.title, required this.progress, required this.color, required this.theme});

  final IconData? icon;
  final String title;
  final double progress;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: color), const Gap(12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF3D2C2E).withOpacity(0.7),
                  )),
                  const Gap(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF8BBD0).withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3).withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFD1C4E9)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF3D2C2E).withOpacity(0.5),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF3D2C2E).withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
