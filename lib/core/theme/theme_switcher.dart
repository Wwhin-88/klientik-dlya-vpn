import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vpnchik/features/profile/notifier/active_profile_notifier.dart';

const _methodChannel = MethodChannel('com.vpnchik.app/icon');

/// Whether the app is in "cute mode" (profile name contains "lublu").
/// Falls back to `false` (boring mode) when no profile is active.
final isCuteModeProvider = Provider<bool>((ref) {
  final activeProfile = ref.watch(activeProfileProvider).valueOrNull;
  if (activeProfile == null) return false;
  final name = activeProfile.name.toLowerCase();
  final cute = name.contains('lublu');

  // Toggle Android launcher icon (boring ⇄ heart) when mode changes.
  // Fire-and-forget: if native side not available this is a no-op.
  _methodChannel.invokeMethod('setIcon', {'icon': cute ? 'heart' : 'default'});

  return cute;
});
