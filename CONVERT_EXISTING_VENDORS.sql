-- CONVERT EXISTING VENDOR DATA TO SIMPLIFIED FORMAT
-- Run this in your Supabase SQL Editor to update existing machines

-- This will convert from the old format:
-- [{"id": "amazon_us", "name": "Amazon", "url": "https://amazon.com/...", "price": 299, "last_updated": "..."}]
-- 
-- To the new simplified format:
-- [{"url": "https://amazon.com/...", "price": 299}]

UPDATE public.espresso_machines 
SET vendors = (
    SELECT jsonb_agg(
        CASE 
            -- If vendor has both url and price, keep both
            WHEN vendor->>'url' IS NOT NULL AND vendor->>'price' IS NOT NULL THEN
                jsonb_build_object('url', vendor->>'url', 'price', (vendor->>'price')::numeric)
            -- If vendor has url but no price, just keep url as string
            WHEN vendor->>'url' IS NOT NULL THEN
                to_jsonb(vendor->>'url')
            -- Fallback: keep as is
            ELSE vendor
        END
    )
    FROM jsonb_array_elements(vendors) AS vendor
    WHERE jsonb_array_length(vendors) > 0
)
WHERE vendors IS NOT NULL 
  AND jsonb_typeof(vendors) = 'array' 
  AND jsonb_array_length(vendors) > 0;

-- Verify the conversion worked
SELECT 
    id,
    name,
    vendors
FROM public.espresso_machines 
WHERE vendors IS NOT NULL
LIMIT 5; 