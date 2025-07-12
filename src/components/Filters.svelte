<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import SearchBar from './SearchBar.svelte';
  import FilterChips from './FilterChips.svelte';
  import RangeSlider from './RangeSlider.svelte';

  const dispatch = createEventDispatcher();

  export let machines: any[] = [];

  // Filter state variables
  let searchTerm = '';
  let selectedBrands: string[] = [];
  let selectedMachineTypes: string[] = [];
  let selectedBoilerTypes: string[] = [];
  let selectedHeatingSystems: string[] = [];
  let selectedBuiltInGrinder: string[] = [];
  let selectedBuildMaterials: string[] = [];
  let selectedNumberOfBoilers: number[] = [];
  let hasPid: boolean | null = null;
  let hasPreInfusion: boolean | null = null;
  let hasWaterFilter: boolean | null = null;
  let isPlumbable: boolean | null = null;

  // Range filters
  let priceRange: [number, number] = [0, 10000];
  let releaseYearRange: [number, number] = [1980, 2024];
  let heatupTimeRange: [number, number] = [0, 600];
  let waterTankRange: [number, number] = [0, 10];
  let warrantyRange: [number, number] = [0, 10];
  let weightRange: [number, number] = [0, 100];
  let powerRange: [number, number] = [500, 3000];
  
  let showAdvancedFilters = false;

  // Calculate unique values from machines
  $: brands = [...new Set(machines.map(m => m.brand))].filter(Boolean).sort();
  $: machineTypes = ['Semi-automatic', 'Automatic', 'Super-automatic', 'Manual'];
  $: boilerTypes = [
    'Single boiler', 
    'Heat-exchange', 
    'Dual boiler'
  ];
  $: heatingSystems = [
    'Classic tank',
    'Thermoblock', 
    'Thermocoil', 
    'Thermojet', 
    'Quick Heat boiler'
  ];
  $: builtInGrinderOptions = [...new Set(machines.map(m => m.built_in_grinder))].filter(Boolean).sort();
  $: buildMaterials = [...new Set(machines.map(m => m.build_material))].filter(Boolean).sort();
  $: numberOfBoilersOptions = [...new Set(machines.map(m => m.number_of_boilers))].filter(n => n && n > 0).sort();

  // Calculate ranges from data (only set initial values, don't override user selections)
  let rangesInitialized = false;
  $: {
    if (machines.length > 0 && !rangesInitialized) {
      const prices = machines.map(m => m.price_usd || m.price_msrp || 0).filter(p => p > 0);
      const maxPrice = Math.max(...prices, 1000);
      priceRange = [0, Math.ceil(maxPrice)];

      const years = machines.map(m => m.release_year).filter(y => y && y >= 1980);
      const maxYear = Math.max(...years, 2024);
      const minYear = Math.min(...years, 1980);
      releaseYearRange = [minYear, maxYear];

      const heatupTimes = machines.map(m => m.heat_up_seconds).filter(h => h && h > 0);
      if (heatupTimes.length > 0) {
        const maxHeatup = Math.max(...heatupTimes);
        heatupTimeRange = [0, maxHeatup];
      }

      const tanks = machines.map(m => m.water_tank_l || (m.reservoir_ml ? m.reservoir_ml / 1000 : 0)).filter(t => t > 0);
      if (tanks.length > 0) {
        const maxTank = Math.max(...tanks);
        waterTankRange = [0, Math.ceil(maxTank)];
      }

      const warranties = machines.map(m => m.warranty_years).filter(w => w && w > 0);
      if (warranties.length > 0) {
        const maxWarranty = Math.max(...warranties);
        warrantyRange = [0, maxWarranty];
      }

      const weights = machines.map(m => m.weight_lbs).filter(w => w && w > 0);
      if (weights.length > 0) {
        const maxWeight = Math.max(...weights);
        weightRange = [0, Math.ceil(maxWeight)];
      }

      const powers = machines.map(m => m.power_watts).filter(p => p && p > 0);
      if (powers.length > 0) {
        const maxPower = Math.max(...powers);
        const minPower = Math.min(...powers);
        powerRange = [minPower, maxPower];
      }

      rangesInitialized = true;
    }
  }

  // Active filters for chips
  $: activeFilters = {
    searchTerm: searchTerm || undefined,
    brands: selectedBrands.length > 0 ? selectedBrands : undefined,
    machineTypes: selectedMachineTypes.length > 0 ? selectedMachineTypes : undefined,
    boilerTypes: selectedBoilerTypes.length > 0 ? selectedBoilerTypes : undefined,
    heatingSystems: selectedHeatingSystems.length > 0 ? selectedHeatingSystems : undefined,
    builtInGrinder: selectedBuiltInGrinder.length > 0 ? selectedBuiltInGrinder : undefined,
    buildMaterials: selectedBuildMaterials.length > 0 ? selectedBuildMaterials : undefined,
    numberOfBoilers: selectedNumberOfBoilers.length > 0 ? selectedNumberOfBoilers : undefined,
    hasPid: hasPid !== null ? hasPid : undefined,
    hasPreInfusion: hasPreInfusion !== null ? hasPreInfusion : undefined,
    hasWaterFilter: hasWaterFilter !== null ? hasWaterFilter : undefined,
    isPlumbable: isPlumbable !== null ? isPlumbable : undefined,
    priceRange: (priceRange[0] > 0 || priceRange[1] < 10000) ? priceRange : undefined,
    releaseYearRange: (releaseYearRange[0] > 1980 || releaseYearRange[1] < 2024) ? releaseYearRange : undefined,
    heatupTimeRange: (heatupTimeRange[0] > 0 || heatupTimeRange[1] < 600) ? heatupTimeRange : undefined,
    waterTankRange: (waterTankRange[0] > 0 || waterTankRange[1] < 10) ? waterTankRange : undefined,
    warrantyRange: (warrantyRange[0] > 0 || warrantyRange[1] < 10) ? warrantyRange : undefined,
    weightRange: (weightRange[0] > 0 || weightRange[1] < 100) ? weightRange : undefined,
    powerRange: (powerRange[0] > 500 || powerRange[1] < 3000) ? powerRange : undefined,
  };

  function applyFilters() {
    const filters = {
      searchTerm,
      brands: selectedBrands,
      machineTypes: selectedMachineTypes,
      boilerTypes: selectedBoilerTypes,
      heatingSystems: selectedHeatingSystems,
      builtInGrinder: selectedBuiltInGrinder,
      buildMaterials: selectedBuildMaterials,
      numberOfBoilers: selectedNumberOfBoilers,
      hasPid,
      hasPreInfusion,
      hasWaterFilter,
      isPlumbable,
      priceRange,
      releaseYearRange,
      heatupTimeRange,
      waterTankRange,
      warrantyRange,
      weightRange,
      powerRange,
    };
    dispatch('filter', filters);
  }

  // Apply filters when any value changes - comprehensive reactivity
  $: {
    searchTerm;
    selectedBrands;
    selectedMachineTypes;
    selectedBoilerTypes;
    selectedHeatingSystems;
    selectedBuiltInGrinder;
    selectedBuildMaterials;
    selectedNumberOfBoilers;
    hasPid;
    hasPreInfusion;
    hasWaterFilter;
    isPlumbable;
    priceRange;
    releaseYearRange;
    heatupTimeRange;
    waterTankRange;
    warrantyRange;
    weightRange;
    powerRange;

    if (machines.length > 0) {
      applyFilters();
    }
  }

  function handleSearch(event: CustomEvent) {
    searchTerm = event.detail;
  }

  function handleMultiSelect(filterArray: string[], value: string) {
    const index = filterArray.indexOf(value);
    if (index > -1) {
      return filterArray.filter(item => item !== value);
    } else {
      return [...filterArray, value];
    }
  }

  function handleNumberMultiSelect(filterArray: number[], value: number) {
    const index = filterArray.indexOf(value);
    if (index > -1) {
      return filterArray.filter(item => item !== value);
    } else {
      return [...filterArray, value];
    }
  }

  function handleRemoveFilter(event: CustomEvent) {
    const key = event.detail;
    switch (key) {
      case 'searchTerm':
        searchTerm = '';
        break;
      case 'brands':
        selectedBrands = [];
        break;
      case 'machineTypes':
        selectedMachineTypes = [];
        break;
      case 'boilerTypes':
        selectedBoilerTypes = [];
        break;
      case 'heatingSystems':
        selectedHeatingSystems = [];
        break;
      case 'builtInGrinder':
        selectedBuiltInGrinder = [];
        break;
      case 'buildMaterials':
        selectedBuildMaterials = [];
        break;
      case 'numberOfBoilers':
        selectedNumberOfBoilers = [];
        break;
      case 'hasPid':
        hasPid = null;
        break;
      case 'hasPreInfusion':
        hasPreInfusion = null;
        break;
      case 'hasWaterFilter':
        hasWaterFilter = null;
        break;
      case 'isPlumbable':
        isPlumbable = null;
        break;
      case 'priceRange':
        priceRange = [0, 10000];
        break;
      case 'releaseYearRange':
        releaseYearRange = [1980, 2024];
        break;
      case 'heatupTimeRange':
        heatupTimeRange = [0, 600];
        break;
      case 'waterTankRange':
        waterTankRange = [0, 10];
        break;
      case 'warrantyRange':
        warrantyRange = [0, 10];
        break;
      case 'weightRange':
        weightRange = [0, 100];
        break;
      case 'powerRange':
        powerRange = [500, 3000];
        break;
    }
  }

  function clearAllFilters() {
    searchTerm = '';
    selectedBrands = [];
    selectedMachineTypes = [];
    selectedBoilerTypes = [];
    selectedHeatingSystems = [];
    selectedBuiltInGrinder = [];
    selectedBuildMaterials = [];
    selectedNumberOfBoilers = [];
    hasPid = null;
    hasPreInfusion = null;
    hasWaterFilter = null;
    isPlumbable = null;
    priceRange = [0, 10000];
    releaseYearRange = [1980, 2024];
    heatupTimeRange = [0, 600];
    waterTankRange = [0, 10];
    warrantyRange = [0, 10];
    weightRange = [0, 100];
    powerRange = [500, 3000];
  }
