-- Migration: add "Pay on Property" support to hotels.
--
-- When pay_on_property is TRUE for a hotel, guests in the mobile app may
-- reserve a room without paying upfront; the booking is created and the
-- associated payment row is recorded with provider = 'pay_on_property' and
-- status = 'pending' (collected at the property on arrival).
--
-- Run this against the Supabase project (SQL editor or `supabase db push`).

ALTER TABLE public.hotels
  ADD COLUMN IF NOT EXISTS pay_on_property BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.hotels.pay_on_property IS
  'If true, guests can reserve without paying upfront and settle at the property.';

-- NOTE: the payments table has a CHECK constraint on `provider` that must be
-- widened to accept the new 'card' / 'pay_on_property' values. That is handled
-- in the next migration: 0002_payments_provider_constraint.sql. Run both.
