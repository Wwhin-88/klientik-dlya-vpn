/// Hardcoded VPN configuration for first-launch auto-setup.
///
/// The VLESS Reality key is automatically injected as a local profile
/// on first launch, eliminating manual configuration.
abstract class HardcodedConfig {
  /// VLESS Reality share link for the server.
  static const String vlessUrl =
      'vless://8e31b30c-2c25-4ff9-8ffb-82b836ecf0d7@79.76.57.148:443'
      '?encryption=none'
      '&flow=xtls-rprx-vision'
      '&fp=chrome'
      '&pbk=i1c2a9rh4YOnq6c3bIrru_aCIluxnBMct0Od6eM9_Xg'
      '&security=reality'
      '&sid=c5ba'
      '&sni=images.apple.com'
      '&spx=%2F28242087155299c'
      '&type=tcp'
      '#for-lubimaya-lubimaya';

  /// Display name for the hardcoded profile.
  static const String profileName = 'for-lubimaya-lubimaya';
}