</script>

<div class="bg-white p-6 rounded-lg shadow mb-6">
  <!-- Search Bar -->
  <div class="mb-6">
    <SearchBar machines={machines} on:search={handleSearch} />
  </div>

  <!-- Filter Chips -->
  <FilterChips {activeFilters} on:removeFilter={handleRemoveFilter} on:clearAll={clearAllFilters} />

  <!-- Quick Filters -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    <!-- Brand Filter -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Brand</label>
      <div class="space-y-2 max-h-32 overflow-y-auto">
        {#each brands as brand}
          <label class="flex items-center">
            <input
              type="checkbox"
              class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              checked={selectedBrands.includes(brand)}
              on:change={() => selectedBrands = handleMultiSelect(selectedBrands, brand)}
            />
            <span class="ml-2 text-sm text-gray-700">{brand}</span>
          </label>
        {/each}
      </div>
    </div>

    <!-- Machine Type Filter -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Machine Type</label>
      <div class="space-y-2">
        {#each machineTypes as type}
          <label class="flex items-center">
            <input
              type="checkbox"
              class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              checked={selectedMachineTypes.includes(type)}
              on:change={() => selectedMachineTypes = handleMultiSelect(selectedMachineTypes, type)}
            />
            <span class="ml-2 text-sm text-gray-700">{type}</span>
          </label>
        {/each}
      </div>
    </div>

    <!-- Boiler Configuration Filter -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">Boiler Configuration</label>
      <div class="space-y-2">
        {#each boilerTypes as boiler}
          <label class="flex items-center">
            <input
              type="checkbox"
              class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              checked={selectedBoilerTypes.includes(boiler)}
              on:change={() => selectedBoilerTypes = handleMultiSelect(selectedBoilerTypes, boiler)}
            />
            <span class="ml-2 text-sm text-gray-700">{boiler}</span>
          </label>
        {/each}
      </div>
    </div>

    <!-- PID Control -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-2">PID Control</label>
      <div class="space-y-2">
        <label class="flex items-center">
          <input
            type="radio"
            name="pid"
            class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
            checked={hasPid === null}
            on:change={() => hasPid = null}
          />
          <span class="ml-2 text-sm text-gray-700">Any</span>
        </label>
        <label class="flex items-center">
          <input
            type="radio"
            name="pid"
            class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
            checked={hasPid === true}
            on:change={() => hasPid = true}
          />
          <span class="ml-2 text-sm text-gray-700">Has PID</span>
        </label>
        <label class="flex items-center">
          <input
            type="radio"
            name="pid"
            class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
            checked={hasPid === false}
            on:change={() => hasPid = false}
          />
          <span class="ml-2 text-sm text-gray-700">No PID</span>
        </label>
      </div>
    </div>
  </div>

  <!-- Price Range -->
  <div class="mb-6">
    <RangeSlider
      min={0}
      max={Math.max(10000, priceRange[1])}
      bind:value={priceRange}
      step={50}
      label="Price Range"
      unit=""
      formatValue={(val) => `$${val.toLocaleString()}`}
      presets={[
        { label: 'Under $500', value: [0, 500] },
        { label: '$500-$1000', value: [500, 1000] },
        { label: '$1000-$2000', value: [1000, 2000] },
        { label: 'Over $2000', value: [2000, 10000] }
      ]}
    />
  </div>

  <!-- Advanced Filters Toggle -->
  <div class="mb-4">
    <button
      on:click={() => showAdvancedFilters = !showAdvancedFilters}
      class="flex items-center text-sm font-medium text-indigo-600 hover:text-indigo-800"
      type="button"
    >
      <svg class="h-4 w-4 mr-1 transform {showAdvancedFilters ? 'rotate-90' : ''} transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
      </svg>
      Advanced Filters
    </button>
  </div>

  <!-- Advanced Filters -->
  {#if showAdvancedFilters}
    <div class="border-t pt-6 space-y-6">
      <!-- Heating System -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Heating System</label>
        <div class="flex flex-wrap gap-2">
          {#each heatingSystems as system}
            <label class="flex items-center">
              <input
                type="checkbox"
                class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                checked={selectedHeatingSystems.includes(system)}
                on:change={() => selectedHeatingSystems = handleMultiSelect(selectedHeatingSystems, system)}
              />
              <span class="ml-2 text-sm text-gray-700">{system}</span>
            </label>
          {/each}
        </div>
      </div>

      <!-- Number of Boilers -->
      {#if numberOfBoilersOptions.length > 0}
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Number of Boilers</label>
        <div class="flex flex-wrap gap-2">
          {#each numberOfBoilersOptions as count}
            <label class="flex items-center">
              <input
                type="checkbox"
                class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                checked={selectedNumberOfBoilers.includes(count)}
                on:change={() => selectedNumberOfBoilers = handleNumberMultiSelect(selectedNumberOfBoilers, count)}
              />
              <span class="ml-2 text-sm text-gray-700">{count} boiler{count > 1 ? 's' : ''}</span>
            </label>
          {/each}
        </div>
      </div>
      {/if}

      <!-- Built-in Grinder -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Built-in Grinder</label>
        <div class="flex flex-wrap gap-2">
          {#each builtInGrinderOptions as option}
            <label class="flex items-center">
              <input
                type="checkbox"
                class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                checked={selectedBuiltInGrinder.includes(option)}
                on:change={() => selectedBuiltInGrinder = handleMultiSelect(selectedBuiltInGrinder, option)}
              />
              <span class="ml-2 text-sm text-gray-700 capitalize">{option}</span>
            </label>
          {/each}
        </div>
      </div>

      <!-- Build Materials -->
      {#if buildMaterials.length > 0}
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">Build Materials</label>
        <div class="flex flex-wrap gap-2">
          {#each buildMaterials as material}
            <label class="flex items-center">
              <input
                type="checkbox"
                class="h-4 w-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                checked={selectedBuildMaterials.includes(material)}
                on:change={() => selectedBuildMaterials = handleMultiSelect(selectedBuildMaterials, material)}
              />
              <span class="ml-2 text-sm text-gray-700">{material}</span>
            </label>
          {/each}
        </div>
      </div>
      {/if}

      <!-- Additional Range Filters -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <RangeSlider
          min={releaseYearRange[0]}
          max={releaseYearRange[1]}
          bind:value={releaseYearRange}
          step={1}
          label="Release Year"
          unit=""
        />

        <RangeSlider
          min={0}
          max={Math.max(600, heatupTimeRange[1])}
          bind:value={heatupTimeRange}
          step={5}
          label="Heat-up Time"
          unit="s"
          formatValue={(val) => val < 60 ? `${val}s` : `${Math.floor(val/60)}m ${val%60}s`}
          presets={[
            { label: 'Under 30s', value: [0, 30] },
            { label: '30s-1min', value: [30, 60] },
            { label: '1-2min', value: [60, 120] },
            { label: 'Over 2min', value: [120, 600] }
          ]}
        />

        <RangeSlider
          min={0}
          max={Math.max(10, waterTankRange[1])}
          bind:value={waterTankRange}
          step={0.1}
          label="Water Tank Capacity"
          unit="L"
        />

        <RangeSlider
          min={0}
          max={Math.max(10, warrantyRange[1])}
          bind:value={warrantyRange}
          step={1}
          label="Warranty"
          unit=" years"
        />

        <RangeSlider
          min={0}
          max={Math.max(100, weightRange[1])}
          bind:value={weightRange}
          step={1}
          label="Weight"
          unit=" lbs"
        />

        <RangeSlider
          min={powerRange[0]}
          max={powerRange[1]}
          bind:value={powerRange}
          step={50}
          label="Power Consumption"
          unit="W"
        />
      </div>

      <!-- Boolean Filters -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Pre-infusion -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Pre-infusion</label>
          <div class="space-y-2">
            <label class="flex items-center">
              <input
                type="radio"
                name="preInfusion"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={hasPreInfusion === null}
                on:change={() => hasPreInfusion = null}
              />
              <span class="ml-2 text-sm text-gray-700">Any</span>
            </label>
            <label class="flex items-center">
              <input
                type="radio"
                name="preInfusion"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={hasPreInfusion === true}
                on:change={() => hasPreInfusion = true}
              />
              <span class="ml-2 text-sm text-gray-700">Yes</span>
            </label>
            <label class="flex items-center">
              <input
                type="radio"
                name="preInfusion"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={hasPreInfusion === false}
                on:change={() => hasPreInfusion = false}
              />
              <span class="ml-2 text-sm text-gray-700">No</span>
            </label>
          </div>
        </div>

        <!-- Water Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Water Filter Compatible</label>
          <div class="space-y-2">
            <label class="flex items-center">
              <input
                type="radio"
                name="waterFilter"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={hasWaterFilter === null}
                on:change={() => hasWaterFilter = null}
              />
              <span class="ml-2 text-sm text-gray-700">Any</span>
            </label>
            <label class="flex items-center">
              <input
                type="radio"
                name="waterFilter"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={hasWaterFilter === true}
                on:change={() => hasWaterFilter = true}
              />
              <span class="ml-2 text-sm text-gray-700">Yes</span>
            </label>
            <label class="flex items-center">
              <input
                type="radio"
                name="waterFilter"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={hasWaterFilter === false}
                on:change={() => hasWaterFilter = false}
              />
              <span class="ml-2 text-sm text-gray-700">No</span>
            </label>
          </div>
        </div>

        <!-- Plumbable -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Plumbable</label>
          <div class="space-y-2">
            <label class="flex items-center">
              <input
                type="radio"
                name="plumbable"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={isPlumbable === null}
                on:change={() => isPlumbable = null}
              />
              <span class="ml-2 text-sm text-gray-700">Any</span>
            </label>
            <label class="flex items-center">
              <input
                type="radio"
                name="plumbable"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={isPlumbable === true}
                on:change={() => isPlumbable = true}
              />
              <span class="ml-2 text-sm text-gray-700">Yes</span>
            </label>
            <label class="flex items-center">
              <input
                type="radio"
                name="plumbable"
                class="h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                checked={isPlumbable === false}
                on:change={() => isPlumbable = false}
              />
              <span class="ml-2 text-sm text-gray-700">No</span>
            </label>
          </div>
        </div>
      </div>
    </div>
  {/if}
</div> 