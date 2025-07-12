-- SUPABASE TABLE CLEANUP COMMANDS
-- Run these commands in your Supabase SQL Editor in order
-- This will clean up your espresso_machines table to have the correct columns

-- STEP 1: Add the dimensions column if it doesn't exist
ALTER TABLE public.espresso_machines 
ADD COLUMN IF NOT EXISTS dimensions TEXT;

-- STEP 2: Populate dimensions column from existing dimensions_in data if available
-- Only run this if dimensions_in column exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'espresso_machines' 
               AND column_name = 'dimensions_in' 
               AND table_schema = 'public') THEN
        UPDATE public.espresso_machines 
        SET dimensions = dimensions_in
        WHERE dimensions IS NULL AND dimensions_in IS NOT NULL;
    END IF;
END $$;

-- STEP 3: Drop all the old/duplicate columns we don't need
ALTER TABLE public.espresso_machines 
DROP COLUMN IF EXISTS price_msrp,
DROP COLUMN IF EXISTS boiler,
DROP COLUMN IF EXISTS pid,
DROP COLUMN IF EXISTS pid_adjustable,
DROP COLUMN IF EXISTS pre_infusion,
DROP COLUMN IF EXISTS pump,
DROP COLUMN IF EXISTS flow_control,
DROP COLUMN IF EXISTS opv_adjustable,
DROP COLUMN IF EXISTS steam_brew_same,
DROP COLUMN IF EXISTS reservoir_ml,
DROP COLUMN IF EXISTS plumbable,
DROP COLUMN IF EXISTS dimensions_in,
DROP COLUMN IF EXISTS skill_level,
DROP COLUMN IF EXISTS affiliate;

-- STEP 4: Ensure we have all required columns from PRD
-- Add any missing columns that should exist

-- Core identification (should already exist)
ALTER TABLE public.espresso_machines 
ALTER COLUMN id SET DATA TYPE TEXT;

-- Add missing columns if they don't exist
ALTER TABLE public.espresso_machines 
ADD COLUMN IF NOT EXISTS model_name TEXT,
ADD COLUMN IF NOT EXISTS release_year INTEGER CHECK (release_year >= 1980),
ADD COLUMN IF NOT EXISTS machine_type TEXT NOT NULL DEFAULT 'Semi-Automatic',
ADD COLUMN IF NOT EXISTS price_usd NUMERIC(10,2),
ADD COLUMN IF NOT EXISTS vendors JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS boiler_type TEXT,
ADD COLUMN IF NOT EXISTS heat_up_seconds INTEGER,
ADD COLUMN IF NOT EXISTS has_pid BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS built_in_grinder TEXT CHECK (built_in_grinder IN ('built-in', 'external', 'none')),
ADD COLUMN IF NOT EXISTS pre_infusion_type TEXT CHECK (pre_infusion_type IN ('none', 'mechanical', 'programmable')),
ADD COLUMN IF NOT EXISTS portafilter_mm INTEGER,
ADD COLUMN IF NOT EXISTS steam_wand_type TEXT,
ADD COLUMN IF NOT EXISTS is_plumbable BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS water_tank_l NUMERIC(4,2),
ADD COLUMN IF NOT EXISTS has_water_filter BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS weight_lbs NUMERIC(5,2),
ADD COLUMN IF NOT EXISTS power_watts INTEGER,
ADD COLUMN IF NOT EXISTS build_material TEXT,
ADD COLUMN IF NOT EXISTS warranty_years INTEGER;

-- STEP 5: Update the search vector column
ALTER TABLE public.espresso_machines 
DROP COLUMN IF EXISTS search_vec;

ALTER TABLE public.espresso_machines 
ADD COLUMN search_vec TSVECTOR GENERATED ALWAYS AS (
  to_tsvector('english', COALESCE(model_name, name, '') || ' ' || COALESCE(brand, ''))
) STORED;

-- STEP 6: Create all required indexes for performance
CREATE INDEX IF NOT EXISTS espresso_search_idx ON public.espresso_machines USING GIN (search_vec);
CREATE INDEX IF NOT EXISTS espresso_brand_idx ON public.espresso_machines (brand);
CREATE INDEX IF NOT EXISTS espresso_price_idx ON public.espresso_machines (price_usd);
CREATE INDEX IF NOT EXISTS espresso_boiler_idx ON public.espresso_machines (boiler_type);
CREATE INDEX IF NOT EXISTS espresso_pid_idx ON public.espresso_machines (has_pid);
CREATE INDEX IF NOT EXISTS espresso_grinder_idx ON public.espresso_machines (built_in_grinder);
CREATE INDEX IF NOT EXISTS espresso_type_idx ON public.espresso_machines (machine_type);
CREATE INDEX IF NOT EXISTS espresso_year_idx ON public.espresso_machines (release_year);
CREATE INDEX IF NOT EXISTS espresso_plumbable_idx ON public.espresso_machines (is_plumbable);
CREATE INDEX IF NOT EXISTS espresso_heatup_idx ON public.espresso_machines (heat_up_seconds);
CREATE INDEX IF NOT EXISTS espresso_tank_idx ON public.espresso_machines (water_tank_l);
CREATE INDEX IF NOT EXISTS espresso_warranty_idx ON public.espresso_machines (warranty_years);
CREATE INDEX IF NOT EXISTS espresso_weight_idx ON public.espresso_machines (weight_lbs);
CREATE INDEX IF NOT EXISTS espresso_power_idx ON public.espresso_machines (power_watts);

-- STEP 7: Verify the final table structure
-- Run this to see your complete table structure:
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'espresso_machines' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- STEP 8: Verify your data looks correct
SELECT id, name, brand, price_usd, boiler_type, has_pid, dimensions, asin, image_url
FROM public.espresso_machines
LIMIT 5;

-- FINAL CLEAN TABLE STRUCTURE:
-- ✓ id (text, primary key)
-- ✓ name (text) - kept for backward compatibility
-- ✓ model_name (text)
-- ✓ brand (text)
-- ✓ release_year (integer)
-- ✓ machine_type (text)
-- ✓ price_usd (numeric)
-- ✓ asin (text) - kept as requested
-- ✓ image_url (text) - kept as requested
-- ✓ vendors (jsonb)
-- ✓ boiler_type (text)
-- ✓ heat_up_seconds (integer)
-- ✓ has_pid (boolean)
-- ✓ built_in_grinder (text)
-- ✓ pre_infusion_type (text)
-- ✓ portafilter_mm (integer)
-- ✓ steam_wand_type (text)
-- ✓ is_plumbable (boolean)
-- ✓ water_tank_l (numeric)
-- ✓ has_water_filter (boolean)
-- ✓ dimensions (text) - single column for display (W x H x D format)
-- ✓ weight_lbs (numeric)
-- ✓ power_watts (integer)
-- ✓ build_material (text)
-- ✓ warranty_years (integer)
-- ✓ search_vec (tsvector, generated)

-- Clean, simple structure with just the dimensions column for display! 