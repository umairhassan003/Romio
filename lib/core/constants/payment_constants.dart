/// Payment configuration for Romio.
///
/// ── Where the PayPal secret lives ──
/// The PayPal REST *Client Secret* is a shared secret: if the app can read it,
/// so can anyone who has the app (the Supabase anon key is in the app too, so a
/// Supabase *table* is no safer than hardcoding). The only secure home is
/// server-side, where the client never sees it.
///
/// Romio uses a **Supabase Edge Function** (`paypal-charge`) for this — it runs
/// inside your existing Supabase project (no separate server to host) and reads
/// the credentials from Supabase *secrets*:
///   PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET, PAYPAL_ENV
///
/// The app only knows the function name and the public, display-safe values
/// below. See: supabase/functions/paypal-charge/  (+ its README for deploy).
///
/// ── How to go live ──
///   1. Deploy the edge function and set the secrets (see the function README).
///   2. Flip [liveChargingEnabled] to `true`.
/// Until then the gateway runs in record-only mode so the booking flow still
/// works during development.
class PaymentConstants {
  const PaymentConstants._();

  /// Flip to `true` once the `paypal-charge` Edge Function is deployed and its
  /// secrets are set. When `false`, no real charge is made (record-only).
  static const bool liveChargingEnabled = false;

  /// Name of the Supabase Edge Function that performs PayPal charges.
  static const String paymentFunctionName = 'paypal-charge';

  // ── Public account identifiers (safe to ship; shown at checkout) ─────────
  static const String paypalMerchantId = 'D8KNSGX6Q52NQ';
  static const String paypalReceiverEmail = 'info@getromio.app';

  /// Default currency used for all charges.
  static const String currency = 'USD';

  /// What the customer sees on their card statement / PayPal notification.
  /// Max 22 chars for PayPal's `soft_descriptor`.
  static const String statementDescriptor = 'ROMIO HOTEL BOOKING';

  /// Brand name shown on PayPal-hosted screens and receipts.
  static const String brandName = 'ROMIO HOTEL BOOKING';

  // ── PayPal-wallet approval redirect URLs ─────────────────────────────────
  // These are where PayPal sends the buyer's browser after they approve or
  // cancel. They don't need to host anything real — the in-app browser
  // intercepts navigation to them (before they load) to detect the outcome.
  static const String paypalReturnUrl = 'https://getromio.app/paypal/return';
  static const String paypalCancelUrl = 'https://getromio.app/paypal/cancel';
}
