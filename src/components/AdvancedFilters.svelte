<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Checkbox from './Checkbox.svelte';

  const dispatch = createEventDispatcher();

  export let machines: any[] = [];
  export let isOpen = false;

  // Advanced filter state
  let selectedBoilerConfigurations: string[] = [];
  let selectedHeatingSystems: string[] = [];
  let heatUpTimeRange: [number, number] = [0, 600];
  let selectedPreInfusion: string[] = [];
  let waterTankRange: [number, number] = [0, 10];
  let selectedWaterFilter: string[] = [];
  let selectedBuildMaterials: string[] = [];
  let selectedWarrantyYears: number[] = [];

  // Calculate unique values and ranges from machines
  $: boilerConfigurations = [
    'Single boiler',
    'Dual boiler', 
    'Heat-exchange'
  ];

  $: heatingSystems = [
    'Thermoblock',
    'Thermocoil'
  ];

  $: preInfusionOptions = ['None', 'Mechanical', 'Programmable'];
  $: waterFilterOptions = ['Has Filter', 'No Filter'];
  $: buildMaterials = [...new Set(machines.map(m => m.build_material))].filter(Boolean).sort();
  $: warrantyYears = [1, 2, 3, 4, 5];

  // Calculate ranges from data
  let rangesInitialized = false;
  $: {
    if (machines.length > 0 && !rangesInitialized) {
      const heatupTimes = machines.map(m => m.heat_up_seconds).filter(h => h && h > 0);
      if (heatupTimes.length > 0) {
        const maxHeatup = Math.max(...heatupTimes);
        heatUpTimeRange = [0, maxHeatup];
      }

      const tanks = machines.map(m => m.water_tank_l || (m.reservoir_ml ? m.reservoir_ml / 1000 : 0)).filter(t => t > 0);
      if (tanks.length > 0) {
        const maxTank = Math.max(...tanks);
        waterTankRange = [0, Math.ceil(maxTank)];
      }

      rangesInitialized = true;
    }
  }

  // Apply filters when any value changes
  $: {
    selectedBoilerConfigurations;
    selectedHeatingSystems;
    heatUpTimeRange;
    selectedPreInfusion;
    waterTankRange;
    selectedWaterFilter;
    selectedBuildMaterials;
    selectedWarrantyYears;

    if (machines.length > 0) {
      applyFilters();
    }
  }

  function applyFilters() {
    const filters = {
      boilerConfigurations: selectedBoilerConfigurations.length > 0 ? selectedBoilerConfigurations : undefined,
      heatingSystems: selectedHeatingSystems.length > 0 ? selectedHeatingSystems : undefined,
      maxHeatUpTime: heatUpTimeRange[1] < 600 ? heatUpTimeRange[1] : undefined,
      preInfusion: selectedPreInfusion.length > 0 ? selectedPreInfusion : undefined,
      minWaterTank: waterTankRange[0] > 0 ? waterTankRange[0] : undefined,
      waterFilter: selectedWaterFilter.length > 0 ? selectedWaterFilter : undefined,
      buildMaterials: selectedBuildMaterials.length > 0 ? selectedBuildMaterials : undefined,
      warrantyYears: selectedWarrantyYears.length > 0 ? selectedWarrantyYears : undefined,
    };
    dispatch('advancedFilter', filters);
  }

  function toggleBoilerConfiguration(config: string) {
    if (selectedBoilerConfigurations.includes(config)) {
      selectedBoilerConfigurations = selectedBoilerConfigurations.filter(c => c !== config);
    } else {
      selectedBoilerConfigurations = [...selectedBoilerConfigurations, config];
    }
  }

  function toggleHeatingSystem(system: string) {
    if (selectedHeatingSystems.includes(system)) {
      selectedHeatingSystems = selectedHeatingSystems.filter(s => s !== system);
    } else {
      selectedHeatingSystems = [...selectedHeatingSystems, system];
    }
  }

  function togglePreInfusion(option: string) {
    if (selectedPreInfusion.includes(option)) {
      selectedPreInfusion = selectedPreInfusion.filter(o => o !== option);
    } else {
      selectedPreInfusion = [...selectedPreInfusion, option];
    }
  }

  function toggleBuildMaterial(material: string) {
    if (selectedBuildMaterials.includes(material)) {
      selectedBuildMaterials = selectedBuildMaterials.filter(m => m !== material);
    } else {
      selectedBuildMaterials = [...selectedBuildMaterials, material];
    }
  }

  function toggleWarrantyYear(year: number) {
    if (selectedWarrantyYears.includes(year)) {
      selectedWarrantyYears = selectedWarrantyYears.filter(y => y !== year);
    } else {
      selectedWarrantyYears = [...selectedWarrantyYears, year];
    }
  }

  function toggleWaterFilter(option: string) {
    if (selectedWaterFilter.includes(option)) {
      selectedWaterFilter = selectedWaterFilter.filter(o => o !== option);
    } else {
      selectedWaterFilter = [...selectedWaterFilter, option];
    }
  }

  function clearAdvancedFilters() {
    selectedBoilerConfigurations = [];
    selectedHeatingSystems = [];
    heatUpTimeRange = [0, 600];
    selectedPreInfusion = [];
    waterTankRange = [0, 10];
    selectedWaterFilter = [];
    selectedBuildMaterials = [];
    selectedWarrantyYears = [];
  }

  function formatHeatUpTime(seconds: number): string {
    if (seconds === 0) return 'Show All';
    if (seconds < 60) return `${seconds}s`;
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    if (remainingSeconds === 0) return `${minutes}m`;
    return `${minutes}m ${remainingSeconds}s`;
  }

  function formatTankSize(liters: number): string {
    if (liters === 0) return 'Show All';
    if (liters >= 10) return '10+ L';
    return `${liters}L`;
  }

  // Handle global escape key
  function handleGlobalKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape' && isOpen) {
      isOpen = false;
    }
  }

  // Add/remove global event listeners
  $: if (typeof window !== 'undefined') {
    if (isOpen) {
      window.addEventListener('keydown', handleGlobalKeydown);
    } else {
      window.removeEventListener('keydown', handleGlobalKeydown);
    }
  }
