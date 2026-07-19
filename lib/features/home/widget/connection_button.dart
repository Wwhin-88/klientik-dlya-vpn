import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vpnchik/core/localization/translations.dart';
import 'package:vpnchik/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:vpnchik/core/router/dialog/dialog_notifier.dart';
import 'package:vpnchik/core/theme/theme_extensions.dart';
import 'package:vpnchik/core/theme/theme_switcher.dart';
import 'package:vpnchik/core/widget/animated_text.dart';
import 'package:vpnchik/features/connection/model/connection_status.dart';
import 'package:vpnchik/features/connection/notifier/connection_notifier.dart';
import 'package:vpnchik/features/profile/notifier/active_profile_notifier.dart';
import 'package:vpnchik/features/proxy/active/active_proxy_notifier.dart';
import 'package:vpnchik/features/settings/notifier/config_option/config_option_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// vpnchik kawaii connection button — pastel gradient, heart icon, soft glow
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final isCute = ref.watch(isCuteModeProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;

    final requiresReconnect = ref.watch(configOptionNotifierProvider).valueOrNull;

    var secureLabel = '';
    if (delay <= 0 || delay > 65000 || connectionStatus.value != const Connected()) {
      secureLabel = "";
    }
    return _ConnectionButton(
      onTap: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => () async {
          final activeProfile = await ref.read(activeProfileProvider.future);
          return await ref.read(connectionNotifierProvider.notifier).reconnect(activeProfile);
        },
        AsyncData(value: Disconnected()) || AsyncError() => () async {
          if (ref.read(activeProfileProvider).valueOrNull == null) {
            await ref.read(dialogNotifierProvider.notifier).showNoActiveProfile();
            ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile();
          }
          if (await ref.read(dialogNotifierProvider.notifier).showExperimentalFeatureNotice()) {
            return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
          }
        },
        AsyncData(value: Connected()) => () async {
          if (requiresReconnect == true &&
              await ref.read(dialogNotifierProvider.notifier).showExperimentalFeatureNotice()) {
            return await ref
                .read(connectionNotifierProvider.notifier)
                .reconnect(await ref.read(activeProfileProvider.future));
          }
          return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
        },
        _ => () {},
      },
      enabled: switch (connectionStatus) {
        AsyncData(value: Connected()) || AsyncData(value: Disconnected()) || AsyncError() => true,
        _ => false,
      },
      label: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => t.connection.connecting,
        AsyncData(value: Disconnected()) => isCute ? 'Тыцни что бы включить 💗' : t.connection.tapToConnect,
        AsyncData(value: final status) => status.present(t),
        _ => "",
      },
      isConnected: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => true,
        AsyncData(value: Connected()) => true,
        _ => false,
      },
      animated: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => false,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => false,
        AsyncData(value: Connected()) => true,
        AsyncData(value: _) => true,
        _ => false,
      },
      secureLabel: secureLabel,
    );
  }
}

class _ConnectionButton extends StatefulWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.isConnected,
    required this.animated,
    required this.secureLabel,
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final bool isConnected;
  final bool animated;
  final String secureLabel;

  @override
  State<_ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends State<_ConnectionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  bool _pressed = false;

  // Pastel gradient colors for the button
  static const List<Color> _idleGradient = [
    Color(0xFFF8BBD0), // pastel pink
    Color(0xFFFFD1B3), // pastel peach
    Color(0xFFD1C4E9), // lavender
  ];

  static const List<Color> _connectedGradient = [
    Color(0xFFE8A0BF), // pastel rose
    Color(0xFFF8BBD0), // pastel pink
    Color(0xFFC9B1E0), // soft lilac
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ConnectionButton old) {
    super.didUpdateWidget(old);
    if (widget.animated && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.animated && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.label,
          child: GestureDetector(
            onTapDown: widget.enabled
                ? (_) {
                    setState(() => _pressed = true);
                  }
                : null,
            onTapUp: widget.enabled
                ? (_) {
                    setState(() => _pressed = false);
                    widget.onTap();
                  }
                : null,
            onTapCancel: () {
              if (_pressed) setState(() => _pressed = false);
            },
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) {
                final glowValue = _glowAnimation.value;
                final scale = _pressed ? 0.95 : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isConnected ? _connectedGradient : _idleGradient,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isConnected
                              ? const Color(0xFFE8A0BF).withValues(alpha: 0.4 * glowValue)
                              : const Color(0xFFF8BBD0).withValues(alpha: 0.35 * glowValue),
                          blurRadius: 20 + (1 - glowValue) * 8,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: widget.isConnected
                              ? const Color(0xFFD1C4E9).withValues(alpha: 0.2 * glowValue)
                              : const Color(0xFFFFD1B3).withValues(alpha: 0.2 * glowValue),
                          blurRadius: 32 + (1 - glowValue) * 12,
                          spreadRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.enabled ? widget.onTap : null,
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: widget.isConnected
                                ? FaIcon(
                                    FontAwesomeIcons.solidHeart,
                                    key: const ValueKey('heart'),
                                    size: 40,
                                    color: Colors.white,
                                  )
                                : FaIcon(
                                    FontAwesomeIcons.star,
                                    key: const ValueKey('star'),
                                    size: 40,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ).animate(target: widget.enabled ? 0 : 1).blurXY(end: 1),
                );
              },
            ),
          ),
        ),
        const Gap(16),
        ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedText(widget.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF3D2C2E),
                fontWeight: FontWeight.w600,
              )),
              if (widget.secureLabel.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.shieldHalved, size: 16, color: const Color(0xFFD1C4E9)),
                    const Gap(4),
                    Text(
                      widget.secureLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFFD1C4E9),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
