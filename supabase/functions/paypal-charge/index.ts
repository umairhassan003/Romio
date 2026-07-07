// @ts-nocheck — runs in Supabase's Deno runtime, not the editor's Node TS
// server. The `Deno` global and remote imports resolve at deploy time.
/// <reference lib="deno.ns" />
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Supabase Edge Function: paypal-charge
//
// Holds the PayPal REST credentials server-side (as Supabase secrets) and
// drives the PayPal Orders v2 flow. The mobile app calls it via
// `supabase.functions.invoke('paypal-charge')` and never sees the secret.
//
// Secrets required (set with `supabase secrets set ...`):
//   PAYPAL_CLIENT_ID      - REST app Client ID
//   PAYPAL_CLIENT_SECRET  - REST app Client Secret
//   PAYPAL_ENV            - 'sandbox' (default) or 'live'
//
// Auth: requires a valid Supabase JWT by default (verify_jwt), so only
// authenticated app users can call it.
//
// ── Actions ──
// 1) action: "create"
//    Card  → creates + captures inline → { status: "completed", reference }
//    PayPal→ creates order, returns approval link the buyer must approve:
//            { status: "requires_approval", order_id, approval_url }
// 2) action: "capture"  (after PayPal-wallet approval)
//    body: { order_id } → { status: "completed", reference }
//
// All business outcomes return HTTP 200 so the app can read { status, ... }.

const PAYPAL_ENV = Deno.env.get("PAYPAL_ENV") ?? "sandbox";
const CLIENT_ID = Deno.env.get("PAYPAL_CLIENT_ID") ?? "";
const CLIENT_SECRET = Deno.env.get("PAYPAL_CLIENT_SECRET") ?? "";
const BASE_URL = PAYPAL_ENV === "live"
  ? "https://api-m.paypal.com"
  : "https://api-m.sandbox.paypal.com";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

async function fetchAccessToken(): Promise<string | null> {
  const basic = btoa(`${CLIENT_ID}:${CLIENT_SECRET}`);
  const res = await fetch(`${BASE_URL}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });
  if (!res.ok) return null;
  const data = await res.json();
  return data.access_token ?? null;
}

function extractError(body: any, fallback: string): string {
  const detail = body?.details?.[0];
  return detail?.description ?? detail?.issue ?? body?.message ?? fallback;
}

function captureIdFrom(order: any): string | undefined {
  return order?.purchase_units?.[0]?.payments?.captures?.[0]?.id;
}

function approvalLinkFrom(order: any): string | undefined {
  const links = order?.links ?? [];
  const link = links.find((l: any) =>
    l.rel === "payer-action" || l.rel === "approve"
  );
  return link?.href;
}

async function captureOrder(token: string, orderId: string): Promise<Response> {
  const res = await fetch(
    `${BASE_URL}/v2/checkout/orders/${orderId}/capture`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`,
      },
    },
  );
  const body = await res.json();
  if (res.ok && body.status === "COMPLETED") {
    return json({
      status: "completed",
      reference: captureIdFrom(body) ?? orderId,
    });
  }
  return json({
    status: "failed",
    error: extractError(body, `Payment not completed (${body.status}).`),
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }
  if (req.method !== "POST") {
    return json({ status: "failed", error: "Method not allowed" }, 405);
  }
  if (!CLIENT_ID || !CLIENT_SECRET) {
    return json({
      status: "failed",
      error: "PayPal credentials are not configured on the server.",
    });
  }

  try {
    const body = await req.json();
    const action = body.action === "capture" ? "capture" : "create";

    const token = await fetchAccessToken();
    if (!token) {
      return json({
        status: "failed",
        error: "Could not authenticate with PayPal (check credentials/env).",
      });
    }

    // ── Capture an already-approved PayPal-wallet order ──
    if (action === "capture") {
      const orderId = String(body.order_id ?? "");
      if (!orderId) {
        return json({ status: "failed", error: "Missing order_id." });
      }
      return await captureOrder(token, orderId);
    }

    // ── Create a new order ──
    const method = body.method === "paypal" ? "paypal" : "card";
    const amount = String(body.amount ?? "");
    const currency = String(body.currency ?? "USD");
    const reservationCode = String(body.reservation_code ?? "");
    const descriptor = String(body.descriptor ?? "ROMIO HOTEL BOOKING").slice(0, 22);
    const brandName = String(body.brand_name ?? "ROMIO HOTEL BOOKING");

    if (!amount || Number(amount) <= 0) {
      return json({ status: "failed", error: "Invalid amount." });
    }

    const paymentSource = method === "card"
      ? {
        card: {
          number: body.card?.number,
          expiry: body.card?.expiry,
          security_code: body.card?.cvv,
          name: body.card?.name,
        },
      }
      : {
        paypal: {
          experience_context: {
            brand_name: brandName,
            user_action: "PAY_NOW",
            shipping_preference: "NO_SHIPPING",
            return_url: String(body.return_url ?? ""),
            cancel_url: String(body.cancel_url ?? ""),
          },
        },
      };

    const orderBody = {
      intent: "CAPTURE",
      purchase_units: [
        {
          amount: { currency_code: currency, value: amount },
          description: descriptor,
          soft_descriptor: descriptor,
          custom_id: reservationCode,
        },
      ],
      payment_source: paymentSource,
    };

    const createRes = await fetch(`${BASE_URL}/v2/checkout/orders`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`,
        "PayPal-Request-Id": reservationCode || crypto.randomUUID(),
      },
      body: JSON.stringify(orderBody),
    });

    const createJson = await createRes.json();
    if (!createRes.ok) {
      return json({
        status: "failed",
        error: extractError(createJson, "Order creation failed."),
      });
    }

    // Card orders capture inline.
    if (createJson.status === "COMPLETED") {
      return json({
        status: "completed",
        reference: captureIdFrom(createJson) ?? createJson.id,
      });
    }

    // PayPal-wallet orders need buyer approval first.
    if (method === "paypal") {
      const approvalUrl = approvalLinkFrom(createJson);
      if (!approvalUrl) {
        return json({
          status: "failed",
          error: "PayPal did not return an approval link.",
        });
      }
      return json({
        status: "requires_approval",
        order_id: createJson.id,
        approval_url: approvalUrl,
      });
    }

    // Card order not completed inline → try an explicit capture.
    return await captureOrder(token, createJson.id);
  } catch (e) {
    return json({ status: "failed", error: `Payment error: ${e}` });
  }
});
