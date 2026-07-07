-- Migration: per-slot pricing for rooms.
--
-- Each room can now have a distinct price for the 3h, 6h and 24h booking
-- slots the mobile app offers. The existing `price_per_hour` column is kept
-- (used as an hourly fallback and for the "from" price on listings).
--
-- Run this in the Supabase SQL editor (or `supabase db push`).

ALTER TABLE public.rooms
  ADD COLUMN IF NOT EXISTS price_3h  numeric,
  ADD COLUMN IF NOT EXISTS price_6h  numeric,
  ADD COLUMN IF NOT EXISTS price_24h numeric;

-- Backfill previously-added rooms: auto-calculate each slot from the existing
-- hourly rate (price_per_hour × hours). Only fills rows that don't have a
-- value yet, so it is safe to re-run.
UPDATE public.rooms SET
  price_3h  = COALESCE(price_3h,  ROUND(price_per_hour * 3,  2)),
  price_6h  = COALESCE(price_6h,  ROUND(price_per_hour * 6,  2)),
  price_24h = COALESCE(price_24h, ROUND(price_per_hour * 24, 2));

COMMENT ON COLUMN public.rooms.price_3h  IS 'Price for a 3-hour booking slot.';
COMMENT ON COLUMN public.rooms.price_6h  IS 'Price for a 6-hour booking slot.';
COMMENT ON COLUMN public.rooms.price_24h IS 'Price for a 24-hour booking slot.';
