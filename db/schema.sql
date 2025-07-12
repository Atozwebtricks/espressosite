-- Updated Espresso Machines Database Schema
-- Matches the new Supabase table structure with enhanced fields and constraints

CREATE TABLE public.espresso_machines (
  -- Core identification
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT,
  brand TEXT,
  asin TEXT,
  model_name TEXT,
  release_year INTEGER CHECK (release_year >= 1980),
  machine_type TEXT NOT NULL DEFAULT 'Semi-Automatic',
  
  -- Pricing and vendor info
  price_usd NUMERIC(10,2),
  vendors JSONB DEFAULT '[]'::jsonb,
  
  -- Technical specifications
  boiler_configuration TEXT,
  heating_system TEXT,
  number_of_boilers SMALLINT,
  heat_up_seconds INTEGER,
  has_pid BOOLEAN DEFAULT false,
  built_in_grinder TEXT,
  portafilter_mm INTEGER,
  steam_wand_type TEXT,
  
  -- Pre-infusion (boolean format)
  pre_infusion BOOLEAN,
  
  -- Utility features
  is_plumbable BOOLEAN DEFAULT false,
  water_tank_l NUMERIC(4,2),
  has_water_filter BOOLEAN DEFAULT false,
  
  -- Physical specifications
  dimensions TEXT,
  weight_lbs NUMERIC(5,2),
  power_watts INTEGER,
  
  -- Build and warranty
  build_material TEXT,
  warranty TEXT,
  warranty_years INTEGER GENERATED ALWAYS AS (
    CASE 
      WHEN (warranty ~ '^\d+'::text) THEN ((regexp_match(warranty, '(\d+)'::text))[1])::integer
      ELSE 0
    END
  ) STORED,
  
  -- Image handling
  image_path TEXT,
  image_caption TEXT,
  image_source TEXT,
  
  -- Search optimization
  search_vec TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('english'::regconfig, 
      (COALESCE(model_name, name, ''::text) || ' '::text) || COALESCE(brand, ''::text)
    )
  ) STORED NOT NULL,
  
  -- Constraints
  CONSTRAINT chk_number_of_boilers CHECK (number_of_boilers = ANY (ARRAY[1, 2])),
  CONSTRAINT espresso_machines_built_in_grinder_check CHECK (
    built_in_grinder = ANY (ARRAY['built-in'::text, 'external'::text, 'none'::text])
  ),
  CONSTRAINT chk_boiler_configuration CHECK (
    boiler_configuration = ANY (ARRAY[
      'Single boiler'::text,
      'Heat-exchange'::text,
      'Dual boiler'::text
    ])
  ),
  CONSTRAINT machine_type_check CHECK (
    machine_type = ANY (ARRAY[
      'Semi-automatic'::text,
      'Automatic'::text,
      'Super-automatic'::text,
      'Manual'::text
    ])
  ),
  CONSTRAINT espresso_machines_heating_system_check CHECK (
    (heating_system IS NULL) OR (
      heating_system = ANY (ARRAY[
        'Classic tank'::text,
        'Thermoblock'::text,
        'Thermocoil'::text,
        'Thermojet'::text,
        'Quick Heat boiler'::text
      ])
    )
  )
);

-- Create all required indexes for optimal performance
CREATE INDEX IF NOT EXISTS espresso_search_idx ON public.espresso_machines USING GIN (search_vec);
CREATE INDEX IF NOT EXISTS espresso_brand_idx ON public.espresso_machines USING BTREE (brand);
CREATE INDEX IF NOT EXISTS espresso_price_idx ON public.espresso_machines USING BTREE (price_usd);
CREATE INDEX IF NOT EXISTS espresso_pid_idx ON public.espresso_machines USING BTREE (has_pid);
CREATE INDEX IF NOT EXISTS espresso_grinder_idx ON public.espresso_machines USING BTREE (built_in_grinder);
CREATE INDEX IF NOT EXISTS espresso_type_idx ON public.espresso_machines USING BTREE (machine_type);
CREATE INDEX IF NOT EXISTS espresso_year_idx ON public.espresso_machines USING BTREE (release_year);
CREATE INDEX IF NOT EXISTS espresso_plumbable_idx ON public.espresso_machines USING BTREE (is_plumbable);
CREATE INDEX IF NOT EXISTS espresso_heatup_idx ON public.espresso_machines USING BTREE (heat_up_seconds);
CREATE INDEX IF NOT EXISTS espresso_tank_idx ON public.espresso_machines USING BTREE (water_tank_l);
CREATE INDEX IF NOT EXISTS espresso_weight_idx ON public.espresso_machines USING BTREE (weight_lbs);
CREATE INDEX IF NOT EXISTS espresso_power_idx ON public.espresso_machines USING BTREE (power_watts);
CREATE INDEX IF NOT EXISTS espresso_boiler_cfg_idx ON public.espresso_machines USING BTREE (boiler_configuration);
CREATE INDEX IF NOT EXISTS espresso_heating_sys_idx ON public.espresso_machines USING BTREE (heating_system);
CREATE INDEX IF NOT EXISTS espresso_boiler_count_idx ON public.espresso_machines USING BTREE (number_of_boilers);

-- Function for generating ID from model name (if the trigger exists)
-- This assumes you have a function called generate_id_from_model_name()
-- CREATE TRIGGER set_id_trigger BEFORE INSERT OR UPDATE ON espresso_machines 
-- FOR EACH ROW EXECUTE FUNCTION generate_id_from_model_name(); 