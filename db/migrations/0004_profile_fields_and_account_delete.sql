-- Migration: personal-info fields (city, phone) + full account deletion.
--
-- 1. Adds `city` and `phone` columns to profiles so the mobile "Datos
--    personales" screen can persist every field shown in the design.
-- 2. Adds a SECURITY DEFINER function `delete_current_user()` that lets an
--    authenticated user permanently delete their own account — their payments,
--    reservations, profile row and the auth.users record — in a single call.
--
-- Run this against the Supabase project (SQL editor or `supabase db push`).

-- 1. New profile columns -----------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS city  TEXT,
  ADD COLUMN IF NOT EXISTS phone TEXT;

COMMENT ON COLUMN public.profiles.city  IS 'City shown/edited in the mobile personal-info screen.';
COMMENT ON COLUMN public.profiles.phone IS 'Contact phone shown/edited in the mobile personal-info screen.';

-- 2. Self-service account deletion ------------------------------------------
-- SECURITY DEFINER so it can remove the auth.users row, but it only ever
-- touches data belonging to the caller (auth.uid()), so a user can delete
-- their own account and nobody else's.
CREATE OR REPLACE FUNCTION public.delete_current_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  pid uuid;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT id INTO pid FROM public.profiles WHERE user_id = uid;

  IF pid IS NOT NULL THEN
    DELETE FROM public.payments
      WHERE reservation_id IN (
        SELECT id FROM public.reservations WHERE profile_id = pid
      );
    DELETE FROM public.reservations WHERE profile_id = pid;
    DELETE FROM public.profiles WHERE id = pid;
  END IF;

  -- Removing the auth user invalidates the session and completes deletion.
  DELETE FROM auth.users WHERE id = uid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_current_user() TO authenticated;
