/// Back-office settlement / payout configuration for the Romio web admin.
///
/// This is the destination where collected funds (PayPal + card-via-PayPal)
/// are ultimately settled. It is shown read-only to operators in the admin
/// Settings screen so they can verify where money lands.
///
/// SECURITY / SCOPE:
/// These values live only in the web-admin scope and are intentionally kept
/// OUT of the mobile app binary (which ships to end users and is trivially
/// extractable). Even so, a client-side admin bundle is not a secrets vault —
/// for production the canonical home for these is a server-side secret store
/// (e.g. Supabase config / Vault). Treat this file as operator-facing display
/// config, not a security boundary.
class SettlementConfig {
  const SettlementConfig._();

  /// PayPal account that collects payments (PayPal + cards via PayPal).
  static const String paypalMerchantId = 'D8KNSGX6Q52NQ';
  static const String paypalReceiverEmail = 'info@getromio.app';

  /// Bank account where PayPal payouts are withdrawn to.
  static const String bankRoutingNumber = '101019628';
  static const String bankAccountNumber = '216221024193';
  static const String bankSwiftBic = 'TRWIUS35XXX';
}
