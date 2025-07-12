Comprehensive Guide for Scraping Espresso Machine Data and Populating Supabase (Phase 1)
Date: June 22, 2025
Objective: Scrape detailed product information for 60+ espresso machines (excluding image_url and price_usd) and populate a Supabase table using Browserbase for automation, with a focus on generating a vendors JSONB field for buying options. This document is designed for feeding into AI tools like Cursor AI or other models to facilitate implementation.
Table of Contents
Project Overview (#project-overview)
Supabase Table Schema (#supabase-table-schema)
Product List (#product-list)
Vendors JSONB Format (#vendors-jsonb-format)
Proposed Approach (#proposed-approach)
Automation with Browserbase (#automation-with-browserbase)
Data Cleaning and Validation (#data-cleaning-and-validation)
Importing to Supabase (#importing-to-supabase)
Implementation Steps (#implementation-steps)
Browserbase Configuration (#browserbase-configuration)
Python Cleaning Script (#python-cleaning-script)
Supabase Import Process (#supabase-import-process)
Challenges and Mitigations (#challenges-and-mitigations)
Example Workflow (#example-workflow)
Tools and Dependencies (#tools-and-dependencies)
Sample Code Snippets (#sample-code-snippets)
Testing and Validation (#testing-and-validation)
Conclusion and Next Steps (#conclusion-and-next-steps)
Project Overview
This project involves scraping detailed specifications for over 60 espresso machines from brands like Breville, Lelit, Gaggia, DeLonghi, Rancilio, La Marzocco, and Profitec, and storing the data in a Supabase table. For Phase 1, all fields except image_url and price_usd are included, with a specific focus on the vendors JSONB field, which lists buying options with URLs and prices. Automation is achieved using Browserbase, an AI-driven browser tool, to search, extract, and compile data into a CSV. The CSV is cleaned using Python and imported into Supabase, ensuring compliance with the table’s schema constraints.
This document provides a detailed, actionable guide for implementation, suitable for use with AI coding assistants like Cursor AI to generate scripts, troubleshoot issues, and streamline development.
Supabase Table Schema
The espresso_machines table in Supabase is designed to store comprehensive product details. Below is the schema, excluding image_url and price_usd for Phase 1.
sql
CREATE TABLE public.espresso_machines (
  id TEXT NOT NULL,
  name TEXT NULL,
  brand TEXT NULL,
  asin TEXT NULL,
  model_name TEXT NULL,
  release_year INTEGER NULL,
  machine_type TEXT NOT NULL DEFAULT 'Semi-Automatic'::TEXT,
  boiler_type TEXT NULL,
  heat_up_seconds INTEGER NULL,
  has_pid BOOLEAN NULL DEFAULT FALSE,
  built_in_grinder TEXT NULL,
  portafilter_mm INTEGER NULL,
  steam_wand_type TEXT NULL,
  is_plumbable BOOLEAN NULL DEFAULT FALSE,
  water_tank_l NUMERIC(4,2) NULL,
  has_water_filter BOOLEAN NULL DEFAULT FALSE,
  weight_lbs NUMERIC(5,2) NULL,
  power_watts INTEGER NULL,
  build_material TEXT NULL,
  vendors JSONB NULL DEFAULT '[]'::JSONB,
  dimensions TEXT NULL,
  search_vec TSVECTOR GENERATED ALWAYS AS (
    TO_TSVECTOR(
      'english'::REGCONFIG,
      ((COALESCE(model_name, name, ''::TEXT) || ' '::TEXT) || COALESCE(brand, ''::TEXT))
    )
  ) STORED NULL,
  pre_infusion BOOLEAN NULL,
  warranty TEXT NULL,
  warranty_years INTEGER GENERATED ALWAYS AS (
    CASE
      WHEN (warranty ~ '^\d+'::TEXT) THEN ((REGEXP_MATCH(warranty, '(\d+)'::TEXT))[1])::INTEGER
      ELSE 0
    END
  ) STORED NULL,
  CONSTRAINT machines_pkey PRIMARY KEY (id),
  CONSTRAINT boiler_type_check CHECK (
    boiler_type IN ('Single boiler', 'Double boiler', 'Heat exchange', 'Thermoblock', 'Thermojet')
  ),
  CONSTRAINT espresso_machines_built_in_grinder_check CHECK (
    built_in_grinder IN ('built-in', 'external', 'none')
  ),
  CONSTRAINT espresso_machines_release_year_check CHECK (release_year >= 1980),
  CONSTRAINT machine_type_check CHECK (
    machine_type IN ('Semi-automatic', 'Automatic', 'Super-automatic', 'Manual')
  )
);

-- Indexes
CREATE INDEX IF NOT EXISTS espresso_brand_idx ON public.espresso_machines USING BTREE (brand);
CREATE INDEX IF NOT EXISTS espresso_boiler_idx ON public.espresso_machines USING BTREE (boiler_type);
CREATE INDEX IF NOT EXISTS espresso_pid_idx ON public.espresso_machines USING BTREE (has_pid);
CREATE INDEX IF NOT EXISTS espresso_grinder_idx ON public.espresso_machines USING BTREE (built_in_grinder);
CREATE INDEX IF NOT EXISTS espresso_type_idx ON public.espresso_machines USING BTREE (machine_type);
CREATE INDEX IF NOT EXISTS espresso_year_idx ON public.espresso_machines USING BTREE (release_year);
CREATE INDEX IF NOT EXISTS espresso_plumbable_idx ON public.espresso_machines USING BTREE (is_plumbable);
CREATE INDEX IF NOT EXISTS espresso_heatup_idx ON public.espresso_machines USING BTREE (heat_up_seconds);
CREATE INDEX IF NOT EXISTS espresso_tank_idx ON public.espresso_machines USING BTREE (water_tank_l);
CREATE INDEX IF NOT EXISTS espresso_search_idx ON public.espresso_machines USING GIN (search_vec);
CREATE INDEX IF NOT EXISTS espresso_weight_idx ON public.espresso_machines USING BTREE (weight_lbs);
CREATE INDEX IF NOT EXISTS espresso_power_idx ON public.espresso_machines USING BTREE (power_watts);

-- Trigger for ID generation
CREATE TRIGGER set_id_trigger
BEFORE INSERT OR UPDATE ON espresso_machines
FOR EACH ROW
EXECUTE FUNCTION generate_id_from_model_name();
Key Notes:
Excluded Fields: image_url and price_usd are omitted in Phase 1.
Vendors Field: JSONB array storing buying options (see Vendors JSONB Format (#vendors-jsonb-format)).
Generated Fields: id, search_vec, warranty_years are computed automatically.
Constraints: Enforce valid values for boiler_type, machine_type, built_in_grinder, and release_year.
Product List
The list includes over 60 espresso machines, referenced in @currentProductsListRef.md. Examples:
Breville: The Oracle Touch, The Oracle, The Barista Touch, The Bambino Plus, etc.
Lelit: Anna (PL41TEM), Anita (PL042TEMD), Bianca (PL162T), etc.
Gaggia: Classic Evo Pro, Cadorna Prestige, Magenta Plus, etc.
DeLonghi: Eletta Explore, La Specialista Maestro, Magnifica Evo, etc.
Rancilio: Silvia Pro X, Silvia
La Marzocco: Linea Mini
Profitec: GO, MOVE, Drive, RIDE
Input File: Store the product list in a file (e.g., products.txt) with one product per line for Browserbase to process.
Vendors JSONB Format
The vendors field is a JSONB array of objects, each representing a buying option with a URL and price.
Example:
json
[
  {
    "url": "https://www.amazon.com/dp/B07MNO6789",
    "price": 299.00
  },
  {
    "url": "https://www.williams-sonoma.com/products/breville-bambino-plus/",
    "price": 299.95
  },
  {
    "url": "https://www.wholelattelove.com/products/breville-bambino-plus",
    "price": 300.50
  }
]
Specifications:
url (string): Direct link to the product page (e.g., Amazon, Williams Sonoma).
price (number): Price in USD, with up to two decimal places.
Default: [] if no vendors are found.
Phase 1 Note: Although price_usd is excluded from the main table, price in vendors is included to capture buying options.
Proposed Approach
The approach involves three stages: scraping with Browserbase, cleaning with Python, and importing to Supabase.
Automation with Browserbase
Browserbase automates data collection from manufacturer sites, retailers, and review platforms.
Search Strategy:
Input: Product list (e.g., products.txt).
For each product (e.g., “Breville Bambino Plus”), perform a Google search and visit top results, prioritizing:
Manufacturer sites (e.g., Breville)
Retailers (e.g., Amazon, Williams Sonoma, Best Buy)
Specialty sites (e.g., Whole Latte Love)
Limit to 3–5 sources per product to balance coverage and performance.
Data Extraction:
Extract fields: name, brand, asin, model_name, release_year, machine_type, boiler_type, etc.
For vendors, collect URLs and prices from retailer sites.
Use XPath/CSS selectors tailored to site structures (e.g., Amazon’s spec tables).
Example:
name: Page title
boiler_type: Map “dual boiler” to “Double boiler”
vendors: [{"url": "https://www.amazon.com/dp/B07MNO6789", "price": 299.00}, ...]
Fallback Mechanism:
If data is missing (e.g., portafilter_mm), check alternative sources (e.g., Coffee Geek, Home-Barista).
Log missing fields for manual review.
Output: CSV file with columns matching the Supabase schema (e.g., espresso_machines.csv).
Data Cleaning and Validation
The raw CSV is cleaned to ensure schema compliance.
Steps:
Load CSV: Use pandas to read espresso_machines.csv.
Type Conversion:
release_year: Integer >= 1980, NULL if missing.
boiler_type: Map to valid values (e.g., “dual boiler” → “Double boiler”).
water_tank_l: Numeric(4,2) (e.g., “2.5” → 2.50).
vendors: Validate JSONB format, ensure url is valid, price is numeric.
Handle Missing Values:
Critical fields (name, brand): Manual research if missing.
Niche fields (e.g., steam_wand_type): Set defaults or cross-reference forums.
Generated Fields:
Ensure model_name and warranty are populated for search_vec and warranty_years.
Leave id empty for trigger.
Output: Cleaned CSV (cleaned_espresso_machines.csv).
Importing to Supabase
The cleaned CSV is imported into Supabase.
Methods:
Supabase dashboard CSV import.
psql command: COPY espresso_machines FROM 'cleaned_espresso_machines.csv' DELIMITER ',' CSV HEADER;
Validation:
Check constraints (e.g., valid boiler_type).
Verify search_vec, warranty_years, and indexes.
Error Handling:
Log import errors and fix CSV issues.
Implementation Steps
Browserbase Configuration
Setup:
Install Browserbase SDK: pip install browserbase
Obtain API key from Browserbase.
Script:
Read product list (products.txt).
For each product, search Google, visit top sites, and extract data.
Save to espresso_machines.csv.
Selectors:
Define XPath/CSS for key sites (e.g., Amazon, Breville).
Example: //div[@id='productTitle'] for Amazon product name.
Error Handling:
Retry failed requests (e.g., 3 attempts).
Log missing data for manual review.
Python Cleaning Script
Setup:
Install dependencies: pip install pandas validators
Script:
Load espresso_machines.csv.
Validate and convert data types.
Save to cleaned_espresso_machines.csv.
Validation:
Check vendors JSONB format.
Ensure schema constraints are met.
Supabase Import Process
Setup:
Configure Supabase connection (URL, key).
Import:
Use Supabase CLI or dashboard.
Example: psql -c "COPY espresso_machines FROM 'cleaned_espresso_machines.csv' DELIMITER ',' CSV HEADER;".
Verification:
Query table to confirm data integrity.
Challenges and Mitigations
Challenge
Description
Mitigation
Website Blocking
Sites may block scraping.
Use rotating proxies, set user-agent headers, respect robots.txt.
Data Inconsistency
Specs vary by source.
Prioritize manufacturer data, log discrepancies.
Missing Data
Niche fields (e.g., portafilter_mm) may be absent.
Use fallback sources (e.g., Home-Barista), manual research.
Scalability
Scraping 60+ products is time-intensive.
Batch process (e.g., 10 products per batch).
Example Workflow
Product: Breville Bambino Plus
Browserbase:
Search: “Breville Bambino Plus”
Visit: Breville, Amazon
Extract:
name: “Bambino Plus”
brand: “Breville”
boiler_type: “Thermoblock”
vendors: [{"url": "https://www.amazon.com/dp/B07MNO6789", "price": 299.00}, {"url": "https://www.williams-sonoma.com/products/breville-bambino-plus/", "price": 299.95}]
Fallback: Check Whole Latte Love for portafilter_mm.
Cleaning:
Map boiler_type to “Thermoblock”.
Validate vendors JSON.
Set defaults (e.g., has_pid = false).
Supabase Import:
Import CSV row.
Verify search_vec, warranty_years.
Tools and Dependencies
Browserbase: Web scraping automation Documentation.
Python: Data cleaning.
pandas: CSV manipulation.
validators: URL validation.
json: JSONB handling.
Supabase: Database Documentation.
Fallback Sources:
Breville, Gaggia
Amazon, Williams Sonoma, Whole Latte Love
Coffee Geek, Home-Barista
Sample Code Snippets
Browserbase Script (Python)
python
from browserbase import Browserbase
import csv
import time

bb = Browserbase(api_key='YOUR_API_KEY')
products = open('products.txt').read().splitlines()
output = []

for product in products:
    try:
        session = bb.create_session()
        # Search Google
        session.navigate(f"https://www.google.com/search?q={product}")
        links = session.find_elements('a[href*="amazon.com"], a[href*="breville.com"]')[:3]
        
        data = {'name': product, 'brand': '', 'vendors': []}
        for link in links:
            session.navigate(link.get_attribute('href'))
            # Extract data (simplified)
            if 'amazon.com' in link.get_attribute('href'):
                data['asin'] = session.find_element('#ASIN').get_attribute('value')
                data['vendors'].append({
                    'url': link.get_attribute('href'),
                    'price': float(session.find_element('.a-price-whole').text)
                })
            time.sleep(1)  # Avoid rate limits
        
        output.append(data)
    except Exception as e:
        print(f"Error for {product}: {e}")
    
    # Save to CSV
    with open('espresso_machines.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['name', 'brand', 'asin', 'vendors'])
        writer.writeheader()
        writer.writerows(output)
Python Cleaning Script
python
import pandas as pd
import json
import validators

df = pd.read_csv('espresso_machines.csv')

# Define valid values
boiler_types = ['Single boiler', 'Double boiler', 'Heat exchange', 'Thermoblock', 'Thermojet']
machine_types = ['Semi-automatic', 'Automatic', 'Super-automatic', 'Manual']
grinder_types = ['built-in', 'external', 'none']

for index, row in df.iterrows():
    # Clean vendors
    try:
        vendors = json.loads(row['vendors'])
        for vendor in vendors:
            if not validators.url(vendor['url']):
                vendor['url'] = None
            vendor['price'] = float(vendor['price']) if vendor['price'] else 0.0
        df.at[index, 'vendors'] = json.dumps([v for v in vendors if v['url']])
    except:
        df.at[index, 'vendors'] = '[]'
    
    # Clean other fields (example)
    if pd.notna(row['boiler_type']):
        df.at[index, 'boiler_type'] = next((bt for bt in boiler_types if bt.lower() in row['boiler_type'].lower()), None)

df.to_csv('cleaned_espresso_machines.csv', index=False)
Supabase Import (SQL)
sql
COPY espresso_machines (name, brand, asin, model_name, release_year, machine_type, boiler_type, heat_up_seconds, has_pid, built_in_grinder, portafilter_mm, steam_wand_type, is_plumbable, water_tank_l, has_water_filter, weight_lbs, power_watts, build_material, vendors, dimensions, pre_infusion, warranty)
FROM '/path/to/cleaned_espresso_machines.csv'
DELIMITER ','
CSV HEADER;
Testing and Validation
Browserbase:
Test on 5 products.
Verify extracted fields (e.g., vendors includes valid URLs/prices).
Cleaning:
Check cleaned_espresso_machines.csv for schema compliance.
Validate vendors JSONB format.
Supabase:
Import test CSV.
Query: SELECT name, vendors->0->>'url', vendors->0->>'price' FROM espresso_machines LIMIT 5;
Verify search_vec, warranty_years.
Conclusion and Next Steps
This guide provides a detailed roadmap for scraping espresso machine data using Browserbase, cleaning with Python, and importing into Supabase. The vendors JSONB field is structured to capture buying options, supporting Phase 1 and future Phase 2 integration. Feed this document into Cursor AI or similar tools to generate scripts, debug issues, and automate development.
Next Steps:
Set up Browserbase with API key and test script.
Create products.txt with the product list.
Run Browserbase on a small batch (5 products).
Develop and test Python cleaning script.
Import test data to Supabase and validate.
Scale to full 60+ products, monitoring for errors.
This document is structured for AI-assisted development, with clear specifications, code snippets, and validation steps to ensure a smooth implementation.