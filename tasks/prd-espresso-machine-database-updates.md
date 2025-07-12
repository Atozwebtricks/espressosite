# Database & Frontend Enhancement PRD: Espresso Machine Comparison Site

## Overview
This PRD outlines specific updates to enhance the existing espresso machine comparison site with comprehensive filtering, improved data structure, and advanced search capabilities. The current system has basic filtering on a simple `machines` table - we need to expand this significantly.

---

## 🗄️ Database Updates Required

### Current Schema Issues
The existing `machines` table has several limitations:
- Limited technical specifications
- No standardized units or data validation
- Missing key filtering attributes
- No full-text search capability
- Inconsistent data types

### Required Database Changes

#### 1. Update Table Schema: `machines` → `espresso_machines`

**MIGRATION NEEDED:** Rename table and add new columns

```sql
-- Rename existing table and add new columns
ALTER TABLE machines RENAME TO espresso_machines;

-- Add new required columns
ALTER TABLE espresso_machines 
  ADD COLUMN model_name TEXT,
  ADD COLUMN release_year INTEGER CHECK (release_year >= 1980),
  ADD COLUMN machine_type TEXT NOT NULL DEFAULT 'Semi-Automatic',
  ADD COLUMN price_usd NUMERIC(10,2),
  ADD COLUMN boiler_type TEXT,
  ADD COLUMN heat_up_seconds INTEGER,
  ADD COLUMN has_pid BOOLEAN DEFAULT false,
  ADD COLUMN built_in_grinder TEXT CHECK (built_in_grinder IN ('built-in', 'external', 'none')),
  ADD COLUMN pre_infusion_type TEXT CHECK (pre_infusion_type IN ('none', 'mechanical', 'programmable')),
  ADD COLUMN portafilter_mm INTEGER,
  ADD COLUMN steam_wand_type TEXT,
  ADD COLUMN is_plumbable BOOLEAN DEFAULT false,
  ADD COLUMN water_tank_l NUMERIC(4,2),
  ADD COLUMN has_water_filter BOOLEAN DEFAULT false,
  ADD COLUMN width_in NUMERIC(5,2),
  ADD COLUMN height_in NUMERIC(5,2),
  ADD COLUMN depth_in NUMERIC(5,2),
  ADD COLUMN weight_lbs NUMERIC(5,2),
  ADD COLUMN power_watts INTEGER,
  ADD COLUMN build_material TEXT,
  ADD COLUMN warranty_years INTEGER,
  ADD COLUMN vendors JSONB,
  ADD COLUMN search_vec tsvector GENERATED ALWAYS AS (
    to_tsvector('english', COALESCE(model_name, name) || ' ' || brand)
  ) STORED;

-- Update existing data mapping
UPDATE espresso_machines SET
  model_name = name,
  price_usd = price_msrp,
  boiler_type = boiler,
  has_pid = pid,
  is_plumbable = plumbable,
  water_tank_l = reservoir_ml / 1000.0,
  machine_type = CASE 
    WHEN skill_level = 'Beginner' THEN 'Semi-Automatic'
    WHEN skill_level = 'Intermediate' THEN 'Semi-Automatic'
    WHEN skill_level = 'Prosumer' THEN 'Manual'
    ELSE 'Semi-Automatic'
  END,
  built_in_grinder = 'none',
  pre_infusion_type = CASE
    WHEN pre_infusion = 'Manual' THEN 'none'
    WHEN pre_infusion = 'Automatic' THEN 'mechanical'
    WHEN pre_infusion = 'Mechanical' THEN 'mechanical'
    WHEN pre_infusion = 'Pressure Profiling' THEN 'programmable'
    ELSE 'none'
  END;
```

#### 2. Create Required Indexes

```sql
CREATE INDEX espresso_search_idx ON espresso_machines USING GIN (search_vec);
CREATE INDEX espresso_brand_idx ON espresso_machines (brand);
CREATE INDEX espresso_price_idx ON espresso_machines (price_usd);
CREATE INDEX espresso_boiler_idx ON espresso_machines (boiler_type);
CREATE INDEX espresso_pid_idx ON espresso_machines (has_pid);
CREATE INDEX espresso_grinder_idx ON espresso_machines (built_in_grinder);
CREATE INDEX espresso_type_idx ON espresso_machines (machine_type);
CREATE INDEX espresso_year_idx ON espresso_machines (release_year);
CREATE INDEX espresso_plumbable_idx ON espresso_machines (is_plumbable);
```

