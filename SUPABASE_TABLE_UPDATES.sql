-- SUPABASE TABLE UPDATES
-- Run these commands in your Supabase SQL Editor to update the espresso_machines table

-- 1. Rename pre_infusion_type to pre_infusion
ALTER TABLE public.espresso_machines 
RENAME COLUMN pre_infusion_type TO pre_infusion;

-- 2. Change pre_infusion to boolean (Yes/No)
-- First, add a temporary boolean column
ALTER TABLE public.espresso_machines 
ADD COLUMN pre_infusion_temp BOOLEAN;

-- Update the temporary column with converted values
UPDATE public.espresso_machines 
SET pre_infusion_temp = CASE 
    WHEN LOWER(pre_infusion::TEXT) IN ('yes', 'true', '1', 'manual', 'automatic', 'programmable') THEN true
    WHEN LOWER(pre_infusion::TEXT) IN ('no', 'false', '0', 'none') THEN false
    ELSE false
END;

-- Drop the old column and rename the new one
ALTER TABLE public.espresso_machines DROP COLUMN pre_infusion;
ALTER TABLE public.espresso_machines RENAME COLUMN pre_infusion_temp TO pre_infusion;

-- 3. Handle warranty columns
-- First, add warranty column if it doesn't exist
ALTER TABLE public.espresso_machines 
ADD COLUMN IF NOT EXISTS warranty TEXT;

-- If you have existing warranty_years data, migrate it to warranty text format
UPDATE public.espresso_machines 
SET warranty = COALESCE(warranty_years::TEXT || ' year warranty', warranty)
WHERE warranty IS NULL AND warranty_years IS NOT NULL;

-- Drop the existing warranty_years column if it exists and recreate it as a generated column
ALTER TABLE public.espresso_machines DROP COLUMN IF EXISTS warranty_years;

-- Add a generated column that extracts the number from warranty text
ALTER TABLE public.espresso_machines 
ADD COLUMN warranty_years INTEGER GENERATED ALWAYS AS (
    CASE 
        WHEN warranty ~ '^\d+' THEN 
            (regexp_match(warranty, '(\d+)'))[1]::INTEGER
        ELSE 0
    END
) STORED;

-- 4. Add constraint for machine_type with specific options
ALTER TABLE public.espresso_machines 
ADD CONSTRAINT machine_type_check 
CHECK (machine_type IN ('Semi-automatic', 'Automatic', 'Super-automatic', 'Manual'));

-- 5. Add constraint for boiler_type with specific options
ALTER TABLE public.espresso_machines 
ADD CONSTRAINT boiler_type_check 
CHECK (boiler_type IN ('Single boiler', 'Double boiler', 'Heat exchange', 'Thermoblock', 'Thermojet'));

-- Update existing data to match the new constraints (if needed)
-- You may need to update existing records to match the new constraint values

-- Example updates for machine_type (adjust based on your current data)
UPDATE public.espresso_machines 
SET machine_type = CASE 
    WHEN LOWER(machine_type) LIKE '%semi%' THEN 'Semi-automatic'
    WHEN LOWER(machine_type) LIKE '%super%' THEN 'Super-automatic'
    WHEN LOWER(machine_type) LIKE '%automatic%' THEN 'Automatic'
    WHEN LOWER(machine_type) LIKE '%manual%' THEN 'Manual'
    ELSE 'Semi-automatic'
END
WHERE machine_type IS NOT NULL;

-- Example updates for boiler_type (adjust based on your current data)
UPDATE public.espresso_machines 
SET boiler_type = CASE 
    WHEN LOWER(boiler_type) LIKE '%double%' THEN 'Double boiler'
    WHEN LOWER(boiler_type) LIKE '%single%' THEN 'Single boiler'
    WHEN LOWER(boiler_type) LIKE '%heat%exchange%' THEN 'Heat exchange'
    WHEN LOWER(boiler_type) LIKE '%thermoblock%' THEN 'Thermoblock'
    WHEN LOWER(boiler_type) LIKE '%thermojet%' THEN 'Thermojet'
    ELSE 'Single boiler'
END
WHERE boiler_type IS NOT NULL;

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'espresso_machines' 
    AND column_name IN ('pre_infusion', 'warranty', 'warranty_years', 'machine_type', 'boiler_type')
ORDER BY column_name;

-- Check constraints
SELECT 
    constraint_name, 
    check_clause
FROM information_schema.check_constraints 
WHERE constraint_name LIKE '%espresso_machines%';

-- Sample the updated data
SELECT 
    name,
    pre_infusion,
    warranty,
    warranty_years,
    machine_type,
    boiler_type
FROM public.espresso_machines 
LIMIT 5; 