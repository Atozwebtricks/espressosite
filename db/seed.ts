import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

// Manually retrieve environment variables
const supabaseUrl = process.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Supabase URL or Anon Key is missing from .env file");
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

const sampleMachines = [
  {
    id: 'breville-barista-express-impress',
    name: 'Breville Barista Express Impress',
    model_name: 'Barista Express Impress',
    brand: 'Breville',
    release_year: 2023,
    machine_type: 'Semi-automatic',
    price_usd: 899.00,
    asin: 'B0BXYZ1234',
    image_url: 'https://example.com/breville-express-impress.jpg',
    vendors: [
      {
        id: 'amazon_us',
        name: 'Amazon',
        url: 'https://www.amazon.com/dp/B0BXYZ1234',
        price: 899.00,
        last_updated: '2024-01-15T10:30:00Z'
      },
      {
        id: 'williams_sonoma',
        name: 'Williams Sonoma',
        url: 'https://www.williams-sonoma.com/products/breville-barista-express-impress/',
        price: 899.95,
        last_updated: '2024-01-15T08:15:00Z'
      }
    ],
    boiler_type: 'Single boiler',
    heat_up_seconds: 30,
    has_pid: true,
    built_in_grinder: 'built-in',
    pre_infusion: true,
    portafilter_mm: 54,
    steam_wand_type: 'manual',
    is_plumbable: false,
    water_tank_l: 2.0,
    has_water_filter: true,
    dimensions: '12.5" x 16.1" x 13.3"',
    weight_lbs: 26.7,
    power_watts: 1680,
    build_material: 'Brushed Stainless Steel',
    warranty: '2 year warranty'
  },
  {
    id: 'gaggia-classic-pro',
    name: 'Gaggia Classic Pro',
    model_name: 'Classic Pro',
    brand: 'Gaggia',
    release_year: 2019,
    machine_type: 'Semi-automatic',
    price_usd: 449.00,
    asin: 'B07RQ3NLB6',
    image_url: 'https://example.com/gaggia-classic-pro.jpg',
    vendors: [
      {
        id: 'amazon_us',
        name: 'Amazon',
        url: 'https://www.amazon.com/dp/B07RQ3NLB6',
        price: 449.00,
        last_updated: '2024-01-15T10:30:00Z'
      },
      {
        id: 'seattle_coffee_gear',
        name: 'Seattle Coffee Gear',
        url: 'https://www.seattlecoffeegear.com/gaggia-classic-pro-espresso-machine',
        price: 449.00,
        last_updated: '2024-01-15T09:45:00Z'
      }
    ],
    boiler_type: 'Single boiler',
    heat_up_seconds: 45,
    has_pid: false,
    built_in_grinder: 'none',
    pre_infusion: false,
    portafilter_mm: 58,
    steam_wand_type: 'manual',
    is_plumbable: false,
    water_tank_l: 2.1,
    has_water_filter: false,

    dimensions: '9.5" x 14.2" x 8.0"',
    weight_lbs: 17.0,
    power_watts: 1425,
    build_material: 'Stainless Steel',
    warranty: '1 year warranty'
  },
  {
    id: 'rancilio-silvia-pro-x',
    name: 'Rancilio Silvia Pro X',
    model_name: 'Silvia Pro X',
    brand: 'Rancilio',
    release_year: 2021,
    machine_type: 'Semi-automatic',
    price_usd: 1695.00,
    asin: 'B08XYZ5678',
    image_url: 'https://example.com/rancilio-silvia-pro-x.jpg',
    vendors: [
      {
        id: 'clive_coffee',
        name: 'Clive Coffee',
        url: 'https://clivecoffee.com/products/rancilio-silvia-pro-x',
        price: 1695.00,
        last_updated: '2024-01-15T11:00:00Z'
      },
      {
        id: 'whole_latte_love',
        name: 'Whole Latte Love',
        url: 'https://www.wholelattelove.com/products/rancilio-silvia-pro-x',
        price: 1695.00,
        last_updated: '2024-01-15T10:15:00Z'
      }
    ],
    boiler_type: 'Single boiler',
    heat_up_seconds: 25,
    has_pid: true,
    built_in_grinder: 'none',
    pre_infusion: true,
    portafilter_mm: 58,
    steam_wand_type: 'manual',
    is_plumbable: true,
    water_tank_l: 2.0,
    has_water_filter: true,

    dimensions: '9.5" x 13.4" x 11.4"',
    weight_lbs: 22.0,
    power_watts: 1400,
    build_material: 'Stainless Steel',
    warranty: '2 year limited warranty'
  },
  {
    id: 'la-marzocco-linea-mini',
    name: 'La Marzocco Linea Mini',
    model_name: 'Linea Mini',
    brand: 'La Marzocco',
    release_year: 2014,
    machine_type: 'Semi-automatic',
    price_usd: 4500.00,
    asin: 'B00ABC9012',
    image_url: 'https://example.com/la-marzocco-linea-mini.jpg',
    vendors: [
      {
        id: 'la_marzocco',
        name: 'La Marzocco',
        url: 'https://lamarzocco.com/en/machines/linea-mini/',
        price: 4500.00,
        last_updated: '2024-01-15T12:00:00Z'
      },
      {
        id: 'clive_coffee',
        name: 'Clive Coffee',
        url: 'https://clivecoffee.com/products/la-marzocco-linea-mini',
        price: 4500.00,
        last_updated: '2024-01-15T11:30:00Z'
      }
    ],
    boiler_type: 'Double boiler',
    heat_up_seconds: 20,
    has_pid: true,
    built_in_grinder: 'none',
    pre_infusion: true,
    portafilter_mm: 58,
    steam_wand_type: 'manual',
    is_plumbable: true,
    water_tank_l: 2.5,
    has_water_filter: false,

    dimensions: '13.0" x 14.0" x 17.3"',
    weight_lbs: 67.0,
    power_watts: 1550,
    build_material: 'Stainless Steel',
    warranty: '2 year manufacturer warranty'
  },
  {
    id: 'delonghi-la-specialista-arte',
    name: 'DeLonghi La Specialista Arte',
    model_name: 'La Specialista Arte',
    brand: 'DeLonghi',
    release_year: 2022,
    machine_type: 'Semi-automatic',
    price_usd: 899.00,
    asin: 'B09DEF3456',
    image_url: 'https://example.com/delonghi-specialista-arte.jpg',
    vendors: [
      {
        id: 'amazon_us',
        name: 'Amazon',
        url: 'https://www.amazon.com/dp/B09DEF3456',
        price: 899.00,
        last_updated: '2024-01-15T10:30:00Z'
      },
      {
        id: 'bed_bath_beyond',
        name: 'Bed Bath & Beyond',
        url: 'https://www.bedbathandbeyond.com/store/product/delonghi-la-specialista-arte',
        price: 949.00,
        last_updated: '2024-01-15T09:20:00Z'
      }
    ],
    boiler_type: 'Single boiler',
    heat_up_seconds: 40,
    has_pid: false,
    built_in_grinder: 'built-in',
    pre_infusion: true,
    portafilter_mm: 51,
    steam_wand_type: 'manual',
    is_plumbable: false,
    water_tank_l: 1.1,
    has_water_filter: true,

    dimensions: '14.8" x 12.6" x 16.5"',
    weight_lbs: 19.8,
    power_watts: 1450,
    build_material: 'Stainless Steel',
    warranty: '2 year warranty'
  },
  {
    id: 'rocket-appartamento',
    name: 'Rocket Appartamento',
    model_name: 'Appartamento',
    brand: 'Rocket Espresso',
    release_year: 2016,
    machine_type: 'Semi-automatic',
    price_usd: 1795.00,
    asin: 'B01GHI7890',
    image_url: 'https://example.com/rocket-appartamento.jpg',
    vendors: [
      {
        id: 'clive_coffee',
        name: 'Clive Coffee',
        url: 'https://clivecoffee.com/products/rocket-appartamento-espresso-machine',
        price: 1795.00,
        last_updated: '2024-01-15T11:45:00Z'
      },
      {
        id: 'espresso_outlet',
        name: 'Espresso Outlet',
        url: 'https://www.espressooutlet.com/rocket-appartamento',
        price: 1795.00,
        last_updated: '2024-01-15T10:00:00Z'
      }
    ],
    boiler_type: 'Heat exchange',
    heat_up_seconds: 15,
    has_pid: false,
    built_in_grinder: 'none',
    pre_infusion: false,
    portafilter_mm: 58,
    steam_wand_type: 'manual',
    is_plumbable: true,
    water_tank_l: 1.8,
    has_water_filter: false,

    dimensions: '10.2" x 13.8" x 16.9"',
    weight_lbs: 37.0,
    power_watts: 1400,
    build_material: 'Stainless Steel',
    warranty: '2 year warranty'
  },
  {
    id: 'profitec-pro-300',
    name: 'Profitec Pro 300',
    model_name: 'Pro 300',
    brand: 'Profitec',
    release_year: 2020,
    machine_type: 'Semi-automatic',
    price_usd: 1399.00,
    asin: 'B08JKL2345',
    image_url: 'https://example.com/profitec-pro-300.jpg',
    vendors: [
      {
        id: 'clive_coffee',
        name: 'Clive Coffee',
        url: 'https://clivecoffee.com/products/profitec-pro-300',
        price: 1399.00,
        last_updated: '2024-01-15T11:20:00Z'
      },
      {
        id: 'whole_latte_love',
        name: 'Whole Latte Love',
        url: 'https://www.wholelattelove.com/products/profitec-pro-300',
        price: 1399.00,
        last_updated: '2024-01-15T10:30:00Z'
      }
    ],
    boiler_type: 'Double boiler',
    heat_up_seconds: 12,
    has_pid: true,
    built_in_grinder: 'none',
    pre_infusion: true,
    portafilter_mm: 58,
    steam_wand_type: 'manual',
    is_plumbable: true,
    water_tank_l: 2.5,
    has_water_filter: true,

    dimensions: '12.2" x 15.7" x 17.3"',
    weight_lbs: 55.0,
    power_watts: 1600,
    build_material: 'Stainless Steel',
    warranty: '3 year warranty'
  },
  {
    id: 'sage-bambino-plus',
    name: 'Sage Bambino Plus',
    model_name: 'Bambino Plus',
    brand: 'Sage',
    release_year: 2019,
    machine_type: 'Semi-automatic',
    price_usd: 299.00,
    asin: 'B07MNO6789',
    image_url: 'https://example.com/sage-bambino-plus.jpg',
    vendors: [
      {
        id: 'amazon_us',
        name: 'Amazon',
        url: 'https://www.amazon.com/dp/B07MNO6789',
        price: 299.00,
        last_updated: '2024-01-15T10:30:00Z'
      },
      {
        id: 'williams_sonoma',
        name: 'Williams Sonoma',
        url: 'https://www.williams-sonoma.com/products/sage-bambino-plus/',
        price: 299.95,
        last_updated: '2024-01-15T09:45:00Z'
      }
    ],
    boiler_type: 'Thermojet',
    heat_up_seconds: 3,
    has_pid: false,
    built_in_grinder: 'none',
    pre_infusion: false,
    portafilter_mm: 54,
    steam_wand_type: 'automatic',
    is_plumbable: false,
    water_tank_l: 1.4,
    has_water_filter: false,

    dimensions: '7.5" x 12.2" x 12.8"',
    weight_lbs: 10.8,
    power_watts: 1600,
    build_material: 'Stainless Steel',
    warranty: '2 year warranty'
  }
];

async function seedDatabase() {
  try {
    console.log('Starting database seed...');
    
    // Insert sample machines
    const { data, error } = await supabase
      .from('espresso_machines')
      .insert(sampleMachines)
    
    if (error) {
      console.error('Error seeding database:', error);
      return;
    }
    
    console.log('Database seeded successfully!');
    console.log(`Inserted ${sampleMachines.length} machines`);
    
  } catch (error) {
    console.error('Unexpected error:', error);
  }
}

// Run the seed function
seedDatabase(); 