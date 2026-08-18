// @ts-nocheck — runs in Supabase's Deno runtime, not the editor's Node TS
// server. The `Deno` global and remote imports resolve at deploy time.
/// <reference lib="deno.ns" />

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") ?? "info@getromio.app";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResp(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

// ─── Brand constants ────────────────────────────────────────────────
const BRAND_COLOR = "#6D0B3E";
const BRAND_LIGHT = "#F2DBE6";
const BRAND_BG = "#FFFFFF";
const BRAND_TEXT = "#1A1A1A";
const BRAND_SECONDARY = "#6B6B6B";

const LOGO_URL = "https://hjpxiekxyuovzqaffmen.supabase.co/storage/v1/object/public/romio/logo.svg";

// ─── Email wrapper ──────────────────────────────────────────────────
function wrapHtml(bodyContent: string): string {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Romio</title>
  <style>
    body { margin: 0; padding: 0; background-color: #F5F5F5; font-family: 'Helvetica Neue', Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; background-color: ${BRAND_BG}; }
    .header { background: linear-gradient(135deg, ${BRAND_COLOR}, #8B1A5A); padding: 32px; text-align: center; }
    .header h1 { color: #FFFFFF; font-size: 28px; margin: 0; letter-spacing: 2px; }
    .content { padding: 40px 32px; color: ${BRAND_TEXT}; line-height: 1.6; }
    .content h2 { color: ${BRAND_COLOR}; font-size: 22px; margin-top: 0; }
    .content p { font-size: 15px; margin: 12px 0; }
    .detail-card { background: #FDF0F5; border-radius: 12px; padding: 24px; margin: 24px 0; border-left: 4px solid ${BRAND_COLOR}; }
    .detail-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid ${BRAND_LIGHT}; }
    .detail-row:last-child { border-bottom: none; }
    .detail-label { color: ${BRAND_SECONDARY}; font-size: 14px; font-weight: 500; }
    .detail-value { color: ${BRAND_TEXT}; font-size: 14px; font-weight: 600; text-align: right; }
    .info-box { background: #F7F7F7; border-radius: 12px; padding: 20px; margin: 24px 0; }
    .info-box h3 { color: ${BRAND_COLOR}; font-size: 16px; margin: 0 0 12px 0; }
    .info-box p { font-size: 13px; color: ${BRAND_SECONDARY}; margin: 8px 0; }
    .footer { background: #F7F7F7; padding: 24px 32px; text-align: center; border-top: 1px solid #E8D5DE; }
    .footer p { font-size: 12px; color: ${BRAND_SECONDARY}; margin: 4px 0; }
    .hotel-image { width: 100%; max-height: 250px; object-fit: cover; border-radius: 12px; margin: 16px 0; }
    .reservation-code { background: ${BRAND_COLOR}; color: #FFFFFF; display: inline-block; padding: 8px 20px; border-radius: 8px; font-size: 18px; font-weight: 700; letter-spacing: 1px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <img src="${LOGO_URL}" alt="Romio" width="160" height="48" />
    </div>
    <div class="content">
      ${bodyContent}
    </div>
    <div class="footer">
      <p>Romio App</p>
      <p>🔒 Romio protege tus datos personales. Consulta nuestra política de privacidad desde la app.</p>
      <p style="margin-top: 12px; color: #B3B3B3;">© ${new Date().getFullYear()} Romio. Todos los derechos reservados.</p>
    </div>
  </div>
</body>
</html>`;
}

// ─── Hotel notification email ───────────────────────────────────────
function buildHotelEmail(data: any): { subject: string; html: string } {
  const body = `
    <h2>Nueva reserva recibida</h2>
    <p>Hola,</p>
    <p>Has recibido una nueva reserva a través de <strong>Romio</strong>.</p>

    <div class="detail-card">
      <h3 style="color: ${BRAND_COLOR}; margin-top: 0; margin-bottom: 16px;">Detalles de la reserva</h3>
      <table width="100%" cellpadding="0" cellspacing="0" style="font-size: 14px;">
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Cliente</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.client_name || data.reservation_code || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Habitación</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.room_name || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Fecha</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.date || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY};">Horario</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600;">${data.check_in || "—"} – ${data.check_out || "—"}</td>
        </tr>
      </table>
    </div>

    <p>Por favor, asegúrate de mantener la habitación disponible según las condiciones acordadas.</p>
    <p>Para cualquier incidencia, puedes contactar con el equipo de Romio.</p>
    <p style="margin-top: 24px;">Gracias por colaborar con nosotros,<br><strong>Equipo Romio</strong></p>
  `;

  return {
    subject: `Nueva reserva – ${data.reservation_code || "Romio"}`,
    html: wrapHtml(body),
  };
}

// ─── Client confirmation email ──────────────────────────────────────
function buildClientEmail(data: any): { subject: string; html: string } {
  const imageHtml = data.room_image_url
    ? `<img src="${data.room_image_url}" alt="Hotel" class="hotel-image" />`
    : "";

  const body = `
    <h2>¡Tu reserva está confirmada! 💜</h2>
    <p>Hola,</p>
    <p>Gracias por elegir <strong>Romio</strong> para tu próxima experiencia.</p>

    <p style="text-align: center; margin: 24px 0;">
      <span class="reservation-code">${data.reservation_code || "RM-0000"}</span>
    </p>

    ${imageHtml}

    <div class="detail-card">
      <h3 style="color: ${BRAND_COLOR}; margin-top: 0; margin-bottom: 16px;">Detalles de tu reserva</h3>
      <table width="100%" cellpadding="0" cellspacing="0" style="font-size: 14px;">
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Hotel</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.hotel_name || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Dirección</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.hotel_address || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Reserva a nombre de</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.client_name || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Habitación</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.room_name || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Fecha</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.date || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY}; border-bottom: 1px solid ${BRAND_LIGHT};">Horario</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid ${BRAND_LIGHT};">${data.check_in || "—"} – ${data.check_out || "—"}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: ${BRAND_SECONDARY};">Precio total</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; color: ${BRAND_COLOR};">$${data.total_price || "0"}</td>
        </tr>
      </table>
    </div>

    <div class="info-box">
      <h3>📋 Información importante</h3>
      <p><strong>Hora de llegada</strong><br>
      Te recomendamos llegar puntualmente a la hora indicada para aprovechar al máximo tu reserva.</p>
      <p><strong>Cancelación</strong><br>
      Puedes cancelar tu reserva sin costo hasta 24 horas antes del inicio de la misma. Pasado ese plazo, la reserva no será reembolsable.</p>
      <p><strong>No show</strong><br>
      En caso de no presentarte y/o no cancelar dentro del plazo indicado, la reserva se considerará utilizada.</p>
      <p><strong>Documento de identidad</strong><br>
      Para realizar el check-in, deberás presentar un documento de identidad válido.</p>
    </div>

    <p>El hotel ya ha sido notificado y te estará esperando en el horario indicado.</p>
    <p>Si tienes alguna duda sobre tu reserva, puedes escribirnos a <a href="mailto:info@getromio.app" style="color: ${BRAND_COLOR};">info@getromio.app</a>.</p>
    <p style="margin-top: 24px;">Disfruta el momento. Nosotros nos encargamos del resto. 💜<br><strong>Romio App</strong></p>
  `;

  return {
    subject: `Reserva confirmada – ${data.reservation_code || "Romio"}`,
    html: wrapHtml(body),
  };
}

// ─── Send via Resend HTTP API ───────────────────────────────────────
async function sendEmail(
  to: string,
  subject: string,
  html: string,
): Promise<void> {
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: `Romio <${FROM_EMAIL}>`,
      to: [to],
      subject,
      html,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Resend API error ${response.status}: ${error}`);
  }
}

// ─── Main handler ───────────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }
  if (req.method !== "POST") {
    return jsonResp({ status: "error", message: "Method not allowed" }, 405);
  }
  if (!RESEND_API_KEY) {
    console.error("send-email: RESEND_API_KEY secret is not set");
    return jsonResp({
      status: "error",
      message: "Email service not configured (missing RESEND_API_KEY).",
    }, 500);
  }

  try {
    const body = await req.json();
    const { type, to, data } = body;

    if (!type || !to) {
      return jsonResp({
        status: "error",
        message: "Missing required fields: type, to",
      }, 400);
    }

    let email: { subject: string; html: string };

    switch (type) {
      case "reservation_hotel":
        email = buildHotelEmail(data ?? {});
        break;
      case "reservation_client":
        email = buildClientEmail(data ?? {});
        break;
      default:
        return jsonResp({
          status: "error",
          message: `Unknown email type: ${type}`,
        }, 400);
    }

    await sendEmail(to, email.subject, email.html);
    console.log(`send-email: ${type} sent to ${to}`);

    return jsonResp({ status: "sent" });
  } catch (e) {
    console.error("send-email error:", e);
    return jsonResp({
      status: "error",
      message: `Failed to send email: ${e}`,
    }, 500);
  }
});