#### 3. Sample Enhanced Data Structure

```json
{
  "id": "gaggia-classic-pro",
  "name": "Gaggia Classic Pro", // Keep for backward compatibility
  "model_name": "Classic Pro",
  "brand": "Gaggia",
  "release_year": 2019,
  "machine_type": "Semi-Automatic",
  "price_usd": 449.00,
  "boiler_type": "single",
  "heat_up_seconds": 45,
  "has_pid": false,
  "built_in_grinder": "none",
  "pre_infusion_type": "none",
  "portafilter_mm": 58,
  "steam_wand_type": "manual",
  "is_plumbable": false,
  "water_tank_l": 2.1,
  "has_water_filter": false,
  "width_in": 9.5,
  "height_in": 14.2,
  "depth_in": 8.0,
  "weight_lbs": 17.0,
  "power_watts": 1425,
  "build_material": "Stainless Steel",
  "warranty_years": 1,
  "vendors": [
    {
      "id": "amazon_us",
      "name": "Amazon",
      "url": "https://www.amazon.com/dp/B07RQ3NLB6",
      "price": 449.00,
      "last_updated": "2024-01-15T10:30:00Z"
    }
  ]
}
```

---

## 🎨 Frontend Updates Required

### Current Frontend Limitations
- Basic dropdowns only
- No search functionality
- Limited filter types
- No advanced filtering options
- Poor mobile experience
- No URL state persistence

### Required Component Updates

#### 1. Enhanced Filters Component (`src/components/Filters.svelte`)

**MAJOR REWRITE NEEDED** - Current component needs complete overhaul:

```typescript
// New filter state structure needed
interface FilterState {
  // Search
  searchTerm: string;
  
  // Quick Filters
  brands: string[];
  machineTypes: string[];
  priceRange: [number, number];
  hasPid: boolean | null;
  builtInGrinder: string[];
  boilerTypes: string[];
  
  // Advanced Filters (collapsible)
  releaseYearRange: [number, number];
  heatupTimeRange: [number, number];
  preInfusionTypes: string[];
  waterTankRange: [number, number];
  hasWaterFilter: boolean | null;
  buildMaterials: string[];
  warrantyRange: [number, number];
  dimensionRanges: {
    width: [number, number];
    height: [number, number];
    depth: [number, number];
  };
  weightRange: [number, number];
  powerRange: [number, number];
  isPlumbable: boolean | null;
}
```

**Key New Features Needed:**
- Full-text search input with autocomplete
- Multi-select filter chips
- Range sliders for numerical fields
- Collapsible advanced filters section
- Active filter display with removal chips
- URL state persistence
- Mobile-responsive filter drawer

#### 2. Update Machine List Logic (`src/components/MachineList.svelte`)

**UPDATES NEEDED:**
- Handle new filter structure
- Implement complex filtering logic
- Add search functionality
- Add pagination for large result sets

```typescript
// New filtering logic needed
function handleFilter(event: CustomEvent) {
  const filters = event.detail;
  
  let filtered = allMachines;
  
  // Search filter
  if (filters.searchTerm) {
    filtered = filtered.filter(m => 
      m.model_name?.toLowerCase().includes(filters.searchTerm.toLowerCase()) ||
      m.brand?.toLowerCase().includes(filters.searchTerm.toLowerCase())
    );
  }
  
  // Multi-select filters
  if (filters.brands.length > 0) {
    filtered = filtered.filter(m => filters.brands.includes(m.brand));
  }
  
  if (filters.boilerTypes.length > 0) {
    filtered = filtered.filter(m => filters.boilerTypes.includes(m.boiler_type));
  }
  
  // Range filters
  if (filters.priceRange) {
    filtered = filtered.filter(m => 
      m.price_usd >= filters.priceRange[0] && 
      m.price_usd <= filters.priceRange[1]
    );
  }
  
  // Boolean filters
  if (filters.hasPid !== null) {
    filtered = filtered.filter(m => m.has_pid === filters.hasPid);
  }
  
  // Advanced numerical ranges
  if (filters.heatupTimeRange) {
    filtered = filtered.filter(m => 
      m.heat_up_seconds >= filters.heatupTimeRange[0] && 
      m.heat_up_seconds <= filters.heatupTimeRange[1]
    );
  }
  
  filteredMachines = filtered;
}
```

