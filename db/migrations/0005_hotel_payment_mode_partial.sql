-- Migration: three payment modes per hotel (+ partial-deposit percentages).
--
-- Replaces the legacy boolean `hotels.pay_on_property` with an explicit,
-- mutually-exclusive `payment_mode` so the admin can pick exactly one of:
--
--   'pay_at_property' -> guest reserves without paying; settles the full amount
--                        at the property (no online payment in the app).
--   'pay_at_app'      -> guest pays the full amount online up front; the booking
--                        is only reserved once payment completes.
--   'pay_partial'     -> guest pays a percentage online up front (the deposit)
--                        and the remaining balance at the property. The deposit
--                        percentage is configured per booking slot (3h/6h/24h).
--
-- The old `pay_on_property` column is kept and mirrored (true when
-- payment_mode = 'pay_at_property') so any legacy reader keeps working.
--
-- Run this in the Supabase SQL editor (or via `supabase db push`). Safe to
-- re-run.

-- ── hotels: payment mode + per-slot deposit percentages ───────────────────
ALTER TABLE public.hotels
  ADD COLUMN IF NOT EXISTS payment_mode         text    NOT NULL DEFAULT 'pay_at_app',
  ADD COLUMN IF NOT EXISTS partial_percent_3h   numeric,
  ADD COLUMN IF NOT EXISTS partial_percent_6h   numeric,
  ADD COLUMN IF NOT EXISTS partial_percent_24h  numeric;

-- Backfill: hotels that previously allowed pay-on-property become that mode.
UPDATE public.hotels
  SET payment_mode = 'pay_at_property'
  WHERE pay_on_property = true;

-- Constrain to the known modes (drop-then-add so the migration is re-runnable).
ALTER TABLE public.hotels
  DROP CONSTRAINT IF EXISTS hotels_payment_mode_check;
ALTER TABLE public.hotels
  ADD CONSTRAINT hotels_payment_mode_check
  CHECK (payment_mode IN ('pay_at_property', 'pay_at_app', 'pay_partial'));

-- The deposit percentages must be a sane 0–100 when present.
ALTER TABLE public.hotels
  DROP CONSTRAINT IF EXISTS hotels_partial_percent_range_check;
ALTER TABLE public.hotels
  ADD CONSTRAINT hotels_partial_percent_range_check
  CHECK (
    (partial_percent_3h  IS NULL OR (partial_percent_3h  >= 0 AND partial_percent_3h  <= 100)) AND
    (partial_percent_6h  IS NULL OR (partial_percent_6h  >= 0 AND partial_percent_6h  <= 100)) AND
    (partial_percent_24h IS NULL OR (partial_percent_24h >= 0 AND partial_percent_24h <= 100))
  );

COMMENT ON COLUMN public.hotels.payment_mode IS
  'How guests pay for this hotel: pay_at_property | pay_at_app | pay_partial.';
COMMENT ON COLUMN public.hotels.partial_percent_3h IS
  'Deposit % charged online for a 3h booking when payment_mode = pay_partial.';
COMMENT ON COLUMN public.hotels.partial_percent_6h IS
  'Deposit % charged online for a 6h booking when payment_mode = pay_partial.';
COMMENT ON COLUMN public.hotels.partial_percent_24h IS
  'Deposit % charged online for a 24h booking when payment_mode = pay_partial.';

-- ── reservations: record the mode + deposit / balance breakdown ────────────
-- total_price stays the full room price. For partial bookings, deposit_amount
-- is what was charged online now and balance_due is collected at the property.
ALTER TABLE public.reservations
  ADD COLUMN IF NOT EXISTS payment_mode   text,
  ADD COLUMN IF NOT EXISTS deposit_amount numeric,
  ADD COLUMN IF NOT EXISTS balance_due    numeric;

COMMENT ON COLUMN public.reservations.payment_mode IS
  'Payment mode used for this booking: pay_at_property | pay_at_app | pay_partial.';
COMMENT ON COLUMN public.reservations.deposit_amount IS
  'Amount paid online up front (full amount for pay_at_app, the deposit for pay_partial, 0 for pay_at_property).';
COMMENT ON COLUMN public.reservations.balance_due IS
  'Amount still to be collected at the property (0 for pay_at_app).';
