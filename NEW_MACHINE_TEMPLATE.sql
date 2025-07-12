-- TEMPLATE FOR ADDING NEW MACHINES WITH SIMPLIFIED VENDOR FORMAT

-- Copy this template and modify the values for new machines
INSERT INTO public.espresso_machines (
    id,
    name,
    brand,
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
    dimensions,
    pre_infusion,
    warranty,
    -- SIMPLIFIED VENDOR FORMAT - Choose one of these options:
    
    -- Option A: Simple URLs only (system auto-detects vendor names)
    vendors
    
    -- Option B: URLs with prices
    -- vendors
    
    -- Option C: Mixed format
    -- vendors
) VALUES (
    'your-machine-id',
    'Your Machine Name',
    'Brand Name',
    'Model Name',
    2024,
    'Semi-automatic',
    599.00,
    'Single boiler',
    30,
    true,
    'none',
    58,
    'manual',
    false,
    2.0,
    true,
    20.0,
    1500,
    'Stainless Steel',
    '10" x 12" x 15"',
    true,
    '2 year warranty',
    
    -- Option A: Simple URLs (uncomment this line)
    '["https://www.amazon.com/dp/YOUR_ASIN", "https://clivecoffee.com/products/your-machine"]'::jsonb
    
    -- Option B: URLs with prices (uncomment this instead)
    -- '[{"url": "https://www.amazon.com/dp/YOUR_ASIN", "price": 599.00}, {"url": "https://clivecoffee.com/products/your-machine", "price": 625.00}]'::jsonb
    
    -- Option C: Mixed format (uncomment this instead)
    -- '["https://www.amazon.com/dp/YOUR_ASIN", {"url": "https://clivecoffee.com/products/your-machine", "price": 625.00}]'::jsonb
); 