-- Sample Data Insert for Espresso Machines Table
-- Run this in your Supabase SQL Editor to add 2 sample machines

INSERT INTO public.espresso_machines (
    id,
    name,
    brand,
    asin,
    image_url,
    model_name,
    release_year,
    machine_type,
    price_usd,
    boiler_type,
    heat_up_seconds,
    has_pid,
    built_in_grinder,
    portafilter_mm,
    steam_wand_type,
    is_plumbable,
    water_tank_l,
    has_water_filter,
    weight_lbs,
    power_watts,
    build_material,
    vendors,
    dimensions,
    pre_infusion,
    warranty
) VALUES 
(
    'breville-bambino-plus-2024',
    'Breville Bambino Plus',
    'Breville',
    'B07MNO6789',
    'https://example.com/breville-bambino-plus.jpg',
    'Bambino Plus',
    2019,
    'Semi-automatic',
    299.00,
    'Thermojet',
    3,
    false,
    'none',
    54,
    'automatic',
    false,
    1.40,
    false,
    10.8,
    1600,
    'Stainless Steel',
    '[
        {
            "id": "amazon_us",
            "name": "Amazon",
            "url": "https://www.amazon.com/dp/B07MNO6789",
            "price": 299.00,
            "last_updated": "2024-01-15T10:30:00Z"
        },
        {
            "id": "williams_sonoma",
            "name": "Williams Sonoma",
            "url": "https://www.williams-sonoma.com/products/breville-bambino-plus/",
            "price": 299.95,
            "last_updated": "2024-01-15T09:45:00Z"
        }
    ]'::jsonb,
    '7.5" x 12.2" x 12.8"',
    false,
    '2 year limited warranty'
),
(
    'rancilio-silvia-pro-x-2024',
    'Rancilio Silvia Pro X',
    'Rancilio',
    'B08XYZ5678',
    'https://example.com/rancilio-silvia-pro-x.jpg',
    'Silvia Pro X',
    2021,
    'Semi-automatic',
    1695.00,
    'Single boiler',
    25,
    true,
    'none',
    58,
    'manual',
    true,
    2.00,
    true,
    22.0,
    1400,
    'Stainless Steel',
    '[
        {
            "id": "clive_coffee",
            "name": "Clive Coffee",
            "url": "https://clivecoffee.com/products/rancilio-silvia-pro-x",
            "price": 1695.00,
            "last_updated": "2024-01-15T11:00:00Z"
        },
        {
            "id": "whole_latte_love",
            "name": "Whole Latte Love",
            "url": "https://www.wholelattelove.com/products/rancilio-silvia-pro-x",
            "price": 1695.00,
            "last_updated": "2024-01-15T10:15:00Z"
        }
    ]'::jsonb,
    '9.5" x 13.4" x 11.4"',
    true,
    '2 year manufacturer warranty'
);

-- Verify the inserted data
SELECT 
    id,
    name,
    brand,
    machine_type,
    boiler_type,
    price_usd,
    pre_infusion,
    warranty,
    warranty_years
FROM public.espresso_machines 
WHERE id IN ('breville-bambino-plus-2024', 'rancilio-silvia-pro-x-2024'); 