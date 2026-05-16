# 🏨 Romio — Hotel Booking Platform

> **Kickoff Brief for the Development Team**
> Version 1.0 · May 2026 · Confidential

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Scope & Deliverables](#2-scope--deliverables)
3. [Repository Structure](#3-repository-structure)
4. [Tech Stack](#4-tech-stack)
5. [Localization](#5-localization)
6. [Theme System](#6-theme-system)
7. [Database & Supabase](#7-database--supabase)
8. [Mobile Application](#8-mobile-application-ios--android)
9. [Web Admin Panel](#9-web-admin-panel)
10. [Architecture Guidelines](#10-architecture-guidelines)
11. [Testing Requirements](#11-testing-requirements)
12. [Non-Negotiable Rules](#12-non-negotiable-rules)
13. [Attached Reference Materials](#13-attached-reference-materials)

---

## 1. Project Overview

**Romio** is a hotel booking platform focused on **hourly room reservations** — users browse hotels, select a room, pick a date, check-in time, and duration (in hours), then pay. The platform is built in a **single Flutter monorepo** that produces two distinct products:

| Product | Audience | Platform |
|---|---|---|
| **Romio Mobile App** | End users (guests) | iOS & Android |
| **Romio Web Admin Panel** | Hotel operators & internal admins | Web (Flutter Web) |

Both products share a single **Supabase** backend (PostgreSQL + Auth + Storage + Realtime) and a single `pubspec.yaml`. The mobile and web targets are completely separated by folder structure, routing, and entry points — they share only domain models, repository interfaces, and core utilities.

### What Romio Does (Mobile App)
- Browse hotels by recommendation or full listing, with ratings, location, and price per 3-hour block displayed.
- View hotel detail — photo carousel, amenities (Wifi, Private Parking, Private Access, Jacuzzi, etc.), room list.
- View room detail — photo carousel, room-specific amenities (King Bed, AC, Water Heater, etc.), price, and a "Reservar Ahora" CTA.
- Book a room — pick date from calendar, pick check-in time slot (14:00–22:00), pick duration in hours with a stepper, see cost summary, and proceed to payment.
- Pay — choose payment method (Credit/Debit Card, PayPal, Pago Chinchin) and confirm.
- View bookings — upcoming reservations with "Recuérdamelo" (reminder) toggle, hotel name, address, check-in/check-out times; empty state when nothing booked.
- Manage profile — personal information, payment method, language preference, contact support, FAQ, terms and conditions, logout.
- Offline state handling — graceful no-connection screen.

---

## 2. Scope & Deliverables

### Mobile App (MVP)
- [x] Splash screen
- [x] Onboarding (2 screens)
- [x] Login / Sign Up / Password Recovery (3-step: email → OTP → new password)
- [x] Home — recommended hotels carousel + full hotel list
- [x] Hotel Detail — photos, amenities, room selector
- [x] Room Detail — photos, amenities, price, book CTA
- [x] Reservation flow — date picker, time selector, duration stepper, cost summary
- [x] Payment — method selector, confirm & pay
- [x] Booking Confirmation screen
- [x] My Reservations — upcoming list + empty state
- [x] Profile — personal info, payment method, language, support, FAQ, T&C, logout
- [x] Offline state screen
- [x] Save / favourite hotel (bookmark icon)

### Web Admin Panel (MVP — no existing designs; team designs from spec below)
- [ ] Admin login
- [ ] Dashboard — KPIs and charts
- [ ] Hotels management — CRUD with amenity assignment and image upload
- [ ] Rooms management — CRUD per hotel with amenity assignment and image upload
- [ ] Amenities management — master list CRUD
- [ ] Reservations — full list, filtering, status management
- [ ] Users — owner list, profile view
- [ ] Analytics — revenue, bookings, popular hotels
- [ ] Admin user management (super admin only)

---

## 3. Repository Structure

The monorepo separates mobile and web concerns at the folder level. **`lib/mobile/` and `lib/web/` must never import from each other.** Only `lib/core/` and `lib/domain/` are shared.

```
romio/
├── lib/
│   ├── core/                          # Shared utilities, extensions, constants
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # Single source of truth for all color tokens
│   │   │   └── app_text_styles.dart   # Named text styles referencing tokens
│   │   ├── extensions/                # BuildContext, String, DateTime extensions
│   │   └── utils/                     # Validators, formatters, connectivity helper
│   │
│   ├── domain/
│   │   ├── config/
│   │   │   ├── supabase_config.dart   # Supabase URL, anon key (from env)
│   │   │   └── table_names.dart       # All Supabase table name constants
│   │   ├── models/                    # Shared Dart models with toJson/fromJson
│   │   │   ├── profile.dart
│   │   │   ├── hotel.dart
│   │   │   ├── room.dart
│   │   │   ├── amenity.dart
│   │   │   ├── reservation.dart
│   │   │   ├── payment.dart
│   │   │   ├── payment_method.dart
│   │   │   └── reservation_reminder.dart
│   │   └── repositories/              # Abstract interfaces + Supabase implementations
│   │       ├── auth_repository.dart
│   │       ├── hotel_repository.dart
│   │       ├── room_repository.dart
│   │       ├── reservation_repository.dart
│   │       ├── payment_repository.dart
│   │       └── profile_repository.dart
│   │
│   ├── mobile/                        # ★ MOBILE ONLY — never imported by web/
│   │   ├── main_mobile.dart           # Mobile entry point
│   │   ├── app_mobile.dart            # MaterialApp + mobile GoRouter config
│   │   ├── theme/
│   │   │   └── mobile_theme.dart      # Light + dark ThemeData for mobile
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── hotel_provider.dart
│   │   │   ├── reservation_provider.dart
│   │   │   └── profile_provider.dart
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   ├── onboarding/
│   │   │   ├── auth/                  # login, signup, forgot_password, reset_password, otp
│   │   │   ├── home/                  # home_screen, hotel_detail, room_detail
│   │   │   ├── reservation/           # reservation_screen, payment_screen, confirmation_screen
│   │   │   ├── my_reservations/       # reservations_screen (list + empty state)
│   │   │   ├── profile/               # profile_screen, personal_info, payment_method, language
│   │   │   └── offline/               # offline_state_screen
│   │   └── widgets/                   # Mobile-specific reusable widgets
│   │       ├── hotel_card.dart
│   │       ├── room_card.dart
│   │       ├── time_slot_picker.dart
│   │       ├── duration_stepper.dart
│   │       ├── bottom_nav_bar.dart
│   │       └── photo_carousel.dart
│   │
│   ├── web/                           # ★ WEB ADMIN ONLY — never imported by mobile/
│   │   ├── main_web.dart              # Web entry point
│   │   ├── app_web.dart               # MaterialApp + web GoRouter config + admin guard
│   │   ├── theme/
│   │   │   └── web_theme.dart         # Light + dark ThemeData for web admin
│   │   ├── providers/
│   │   │   ├── admin_auth_provider.dart
│   │   │   ├── hotel_admin_provider.dart
│   │   │   ├── reservation_admin_provider.dart
│   │   │   └── analytics_provider.dart
│   │   ├── screens/
│   │   │   ├── auth/                  # admin_login_screen
│   │   │   ├── dashboard/
│   │   │   ├── hotels/                # hotel_list, hotel_form, hotel_detail
│   │   │   ├── rooms/                 # room_list, room_form
│   │   │   ├── amenities/             # amenity_list, amenity_form
│   │   │   ├── reservations/          # reservation_list, reservation_detail
│   │   │   ├── users/                 # user_list, user_detail
│   │   │   ├── analytics/
│   │   │   └── settings/              # admin_user_management (super_admin only)
│   │   └── widgets/                   # Admin-specific widgets
│   │       ├── sidebar.dart
│   │       ├── admin_data_table.dart
│   │       ├── kpi_card.dart
│   │       ├── stat_chart.dart
│   │       └── image_upload_field.dart
│   │
│   └── l10n/                          # Shared localization files
│       ├── app_es.arb                 # Spanish (primary/default)
│       └── app_en.arb                 # English
│
├── web/                               # Flutter web build assets (index.html, favicon)
├── android/                           # Android build config
├── ios/                               # iOS build config
├── test/
│   ├── mobile/                        # Mobile unit + widget tests
│   └── web/                           # Web admin unit + widget tests
├── supabase/
│   ├── schema_v3.sql                  # Full DB schema (attached)
│   └── functions/                     # Edge function stubs
├── l10n.yaml                          # flutter gen-l10n config
└── pubspec.yaml
```

### Running Each Target

```bash
# Mobile (iOS Simulator or Android Emulator)
flutter run -t lib/mobile/main_mobile.dart

# Web Admin (Chrome)
flutter run -d chrome -t lib/web/main_web.dart

# Build mobile release
flutter build apk -t lib/mobile/main_mobile.dart
flutter build ios -t lib/mobile/main_mobile.dart

# Build web release
flutter build web -t lib/web/main_web.dart
```

---

## 4. Tech Stack

| Layer | Mobile | Web Admin |
|---|---|---|
| Framework | Flutter (latest stable) | Flutter Web (same SDK) |
| State management | Provider 6.x | Provider 6.x |
| Routing | go_router (mobile routes + guards) | go_router (web routes + admin guards) |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) | Same Supabase project |
| Supabase SDK | `supabase_flutter: ^2.0.0` | `supabase_flutter: ^2.0.0` |
| Localization | `flutter_localizations` + `intl: ^0.20.2` | Same `.arb` files |
| Image handling | `image_picker` + `cached_network_image` | `file_picker` (web) + `Image.network` |
| Notifications | `flutter_local_notifications` (reminder toggle) | N/A |
| Connectivity | `connectivity_plus` | N/A |
| Charts / analytics | N/A | `fl_chart` |
| Payments | Stub — Supabase Edge Function for processing | View-only in admin |
| Local cache | `shared_preferences` (session + language pref) | N/A |

### Key Dependencies (`pubspec.yaml` excerpt)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Backend
  supabase_flutter: ^2.0.0

  # State & routing
  provider: ^6.1.2
  go_router: ^14.0.0

  # Images
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  file_picker: ^8.1.2        # web image upload

  # Utilities
  intl: ^0.20.2
  connectivity_plus: ^6.0.3
  shared_preferences: ^2.3.2

  # Notifications (mobile)
  flutter_local_notifications: ^17.2.3

  # Charts (web)
  fl_chart: ^0.69.0

  # QR (future — reservation deep link)
  qr_flutter: ^4.1.0

flutter:
  generate: true             # required for l10n code generation
```

---

## 5. Localization

Localization is **mandatory from day one**. Zero hardcoded user-facing strings are permitted anywhere in the codebase. All text must reference a key from the `.arb` file.

### Supported Languages (MVP)

| Code | Language | Status |
|---|---|---|
| `es` | Spanish | ✅ Primary / Default |
| `en` | English | ✅ MVP |

> The app UI is primarily in Spanish (as visible in all screen designs). English is a full supported locale. The architecture must make adding further languages require only a new `.arb` file.

### `l10n.yaml`

```yaml
arb-dir: lib/l10n
template-arb-file: app_es.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: false
```

### Rules

- Run `flutter gen-l10n` after any `.arb` change. Generated files go to `lib/generated/`.
- Access strings via `AppLocalizations.of(context)!.keyName` — never abbreviate.
- All date formatting must use `intl` `DateFormat` — never `.toString()` on a `DateTime`.
- All number/currency formatting must use `intl` `NumberFormat`.
- The user's language preference is saved to `profiles.preferred_language` in Supabase and applied on login.
- The language selector in the Profile tab triggers an immediate locale change via `Provider` and persists to Supabase.
- Both the mobile app and the web admin panel use the same `.arb` files. Admin-only strings get their own keys (e.g., `adminDashboardTitle`).

### `.arb` Key Naming Convention

```
screen_elementType_description
```

Examples:
```json
"homeRecommendedTitle": "Recomendado",
"hotelDetailAmenitiesTitle": "Lo que ofrecemos",
"reservationCheckInLabel": "Hora de entrada",
"reservationDurationLabel": "Duración (horas)",
"paymentMethodCardOption": "Tarjeta de crédito/débito",
"profileLanguageTitle": "Idioma",
"errorNoInternetTitle": "Sin conexión",
"errorNoInternetBody": "Parece que no tienes acceso a internet en este momento"
```

---

## 6. Theme System

Themes live in dedicated files per target. Both share a single token file. **No hex color values are permitted anywhere outside `app_colors.dart`.**

### 6.1 Design Tokens — `lib/core/theme/app_colors.dart`

| Token | Hex | Usage |
|---|---|---|
| `primaryBurgundy` | `#6D0B3E` | Primary buttons, active tab indicator, key headings |
| `primaryBurgundyLight` | `#8B1A5A` | Button hover state, card accents |
| `backgroundPink` | `#FDF0F5` | Scaffold background (mobile) |
| `backgroundWhite` | `#FFFFFF` | Cards, bottom sheet, form fields |
| `surfaceLight` | `#F8E8EF` | Inactive tab bg, secondary card bg |
| `textPrimary` | `#1A1A1A` | All body text |
| `textSecondary` | `#6B6B6B` | Subtitles, hints, metadata |
| `textOnPrimary` | `#FFFFFF` | Text on burgundy buttons |
| `borderLight` | `#E8D5DE` | Input field borders, dividers |
| `starRating` | `#E8A020` | Star rating icons |
| `success` | `#4CAF50` | Booking confirmed, active status |
| `warning` | `#FF9800` | Pending status |
| `error` | `#F44336` | Form errors, failed payment |
| `iconDefault` | `#5A3547` | Nav bar icons (inactive) |
| `iconActive` | `#6D0B3E` | Nav bar icons (active) |

> **Web admin** additionally uses `adminSidebarBg: #2D1B29`, `adminSidebarText: #E8D5DE`, and `adminTableHeaderBg: #F8E8EF` — all defined in `app_colors.dart` and referenced only from `web_theme.dart`.

### 6.2 Theme Files

**`lib/mobile/theme/mobile_theme.dart`**
- Font: `Nunito` (rounded, matches the design aesthetic)
- `ThemeData.light()` using burgundy/pink tokens
- `ThemeData.dark()` — dark scaffold with pink accents
- `CardTheme`: `borderRadius: 16`, `elevation: 0`, light pink tint
- `InputDecorationTheme`: rounded border (`borderRadius: 12`), `borderColor: borderLight`
- `ElevatedButtonTheme`: full-width, height 56, `borderRadius: 28`, `backgroundColor: primaryBurgundy`
- `BottomNavigationBarTheme`: white bg, burgundy selected, grey unselected, no elevation line
- `AppBarTheme`: transparent, no elevation, back arrow in burgundy

**`lib/web/theme/web_theme.dart`**
- Font: `Inter` (data-dense, professional)
- `ThemeData.light()` — white content area, pink sidebar
- `ThemeData.dark()` — dark sidebar, dark content area
- `DataTableTheme`: pink header rows, alternating light row bg
- `ElevatedButtonTheme`: standard height 44, `borderRadius: 8`
- `CardTheme`: `borderRadius: 8`, subtle border

**`lib/core/theme/app_text_styles.dart`**

```dart
// Named styles — both themes reference these
static const headingXL  = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
static const headingL   = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
static const headingM   = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
static const headingS   = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
static const bodyL      = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
static const bodyM      = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
static const bodyS      = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
static const labelM     = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
static const caption    = TextStyle(fontSize: 11, fontWeight: FontWeight.w400);
static const price      = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
```

### 6.3 ThemeProvider

`ThemeProvider` (in both `lib/mobile/providers/` and `lib/web/providers/`) stores `ThemeMode`. User preference is saved in `shared_preferences` locally and synced to `profiles.theme_preference` in Supabase on change.

---

## 7. Database & Supabase

> **Full schema SQL, ERD PNG, and RLS policies are provided as separate attachments.**
> `romio_schema_v3.sql` and `romio_erd.png` are the single source of truth for the database.
> Do not make ad-hoc schema changes in the Supabase dashboard — all changes must go through the SQL file and be committed to the repo.

### 7.1 Supabase Project Setup Order

1. Create Supabase project.
2. Run `supabase/schema_v3.sql` in the SQL editor — this creates all tables, RLS policies, storage buckets, triggers, indexes, and admin views in the correct dependency order.
3. Set environment variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) in the Flutter app via a `.env` file (loaded at build time — never hardcode keys).
4. Verify storage buckets `hotel-images` and `room-images` are created and set to public.
5. Create the first `super_admin` user manually in the `admin_users` table after signing up.

### 7.2 Storage Buckets

| Bucket | Access | Used For |
|---|---|---|
| `hotel-images` | Public read, admin write | Hotel hero image + carousel photos |
| `room-images` | Public read, admin write | Room hero image + carousel photos |

Image URL pattern saved in DB:
```
https://<project>.supabase.co/storage/v1/object/public/hotel-images/<filename>
```

Only the full public URL is stored in the database column. Raw binary is never stored in the database.

### 7.3 Table Summary

| Table | Purpose |
|---|---|
| `profiles` | Guest profile; auto-created on `auth.users` signup via trigger |
| `admin_users` | Identifies admin portal users; role: `super_admin` or `hotel_manager` |
| `hotels` | Hotel catalog (name, description, address, lat/lng, rating, cover image) |
| `hotel_images` | Hotel photo carousel (storage URLs + sort order) |
| `amenities` | Master amenity list (admin-managed; `applies_to`: hotel / room / both) |
| `hotel_amenities` | Junction: which amenities a hotel offers |
| `rooms` | Rooms per hotel (name, price_per_hour, status, cover image) |
| `room_images` | Room photo carousel (storage URLs + sort order) |
| `room_amenities` | Junction: which amenities a room has |
| `reservations` | Booking records (date, check-in time, duration, total price, status, code) |
| `payments` | Payment per reservation (provider, amount, status, gateway reference) |
| `payment_methods` | Saved payment methods per user (display label + opaque provider token only) |
| `reservation_reminders` | Powers the "Recuérdamelo" toggle (remind_at timestamp, sent flag) |
| `saved_hotels` | Bookmarked hotels per user (heart icon) |

### 7.4 Row Level Security Summary

- **All tables** have RLS enabled. Default is deny-all; explicit policies grant access.
- **Profiles / Reservations / Payments / Payment methods / Reminders / Saved hotels:** Users may only read/write their own rows (`auth.uid()` match).
- **Hotels / Rooms / Amenities / Images:** Public `SELECT`; admin-only `INSERT`, `UPDATE`, `DELETE`.
- **Admin users:** Only `super_admin` role can manage the `admin_users` table.
- **Storage buckets:** Admin-only upload/update/delete via `is_admin()` function check.

### 7.5 Admin Helper Function

The `is_admin(uid UUID)` function is used throughout all admin-scope RLS policies:

```sql
CREATE OR REPLACE FUNCTION public.is_admin(uid UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = uid AND is_active = TRUE
  );
$$ LANGUAGE sql SECURITY DEFINER;
```

---

## 8. Mobile Application (iOS & Android)

All screens live in `lib/mobile/screens/`. Routing is handled by `go_router` with guards for authenticated vs. unauthenticated states.

### 8.1 Navigation Structure

```
BottomNavigationBar (3 tabs):
  ├── Inicio (Home)       → /home
  ├── Reserva             → /reservations
  └── Perfil              → /profile
```

`ShellRoute` wraps the bottom nav. Any unauthenticated deep-link attempt redirects to `/login`.

### 8.2 Screen Inventory

#### Authentication & Onboarding

| Screen | Route | Notes |
|---|---|---|
| Splash | `/` | Logo on burgundy background; checks Supabase session; redirects to `/onboarding` or `/home` |
| Onboarding 1 | `/onboarding` | Full-bleed hotel photo, title "Reserva", subtitle, "Siguiente" button, 2-dot page indicator |
| Onboarding 2 | `/onboarding` (page 2) | Full-bleed hotel photo (California Suites), title "Pagos 100% seguros", "Empezar" button |
| Login | `/login` | Email + password fields, "Iniciar sesión" CTA, "¿Olvidaste tu contraseña?" link, "¿Eres nuevo en Romio? Crea una cuenta." link, Romio watermark at bottom |
| Sign Up | `/signup` | Nombre inicial, Apellido (2-column), email, password (with show/hide toggle), confirm password (with show/hide toggle), date of birth, billing address (2-column), T&C disclaimer, "Registrarse" button |
| Register Confirmation | Pop-up overlay on Sign Up | Green checkmark, "Todo listo", "Tu cuenta se ha creado correctamente", "Iniciar sesión" button |
| Password Recovery 1 | `/forgot-password` | "Recupera tu contraseña" heading, email field, "Solicitar código" button |
| Password Recovery 2 | `/verify-otp` | "Código de verificación" heading, 4-box OTP input, "Validar" button, "¿No recibiste el código? Reenviar." link |
| Password Recovery 3 | `/reset-password` | "Nueva contraseña" heading, email (pre-filled read-only), new password, confirm password, "Iniciar Sesión" button |

#### Home Tab

| Screen | Route | Notes |
|---|---|---|
| Home | `/home` | Greeting "¡Hola, {name}!", "Encuentre su mejor hotel" title; horizontal scrollable "Recomendado" card carousel (hotel photo, name, location, rating chip, price); "Todos los hoteles" vertical list (thumbnail, name, amenities chips, address, rating, price). Heart/bookmark icon on each card. |
| Hotel Detail | `/hotel/:id` | Back arrow + bookmark icon in top corners over full-bleed photo carousel (4-dot indicator); hotel name, address with pin icon, star rating; "Acerca del hotel" description; "Lo que ofrecemos" amenity icon grid (Wifi, Parking Privado, Acceso Privado, Jacuzzi, etc.); "Seleccionar habitación" room list (thumbnail, name, amenities, price). |
| Room Detail | `/hotel/:hotelId/room/:roomId` | Same photo carousel pattern; room name; hotel name + rating; "Acerca del hotel" description; "Lo que ofrecemos" room amenity icons (Wifi, King Bed, AC, Water Heater); sticky bottom bar: "Precio $50/3 Horas" + "Reservar Ahora" button. |

#### Reservation Flow

| Screen | Route | Notes |
|---|---|---|
| Reservation | `/reservation/:roomId` | "Reserva" title; "Seleccionar fecha" — full calendar month view (arrow to next month); "Hora de entrada" — 3×3 grid of time chips (14:00–22:00); "Duración (horas)" — minus/plus stepper with current value; cost summary row ("1 Habitación · $50"); cancellation policy note; "Continuar con el pago" sticky button. |
| Payment | `/payment/:reservationId` | "Método de pago" title + "Seleccione un método de pago para garantizar su reserva privada." subtitle; 3 radio-button options: Tarjeta de crédito/débito (credit card icon), Paypal (PayPal logo), Pago Chinchin (brand icon); "Pagar y confirmar" sticky button. |
| Booking Confirmation | `/confirmation` | Green checkmark circle; "Reserva confirmada" heading; "Tu espacio es seguro y privado." subtitle; detail card (Reservation ID: #RM-XXXX, Habitación, Check In time, Check Out time); "Volver a la página de inicio" button. |

#### Reservations Tab

| Screen | Route | Notes |
|---|---|---|
| My Reservations (empty) | `/reservations` | "Mi Reserva" title; empty state: calendar-X icon, "Nada planeado", "No tiene ninguna reserva próxima". |
| My Reservations (with bookings) | `/reservations` | "Próximamente" section label; reservation card: date + time, hotel name, address, "Recuérdamelo" toggle (on/off), room name, Check In / Check Out times in 2-column layout. |

#### Profile Tab

| Screen | Route | Notes |
|---|---|---|
| Profile | `/profile` | User name as title, "Gestiona tu cuenta" subtitle; **Cuenta** section: "Información personal" →, "Método de pago" →, "Idioma" →; **Support** section: "Contacto" →, "FAQ" →, "Términos y Condiciones" →; Logout (implied — add to bottom of list). |
| Personal Information | `/profile/personal-info` | Edit form for first name, last name, email, phone. |
| Payment Method | `/profile/payment-method` | Saved payment methods list; add new method. |
| Language | `/profile/language` | Radio list: Español, English. Change triggers locale switch immediately + saves to Supabase. |

#### System Screens

| Screen | Notes |
|---|---|
| Offline State | Wifi-off icon, "Sin conexión" heading, "Parece que no tienes acceso a internet en este momento" body. Displayed as overlay/replacement when `connectivity_plus` detects no network. |

### 8.3 Reservation Flow — Business Logic

```
Room Detail
  └─→ Reservation Screen
        ├── User selects: date (calendar)
        ├── User selects: check-in time slot (14:00–22:00, hourly chips)
        ├── User sets: duration in hours (stepper, min 1)
        ├── App computes: check_out_time = check_in_time + duration_hours
        ├── App computes: total_price = price_per_hour × duration_hours
        └─→ Payment Screen
              ├── User selects: payment method
              └─→ [Supabase: INSERT into reservations + INSERT into payments]
                    └─→ Confirmation Screen
```

**Cancellation policy:** User can cancel up to 24 hours before check-in at no cost. Display copy "Recuerda que puedes cancelar hasta 24h antes del check in sin compromiso" on the reservation screen.

### 8.4 Reminder Toggle ("Recuérdamelo")

- The toggle maps to `reservation_reminders.is_enabled`.
- When toggled ON: compute `remind_at = reservation_date + check_in_time - 1 hour`; update row; schedule a local notification via `flutter_local_notifications`.
- When toggled OFF: cancel the scheduled notification; update `is_enabled = false`.
- Notification copy must be localized.

---

## 9. Web Admin Panel

The admin panel is a management interface for hotel operators and internal Romio staff. It shares the Supabase backend but uses a completely separate Flutter Web entry point, router, and theme.

> **No UI designs exist for the web admin panel.** The development team must design and implement a clean, functional admin layout following the color tokens in Section 6 and the screen spec below. Expected layout pattern: **persistent left sidebar + top app bar + scrollable content area**, similar to standard SaaS admin dashboards.

### 9.1 Admin Layout Shell

- **Left sidebar** (width: 240px, collapsible to icon-only at 72px): Romio logo/wordmark at top, navigation links with icons, user avatar + name at bottom.
- **Top app bar**: Current page breadcrumb, language toggle (ES/EN), theme toggle (light/dark), notifications bell (future), admin avatar + logout.
- **Content area**: Full-width, responsive. Tables paginate at 25 rows. Forms use 2-column layout on wide screens, single-column on narrow.
- **All sidebar links and content labels must be localized.**

### 9.2 Admin Guard

Every route in the web admin must run the admin check:

```dart
// In go_router redirect:
final isAdmin = await AdminAuthProvider.checkAdminAccess(supabase.auth.currentUser?.id);
if (!isAdmin) return '/admin/login';
```

`super_admin` pages (Settings) additionally check `role == 'super_admin'` and redirect to Dashboard if not met.

### 9.3 Admin Screen Map

#### Login — `/admin/login`
- Clean centered card. Romio logo, email + password fields, "Iniciar sesión" button.
- On success: check `admin_users` table. If no record → show "Acceso denegado" error and sign out.
- On success with valid admin record → redirect to `/admin/dashboard`.

---

#### Dashboard — `/admin/dashboard`
**KPI cards (top row):**
- Total active hotels
- Total rooms
- Total registered users
- Reservations this month
- Revenue this month (sum of `payments.amount` where `status = 'completed'`)

**Charts:**
- Line chart: New user registrations (last 30 days, daily)
- Bar chart: Reservations by status (`pending`, `confirmed`, `cancelled`, `completed`)
- Bar chart: Revenue by hotel (top 5)

**Tables:**
- Recent reservations (last 10): reservation code, guest name, hotel, room, check-in, total, status.
- Recently registered users (last 5): name, email, sign-up date.

---

#### Hotels — `/admin/hotels`

**List screen:**
- Searchable, sortable data table: Hotel Name, City, Rating, Rooms count, Active, Created At.
- Action buttons per row: Edit, View Rooms, Toggle Active.
- "Add Hotel" button (top right) → opens hotel form.
- Bulk select + bulk deactivate.

**Hotel Form (Create / Edit):**
- Name (text field)
- Description (multi-line text area)
- Address, City (text fields)
- Latitude, Longitude (number fields — for future map view)
- Cover Image upload (uploads to `hotel-images` bucket; URL saved to `hotels.cover_image_url`)
- Additional Images (multi-image upload; rows in `hotel_images` table with sort order drag-and-drop)
- Amenities selector: multi-select chip list populated from `amenities` table filtered to `applies_to IN ('hotel','both')`. Inline "Add new amenity" button opens a mini form (name + icon key) that inserts to `amenities` and immediately adds to selection.
- Active toggle
- "Save" / "Cancel" buttons

---

#### Rooms — `/admin/rooms`

**List screen (usually accessed via Hotels → View Rooms):**
- Filter by hotel (dropdown).
- Table: Room Name, Hotel, Price/hour, Rating, Status, Created At.
- Actions: Edit, Toggle Status (available / maintenance / inactive).
- "Add Room" button.

**Room Form (Create / Edit):**
- Hotel selector (dropdown)
- Room Name (text field)
- Description (multi-line)
- Price per hour (number field)
- Status (dropdown: available / maintenance / inactive)
- Cover Image upload (→ `room-images` bucket)
- Additional Images (multi-image, sort order)
- Amenities selector: multi-select chip list from `amenities` filtered to `applies_to IN ('room','both')`. Same inline "Add new amenity" capability.
- "Save" / "Cancel"

---

#### Amenities — `/admin/amenities`

**Purpose:** Admin manages the master amenity list here. Hotel and Room forms use this as the source for their pickers.

- Table: Name, Icon Key, Applies To, Created At.
- "Add Amenity" button → form: Name (es + en fields), Icon Key (maps to Flutter `Icons.*` name or SVG asset), Applies To (dropdown: hotel / room / both).
- Edit inline or via form.
- Delete (hard delete — warns if amenity is currently assigned to hotels/rooms).

---

#### Reservations — `/admin/reservations`

- Paginated table (25/page): Reservation Code, Guest Name, Hotel, Room, Date, Check-In, Check-Out, Duration, Total, Payment Status, Reservation Status, Created At.
- **Filters:** Date range picker, Hotel dropdown, Status dropdown (pending / confirmed / cancelled / completed), Payment status dropdown.
- **Row actions:** View Detail, Update Status.
- **Reservation Detail modal/page:** All fields + guest info + payment provider + payment reference. Admin can move status forward (e.g., confirmed → completed) but cannot move backward.
- Export to CSV (current filter applied).

---

#### Users — `/admin/users`

- Paginated, searchable table: Name, Email, Reservations count, Saved hotels count, Joined, Status.
- Search by name or email.
- **User Detail:** Full profile view, list of reservations (read-only), saved hotels list.
- Admin can deactivate a user (sets an `is_active` flag — this should be added to `profiles` table if not present; deactivated users cannot log in via RLS).
- **No editing of user personal data** — admins view only.

---

#### Analytics — `/admin/analytics`

All charts use `fl_chart`. All figures pull from Supabase views (`admin_reservation_overview`, `admin_revenue_by_hotel`) defined in the schema.

- **Revenue chart:** Line chart, revenue by day for selected date range (default: last 30 days). Date range picker at top.
- **Reservations chart:** Bar chart, count by status per week for last 8 weeks.
- **Top hotels:** Horizontal bar chart, top 10 hotels by total revenue.
- **Popular rooms:** Horizontal bar chart, top 10 rooms by reservation count.
- **User growth:** Area chart, cumulative users over time.
- **Payment method breakdown:** Donut chart (credit/debit, PayPal, Pago Chinchin).

---

#### Settings — `/admin/settings` *(super_admin only)*

- **Admin Users:** Table of all admin users (name, email, role, active). Add new admin: enter email → triggers Supabase invite email; assign role. Deactivate admin (sets `is_active = false`).
- **App Config (stub for MVP):** Maintenance mode toggle (stored in a `config` table — add this to schema); featured hotel ordering (drag-and-drop list of hotel IDs).

---

## 10. Architecture Guidelines

### Repository Pattern

```
Widget / Screen
    │  (calls method)
    ▼
Provider  (holds UI state: loading / data / error)
    │  (calls method on)
    ▼
Repository Interface  (abstract class in domain/repositories/)
    │  (implemented by)
    ▼
Supabase Repository Impl  (only place Supabase client is called)
    │
    ▼
Supabase PostgREST / Auth / Storage
```

**No Supabase client calls in widgets, screens, or providers. Ever.**

### Model Rules

- All models in `lib/domain/models/` are plain Dart classes.
- Every model has `fromJson(Map<String, dynamic>)` and `toJson()` matching Supabase column snake_case names exactly.
- No `Map<String, dynamic>` is passed beyond the repository layer — models only.
- Use `copyWith()` for immutable updates.

### Error Handling

```dart
class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});
}
```

All repository `catch` blocks convert `PostgrestException`, `AuthException`, and `StorageException` to `AppException`. Providers expose an `error` state. Screens display errors via `SnackBar` (mobile) or inline banner (web).

### Supabase Table Name Constants

```dart
// lib/domain/config/table_names.dart
class TableNames {
  static const profiles              = 'profiles';
  static const adminUsers            = 'admin_users';
  static const hotels                = 'hotels';
  static const hotelImages           = 'hotel_images';
  static const rooms                 = 'rooms';
  static const roomImages            = 'room_images';
  static const amenities             = 'amenities';
  static const hotelAmenities        = 'hotel_amenities';
  static const roomAmenities         = 'room_amenities';
  static const reservations          = 'reservations';
  static const payments              = 'payments';
  static const paymentMethods        = 'payment_methods';
  static const reservationReminders  = 'reservation_reminders';
  static const savedHotels           = 'saved_hotels';
}
```

No string literals like `'reservations'` anywhere outside this file.

### Provider State Shape

Every provider follows the same pattern:

```dart
class HotelProvider extends ChangeNotifier {
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  AppException? _error;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  Future<void> fetchHotels() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _hotels = await _hotelRepo.getAll();
    } on AppException catch (e) {
      _error = e;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}
```

---

## 11. Testing Requirements

### Unit Tests

- **All Providers:** loading → success → error state transitions; mock repositories.
- **All Models:** `toJson` / `fromJson` round-trip; null-safety edge cases.
- **Repository implementations:** mock Supabase client; test all CRUD paths including error paths.
- **Localization:** verify all keys present in both `app_es.arb` and `app_en.arb` (no missing keys, no extra keys in one file).

### Widget Tests

- `HotelCard`: renders name, rating, price, amenity chips; tap triggers navigation.
- `RoomCard`: renders all fields; "Reservar Ahora" button visible.
- `TimePicker` chip grid: selecting a chip marks it selected; previously selected chip deselects.
- `DurationStepper`: minus button disabled at min value; plus increments correctly; value displays in localized format.
- `OfflineStateScreen`: renders correct icon and localized strings.
- Login form: empty submit shows localized validation errors.
- Admin `DataTable`: renders paginated rows; sort column changes sort icon.

### Integration / E2E Tests

- **Mobile happy path:** Login → Home loads hotels → Tap hotel → View hotel detail → Select room → Complete reservation → See confirmation screen → View in My Reservations.
- **Auth guard:** Unauthenticated user navigating to `/home` is redirected to `/login`.
- **Language switch:** Change language to English in Profile → all visible strings switch to English → reopen app → English persists.
- **Admin happy path:** Admin login → Dashboard loads KPIs → Add hotel with images + amenities → Hotel appears in mobile app home.
- **RLS isolation:** User A's reservations are not returned when queried as User B.
- **Reminder toggle:** Toggle ON → local notification scheduled → Toggle OFF → notification cancelled.

---

## 12. Non-Negotiable Rules

The following are absolute requirements. A feature is not considered done if any of these are violated.

1. **Zero hardcoded strings.** Every user-facing string — button labels, titles, error messages, hints, empty states, notification copy — must exist as a key in `app_es.arb` and `app_en.arb`.

2. **Zero hardcoded colors.** Every color value must be a token from `app_colors.dart`. No `Color(0xFF...)` or `Colors.*` in any widget file.

3. **Strict folder isolation.** `lib/mobile/*` never imports from `lib/web/*` and vice versa. Only `lib/core/*` and `lib/domain/*` are shared.

4. **No Supabase calls outside repositories.** `Supabase.instance.client` is called only inside `lib/domain/repositories/` implementations.

5. **RLS is the security layer.** Client-side filtering is a UX optimization only — never a security boundary. If a user must not see data, the RLS policy must enforce that at the database level.

6. **Images: URLs only.** Only the public/signed Storage URL is stored in the database. Raw binary is never written to any database column.

7. **Admin route guard on every load.** The admin panel must re-verify `admin_users` membership on every navigation event, not only at login time. A deactivated admin must be bounced to `/admin/login` immediately.

8. **No ad-hoc schema changes.** All database changes must be made in `supabase/schema_v3.sql`, committed to the repo, and re-run as a migration. Never modify the schema via the Supabase dashboard UI alone.

9. **Table name constants only.** No string literal table names (`'reservations'`, `'hotels'`, etc.) outside `table_names.dart`.

10. **All providers must be tested.** A provider without a corresponding unit test file covering its state transitions is not releasable.

---

## 13. Attached Reference Materials

The following files are included alongside this README:

| File | Description |
|---|---|
| `romio_erd.png` | Full Entity-Relationship Diagram — all tables, columns, and relationships |
| `romio_schema_v3.sql` | Complete Supabase SQL — tables, RLS policies, storage bucket setup, triggers, indexes, admin views, seed data for amenities |
| `mobile_screens/` | All mobile UI screen designs (PNG exports) — see list below |

### Mobile Screen Files

| File | Screen |
|---|---|
| `Splash_Screen.png` | Splash — burgundy background, Romio wordmark |
| `On_Boarding_Screen__1.png` | Onboarding 1 — Reserva |
| `On_Boarding_Screen__2.png` | Onboarding 2 — Pagos 100% seguros |
| `Log_In_Page.png` | Login |
| `Registration_Page.png` | Sign Up |
| `Pop_Up_Register_Confirmation.png` | Registration success pop-up |
| `Password_Recovery__1.png` | Forgot password — enter email |
| `Password_Recovery__2.png` | OTP verification |
| `Password_Recovery__3.png` | Set new password |
| `Home_Page.png` | Home — hotel listing |
| `Hotel_Detail.png` | Hotel detail — amenities + room list |
| `Room_Detail.png` | Room detail — amenities + book CTA |
| `Reservation.png` | Reservation — date, time, duration, cost |
| `Payment.png` | Payment method selection |
| `Payment_Confirm.png` | Booking confirmation |
| `Reserva.png` | My Reservations — with booking |
| `Reserva__Nada_planeado.png` | My Reservations — empty state |
| `Profile_Page.png` | Profile menu |
| `Offline_state.png` | No internet connection screen |
| `PROFILE__STATE.png` | Profile state label |
| `STARTING.png` | Starting label |
| `reservation_process.png` | Reservation process flow diagram |

> Web admin panel UI designs are not yet available. The development team is expected to design and implement a functional admin interface consistent with the design tokens in Section 6 and the screen specification in Section 9.

---

*Romio Platform — Kickoff Brief · Version 1.0 · May 2026 · Confidential*