#### 3. Enhanced Machine Table (`src/components/MachineTable.svelte`)

**UPDATES NEEDED:**
- Add new columns for enhanced data
- Implement data formatting rules
- Add sort functionality
- Improve mobile responsiveness

**New Columns Required:**
- Machine Type
- Heat-up Time (formatted: "30s", "2m 30s")
- Built-in Grinder (formatted: "Yes (built-in)", "No")
- Water Tank Capacity (formatted: "2.1L")
- Warranty (formatted: "2-year limited")
- Physical Dimensions (W×H×D)

#### 4. New Components Needed

**SearchBar Component** (`src/components/SearchBar.svelte`)
- Auto-complete functionality
- Recent searches
- Search suggestions

**FilterChips Component** (`src/components/FilterChips.svelte`)
- Display active filters
- Easy removal of individual filters
- Clear all functionality

**RangeSlider Component** (`src/components/RangeSlider.svelte`)
- Dual-handle range selection
- Preset value buttons
- Proper formatting for different units

---

## 🔧 Implementation Tasks

### Phase 1: Database Migration (Week 1)
- [ ] Create database migration script
- [ ] Update existing data to new schema
- [ ] Create all required indexes
- [ ] Test query performance
- [ ] Update `supabase.ts` if needed

### Phase 2: Core Search & Filtering (Week 2)
- [ ] Implement full-text search in Filters component
- [ ] Add multi-select filter capabilities
- [ ] Create range slider components
- [ ] Update MachineList filtering logic
- [ ] Add URL state management

### Phase 3: Enhanced Display (Week 3)
- [ ] Update MachineTable with new columns
- [ ] Implement data formatting functions
- [ ] Add sort functionality
- [ ] Create filter chips component
- [ ] Improve mobile responsiveness

### Phase 4: Advanced Features (Week 4)
- [ ] Implement collapsible advanced filters
- [ ] Add search autocomplete
- [ ] Create vendor comparison display
- [ ] Add loading states and error handling
- [ ] Performance optimization

---

## 🎯 Success Criteria

### Database Performance
- [ ] All filter queries execute in < 200ms
- [ ] Full-text search returns results in < 100ms
- [ ] Database supports 1000+ machine records efficiently

### User Experience
- [ ] Filter state persists in URL
- [ ] Mobile-responsive filter interface
- [ ] Real-time filter result count
- [ ] Intuitive advanced filter organization

### Data Quality
- [ ] All existing machines migrated successfully
- [ ] New data structure supports enhanced filtering
- [ ] Proper data validation and constraints

---

## 🚨 Breaking Changes & Migration Notes

### Database Changes
- Table renamed from `machines` to `espresso_machines`
- New columns added with proper data types
- Existing data mapped to new structure
- Old column names kept for backward compatibility

### Frontend Changes
- Filter component completely rewritten
- New filter state structure
- Enhanced filtering logic
- New components required

### API Changes
- Update all Supabase queries to use new table name
- Update column references in components
- Add new query patterns for advanced filtering

---

## 📋 File Changes Summary

**Database Files:**
- `db/schema.sql` - Complete rewrite with new schema
- `db/seed.ts` - Update with enhanced sample data

**Frontend Components:**
- `src/components/Filters.svelte` - Major rewrite
- `src/components/MachineList.svelte` - Update filtering logic
- `src/components/MachineTable.svelte` - Add new columns & formatting
- `src/components/SearchBar.svelte` - New component
- `src/components/FilterChips.svelte` - New component
- `src/components/RangeSlider.svelte` - New component

**Pages:**
- `src/pages/index.astro` - Update table reference if needed

**Utilities:**
- `src/lib/supabase.ts` - Potential updates for new queries
- `src/lib/formatters.ts` - New file for data formatting functions

---

*This PRD provides specific, actionable updates to transform the basic espresso machine site into a comprehensive comparison platform with advanced filtering capabilities.* 