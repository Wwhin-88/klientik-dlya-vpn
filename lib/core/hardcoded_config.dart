/// Hardcoded VPN configuration for first-launch auto-setup.
///
/// Two profiles are injected on first launch:
/// - "others" (old server) — set as active by default for privacy
/// - "lublu tebya <3" (new server) — available as secondary, user switches manually
abstract class HardcodedConfig {
  /// New server — Oracle Cloud, displayed as "lublu tebya <3".
  static const String vlessUrl =
      'vless://471c81f3-0ab9-4517-926c-bdecabdae721@82.70.43.11:443'
      '?encryption=none'
      '&flow=xtls-rprx-vision'
      '&fp=chrome'
      '&pbk=Q1U5Oa-1kQKjTFPvmzBhcupu2wtwlfctIOHodZPh0BU'
      '&security=reality'
      '&sid=8c1f01491d2e37'
      '&sni=images.apple.com'
      '&spx=%2Fe5a7447329f6961'
      '&type=tcp'
      '#lublu%20tebya%20%3C3-lubimaya';

  static const String profileName = 'lublu tebya <3';

  /// Old server — set as DEFAULT active to avoid exposing the other name.
  /// Displayed as "others" in the UI.
  static const String vlessUrlOld =
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

  static const String profileNameOld = 'others';
}
