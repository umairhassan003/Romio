-- Migration: allow the payment provider values the app now writes.
--
-- The mobile app writes these `payments.provider` values:
--   'paypal'           -> PayPal account payment
--   'card'             -> credit/debit card processed via PayPal
--   'pay_on_property'  -> reserved without upfront payment (collected on site)
--
-- The existing CHECK constraint `payments_provider_check` rejects the new
-- values and raises:
--   new row for relation "payments" violates check constraint
--   "payments_provider_check" (code 23514)
--
-- This migration widens the constraint. Legacy values ('credit_card',
-- 'chinchin', 'stripe', 'unknown') are kept so existing rows stay valid.
-- Run it in the Supabase SQL editor (or via `supabase db push`).

ALTER TABLE public.payments
  DROP CONSTRAINT IF EXISTS payments_provider_check;

ALTER TABLE public.payments
  ADD CONSTRAINT payments_provider_check
  CHECK (provider IN (
    'paypal',
    'card',
    'pay_on_property',
    'credit_card',
    'chinchin',
    'stripe',
    'unknown'
  ));