</script>

<!-- Overlay -->
{#if isOpen}
  <div 
    class="fixed inset-0 bg-[#202020ad] z-40 transition-opacity duration-300"
    on:click={() => isOpen = false}
    on:keydown={(e) => e.key === 'Escape' && (isOpen = false)}
    role="button"
    tabindex="0"
    aria-label="Close filters"
  ></div>
{/if}

<!-- Side Drawer -->
<div class="fixed top-0 right-0 h-full w-full sm:w-96 bg-white shadow-xl z-50 transform transition-transform duration-300 ease-in-out {isOpen ? 'translate-x-0' : 'translate-x-full'}">
  <!-- Header -->
  <div class="flex items-center justify-between p-6 border-b border-gray-200">
    <div class="flex items-center gap-3">
      <h2 class="text-lg font-semibold text-gray-900">Advanced Filters</h2>
      
      {#if selectedBoilerConfigurations.length > 0 || selectedHeatingSystems.length > 0 || selectedPreInfusion.length > 0 || selectedBuildMaterials.length > 0 || selectedWarrantyYears.length > 0 || selectedWaterFilter.length > 0 || heatUpTimeRange[1] < 600 || waterTankRange[0] > 0}
        <span class="bg-gray-200 text-primary text-xs rounded-full px-2 py-0.5">
          Active
        </span>
      {/if}
    </div>
    <button
      class="p-2 hover:bg-gray-100 rounded-md transition-colors duration-200"
      on:click={() => isOpen = false}
      aria-label="Close filters"
    >
      <svg class="h-5 w-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>
  </div>

  <!-- Content -->
  <div class="p-6 overflow-y-auto h-full pb-32">
    <div class="space-y-8">
          <!-- Clear Advanced Filters -->
          {#if selectedBoilerConfigurations.length > 0 || selectedHeatingSystems.length > 0 || selectedPreInfusion.length > 0 || selectedBuildMaterials.length > 0 || selectedWarrantyYears.length > 0 || selectedWaterFilter.length > 0 || heatUpTimeRange[1] < 600 || waterTankRange[0] > 0}
          <div class="">
            <button
              class="text-sm font-medium text-gray-600 hover:text-gray-800 underline"
              on:click={clearAdvancedFilters}
            >
              Clear Advanced Filters
            </button>
          </div>
        {/if}
        
        <!-- Boiler Configuration -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Boiler Configuration</label>
          <div class="space-y-1">
            {#each boilerConfigurations as config}
              <Checkbox 
                label={config}
                value={config}
                checked={selectedBoilerConfigurations.includes(config)}
                on:change={() => toggleBoilerConfiguration(config)}
              />
            {/each}
          </div>
        </div>

        <!-- Heating System -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Heating System</label>
          <div class="space-y-1">
            {#each heatingSystems as system}
              <Checkbox 
                label={system}
                value={system}
                checked={selectedHeatingSystems.includes(system)}
                on:change={() => toggleHeatingSystem(system)}
              />
            {/each}
          </div>
        </div>

        <!-- Heat-Up Time Range -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-3">
            Max Heat-Up Time: <span class="inline-flex items-center px-2 py-1 rounded-full text-sm font-medium bg-gray-200 text-primary">
              {formatHeatUpTime(heatUpTimeRange[1])}
            </span>
          </label>
          <div class="relative">
            <!-- Single Range Slider -->
            <div class="relative h-8 flex items-center">
              <!-- Track -->
              <div class="absolute w-full h-2 bg-gray-200 rounded-full"></div>
              
              <!-- Active Range -->
              <div 
                class="absolute h-2 bg-cta rounded-full"
                style="width: {(heatUpTimeRange[1] / 600) * 100}%"
              ></div>
              
              <!-- Slider -->
              <input
                type="range"
                min="0"
                max="600"
                step="30"
                bind:value={heatUpTimeRange[1]}
                class="absolute w-full h-2 bg-transparent appearance-none cursor-pointer slider-thumb"
              />
            </div>
            
            <!-- Min/Max Labels -->
            <div class="flex justify-between text-xs text-gray-500 mt-2">
              <span>0s</span>
              <span>10 min</span>
            </div>
          </div>
        </div>

        <!-- Pre-Infusion -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Pre-Infusion</label>
          <div class="space-y-1">
            {#each preInfusionOptions as option}
              <Checkbox 
                label={option}
                value={option}
                checked={selectedPreInfusion.includes(option)}
                on:change={() => togglePreInfusion(option)}
              />
            {/each}
          </div>
        </div>

        <!-- Water Tank Capacity -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-3">
            Min Water Tank: <span class="inline-flex items-center px-2 py-1 rounded-full text-sm font-medium bg-gray-200 text-primary">
              {formatTankSize(waterTankRange[0])}
            </span>
          </label>
          <div class="relative">
            <!-- Single Range Slider -->
            <div class="relative h-8 flex items-center">
              <!-- Track -->
              <div class="absolute w-full h-2 bg-gray-200 rounded-full"></div>
              
              <!-- Active Range -->
              <div 
                class="absolute h-2 bg-cta rounded-full"
                style="width: {(waterTankRange[0] / 10) * 100}%"
              ></div>
              
              <!-- Slider -->
              <input
                type="range"
                min="0"
                max="10"
                step="0.5"
                bind:value={waterTankRange[0]}
                class="absolute w-full h-2 bg-transparent appearance-none cursor-pointer slider-thumb"
              />
            </div>
            
            <!-- Min/Max Labels -->
            <div class="flex justify-between text-xs text-gray-500 mt-2">
              <span>0L</span>
              <span>10+ Liters</span>
            </div>
          </div>
        </div>

        <!-- Water Filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Water Filter</label>
          <div class="space-y-1">
            {#each waterFilterOptions as option}
              <Checkbox 
                label={option}
                value={option}
                checked={selectedWaterFilter.includes(option)}
                on:change={() => toggleWaterFilter(option)}
              />
            {/each}
          </div>
        </div>

        <!-- Build Materials -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Build Material</label>
          <div class="space-y-1">
            {#each buildMaterials as material}
              <Checkbox 
                label={material}
                value={material}
                checked={selectedBuildMaterials.includes(material)}
                on:change={() => toggleBuildMaterial(material)}
              />
            {/each}
          </div>
        </div>

        <!-- Warranty Years -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Warranty (Years)</label>
          <div class="flex flex-wrap gap-2">
            {#each warrantyYears as year}
              <button
                class="px-3 py-1 text-sm font-medium rounded-full transition-colors duration-200 {
                  selectedWarrantyYears.includes(year)
                    ? 'bg-gray-600 text-white border-gray-200 border'
                    : 'bg-gray-100 text-gray-700 border-gray-200 border hover:bg-gray-200'
                }"
                on:click={() => toggleWarrantyYear(year)}
              >
                {year} year{year > 1 ? 's' : ''}
              </button>
            {/each}
          </div>
        </div>

    
      </div>
    </div>
  </div>

<style>
  .slider-thumb {
    pointer-events: auto;
  }

  .slider-thumb::-webkit-slider-thumb {
    appearance: none;
    height: 20px;
    width: 20px;
    border-radius: 50%;
    background: #ffffff;
    cursor: grab;
    border: 3px solid #6366f1;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.1);
    transition: all 0.2s ease-in-out;
  }

  .slider-thumb::-webkit-slider-thumb:hover {
    transform: scale(1.1);
    border-color: #4f46e5;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2), 0 0 0 2px rgba(99, 102, 241, 0.2);
  }

  .slider-thumb::-webkit-slider-thumb:active {
    cursor: grabbing;
    transform: scale(1.05);
    border-color: #3730a3;
  }

  .slider-thumb::-moz-range-thumb {
    height: 20px;
    width: 20px;
    border-radius: 50%;
    background: #ffffff;
    cursor: grab;
    border: 3px solid #6366f1;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.1);
    transition: all 0.2s ease-in-out;
  }

  .slider-thumb::-moz-range-thumb:hover {
    transform: scale(1.1);
    border-color: #4f46e5;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2), 0 0 0 2px rgba(99, 102, 241, 0.2);
  }

  .slider-thumb::-moz-range-thumb:active {
    cursor: grabbing;
    transform: scale(1.05);
    border-color: #3730a3;
  }

  .slider-thumb::-webkit-slider-track {
    background: transparent;
  }

  .slider-thumb::-moz-range-track {
    background: transparent;
  }
</style> 