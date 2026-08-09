# Supabase Email Templates for Romio

These HTML templates should be pasted into **Supabase Dashboard → Authentication → Email Templates**.

> **Important**: In Supabase's email template editor, `{{ .ConfirmationURL }}` is the magic variable
> that Supabase replaces with the actual verification/reset link.

---

## 1. Confirm Signup (Account Verification)

**Subject**: `Verifica tu cuenta en Romio`

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verifica tu cuenta</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F5F5F5; font-family: 'Helvetica Neue', Arial, sans-serif;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #FFFFFF;">
    <!-- Header -->
    <div style="background: linear-gradient(135deg, #6D0B3E, #8B1A5A); padding: 32px; text-align: center;">
      <h1 style="color: #FFFFFF; font-size: 28px; margin: 0; letter-spacing: 2px;">ROMIO</h1>
    </div>
    
    <!-- Content -->
    <div style="padding: 40px 32px; color: #1A1A1A; line-height: 1.6;">
      <h2 style="color: #6D0B3E; font-size: 22px; margin-top: 0;">Verifica tu cuenta 💜</h2>
      
      <p style="font-size: 15px;">Hola,</p>
      <p style="font-size: 15px;">Gracias por registrarte en <strong>Romio</strong> 💜</p>
      <p style="font-size: 15px;">Estás a un solo paso de empezar a reservar experiencias especiales.</p>
      <p style="font-size: 15px;">Para verificar tu cuenta, haz clic en el siguiente enlace:</p>
      
      <div style="text-align: center; margin: 32px 0;">
        <a href="{{ .ConfirmationURL }}" 
           style="background-color: #6D0B3E; color: #FFFFFF; text-decoration: none; padding: 14px 32px; border-radius: 28px; font-size: 16px; font-weight: 600; display: inline-block;">
          👉 Verificar mi cuenta
        </a>
      </div>
      
      <p style="font-size: 13px; color: #6B6B6B;">Si no has creado esta cuenta, puedes ignorar este correo con total tranquilidad.</p>
      
      <p style="font-size: 15px; margin-top: 32px;">Nos vemos pronto,<br><strong>Romio App</strong></p>
    </div>
    
    <!-- Footer -->
    <div style="background: #F7F7F7; padding: 24px 32px; text-align: center; border-top: 1px solid #E8D5DE;">
      <p style="font-size: 12px; color: #6B6B6B; margin: 4px 0;">Romio App</p>
      <p style="font-size: 12px; color: #6B6B6B; margin: 4px 0;">🔒 Romio protege tus datos personales.</p>
      <p style="font-size: 11px; color: #B3B3B3; margin-top: 12px;">© 2025 Romio. Todos los derechos reservados.</p>
    </div>
  </div>
</body>
</html>
```

---

## 2. Reset Password (Forgot Password — OTP code)

**Subject**: `Restablece tu contraseña en Romio`

### What you must change in Supabase

Go to **Supabase Dashboard → Authentication → Email Templates → Reset password** and:

1. **Replace** any `{{ .ConfirmationURL }}` link/button with the OTP token variable:
   ```html
   {{ .Token }}
   ```
2. **Keep the subject** as: `Restablece tu contraseña en Romio`
3. **Save** the template

Supabase generates an OTP and injects it into `{{ .Token }}`. The mobile app calls
`verifyOTP(type: recovery)` — Supabase checks the code **server-side**. A wrong or expired code
is rejected and the user cannot reach the reset-password screen.

> **Do not remove** `{{ .Token }}` from the template. Without it, Supabase sends only a magic
> link and the in-app OTP flow will not work.

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Restablece tu contraseña</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F5F5F5; font-family: 'Helvetica Neue', Arial, sans-serif;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #FFFFFF;">
    <!-- Header -->
    <div style="background: linear-gradient(135deg, #6D0B3E, #8B1A5A); padding: 32px; text-align: center;">
      <h1 style="color: #FFFFFF; font-size: 28px; margin: 0; letter-spacing: 2px;">ROMIO</h1>
    </div>
    
    <!-- Content -->
    <div style="padding: 40px 32px; color: #1A1A1A; line-height: 1.6;">
      <h2 style="color: #6D0B3E; font-size: 22px; margin-top: 0;">Restablece tu contraseña</h2>
      
      <p style="font-size: 15px;">Hola,</p>
      <p style="font-size: 15px;">Hemos recibido una solicitud para restablecer la contraseña de tu cuenta en <strong>Romio</strong>.</p>
      <p style="font-size: 15px;">Ingresa el siguiente código de verificación en la aplicación:</p>
      
      <div style="text-align: center; margin: 32px 0;">
        <span style="background-color: #6D0B3E; color: #FFFFFF; padding: 16px 32px; border-radius: 12px; font-size: 32px; font-weight: 700; letter-spacing: 8px; display: inline-block;">
          {{ .Token }}
        </span>
      </div>
      
      <div style="background: #FDF0F5; border-radius: 12px; padding: 16px; margin: 24px 0; border-left: 4px solid #6D0B3E;">
        <p style="font-size: 13px; color: #6B6B6B; margin: 0;">⏱ Este código es válido por tiempo limitado.</p>
      </div>
      
      <p style="font-size: 13px; color: #6B6B6B;">Si no solicitaste este cambio, puedes ignorar este correo.</p>
      
      <p style="font-size: 15px; margin-top: 32px;">Con cariño,<br><strong>Equipo Romio</strong></p>
    </div>
    
    <!-- Footer -->
    <div style="background: #F7F7F7; padding: 24px 32px; text-align: center; border-top: 1px solid #E8D5DE;">
      <p style="font-size: 12px; color: #6B6B6B; margin: 4px 0;">Romio App</p>
      <p style="font-size: 12px; color: #6B6B6B; margin: 4px 0;">🔒 Romio protege tus datos personales.</p>
      <p style="font-size: 11px; color: #B3B3B3; margin-top: 12px;">© 2025 Romio. Todos los derechos reservados.</p>
    </div>
  </div>
</body>
</html>
```

---

## How to Apply

1. Go to **Supabase Dashboard** → **Authentication** → **Email Templates**
2. For **Confirm signup**: Paste the first HTML template and set the subject to `Verifica tu cuenta en Romio`
3. For **Reset password**: Paste the second HTML template and set the subject to `Restablece tu contraseña en Romio`. Ensure the template uses `{{ .Token }}` for the mobile OTP flow.
4. Click **Save** for each template
5. The SMTP settings you've already configured (smtp.porkbun.app:587) will route these through your custom SMTP server

## Mobile forgot-password flow

1. User enters email → `resetPasswordForEmail()` sends the OTP via Supabase Auth email
2. User enters the verification code → `verifyOTP(type: recovery)` creates a recovery session
3. User sets a new password → `updateUser({ password })` then signs out and returns to login
