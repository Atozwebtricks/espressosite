-- SIMPLIFIED VENDOR FORMAT EXAMPLES
-- New simplified format removes id, last_updated and auto-extracts vendor names from domains

-- Example 1: Simple URLs only (no prices)
INSERT INTO public.espresso_machines (
    id, name, brand, price_usd, vendors
) VALUES (
    'example-simple-urls',
    'Example Machine 1',
    'Example Brand',
    599.00,
    '[
        "https://www.amazon.com/dp/B123456789",
        "https://www.williams-sonoma.com/products/example-machine/",
        "https://clivecoffee.com/products/example-machine"
    ]'::jsonb
);

-- Example 2: URLs with prices (mixed format)
INSERT INTO public.espresso_machines (
    id, name, brand, price_usd, vendors
) VALUES (
    'example-with-prices',
    'Example Machine 2',
    'Example Brand',
    799.00,
    '[
        {"url": "https://www.amazon.com/dp/B987654321", "price": 799.00},
        {"url": "https://www.seattlecoffeegear.com/example-machine", "price": 825.00},
        "https://www.wholelattelove.com/products/example-machine"
    ]'::jsonb
);

-- Example 3: Mix of formats (backward compatible)
INSERT INTO public.espresso_machines (
    id, name, brand, price_usd, vendors
) VALUES (
    'example-mixed-format',
    'Example Machine 3',
    'Example Brand',
    1299.00,
    '[
        "https://www.amazon.com/dp/B456789123",
        {"url": "https://clivecoffee.com/products/example", "price": 1299.00},
        {"url": "https://www.target.com/p/example-machine", "price": 1199.99},
        "https://www.bestbuy.com/site/example-machine"
    ]'::jsonb
);

-- The system will automatically:
-- ✅ Extract vendor names from domains (amazon.com → "Amazon")
-- ✅ Handle missing prices gracefully (show just vendor name)
-- ✅ Support both string URLs and object format
-- ✅ Work with unknown domains (creates readable names)

-- Domain to vendor name mapping includes:
-- amazon.com → Amazon
-- williams-sonoma.com → Williams Sonoma
-- clivecoffee.com → Clive Coffee
-- seattlecoffeegear.com → Seattle Coffee Gear
-- wholelattelove.com → Whole Latte Love
-- target.com → Target
-- bestbuy.com → Best Buy
-- walmart.com → Walmart
-- And many more...

-- For unknown domains, it creates readable names:
-- coffeeshopexample.com → "Coffeeshopexample"
-- my-coffee-store.com → "My Coffee Store" 