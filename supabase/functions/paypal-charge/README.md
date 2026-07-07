# paypal-charge — Supabase Edge Function

Charges PayPal (PayPal account + credit/debit cards via PayPal) on behalf of the
Romio app. The PayPal **Client Secret lives here as a Supabase secret** and is
never shipped in the app.

## 1. Set the credentials (Supabase secrets)

Get a REST app's Client ID + Secret from
https://developer.paypal.com → Apps & Credentials.

```bash
supabase secrets set \
  PAYPAL_CLIENT_ID=your_client_id \
  PAYPAL_CLIENT_SECRET=your_client_secret \
  PAYPAL_ENV=sandbox      # use 'live' for real money
```

## 2. Deploy

```bash
supabase functions deploy paypal-charge
```

(`supabase link --project-ref hjpxiekxyuovzqaffmen` first if this repo isn't
linked yet. The function requires a valid Supabase JWT by default, so only
signed-in app users can call it.)

## 3. Turn it on in the app

In `lib/core/constants/payment_constants.dart` set:

```dart
static const bool liveChargingEnabled = true;
```

Until then the app stays in record-only mode (no real charge), so the booking
flow keeps working during development.

## Statement / notification text

The customer-facing descriptor is **"ROMIO HOTEL BOOKING"** — sent by the app
as `descriptor` / `brand_name` and applied to the PayPal order's
`soft_descriptor`, `description`, and `brand_name`. (Card statements are usually
prefixed by the processor, e.g. `PAYPAL * ROMIO HOTEL BOOKING`; the 22-char
`soft_descriptor` limit is enforced server-side.)

## How each method works

- **Card** — one `create` call; PayPal captures inline → booking recorded. No
  redirect.
- **PayPal wallet** — `create` returns an approval URL → the app opens it in an
  in-app browser ([PayPalApprovalScreen]) → on approval PayPal redirects to
  `PaymentConstants.paypalReturnUrl`, which the browser intercepts → the app
  calls `capture` with the `order_id` → booking recorded. Cancelling returns to
  the payment screen with no charge and no booking.

Both are fully functional once the secrets are set and the function is deployed
— no further app changes needed.

## Notes / limits

- **PCI**: raw card data passes through this function over TLS to PayPal. That
  is acceptable for low volume but puts the function in PCI scope. To minimize
  scope later, tokenize the card client-side with PayPal's SDK and send only the
  token here. (PayPal-wallet payments never expose card data to us.)
- The wallet approval uses an in-app WebView. PayPal occasionally adds friction
  to logins inside embedded WebViews; if that becomes an issue for live traffic,
  switch the approval step to a system browser tab (Custom Tabs / ASWebAuth).
```
