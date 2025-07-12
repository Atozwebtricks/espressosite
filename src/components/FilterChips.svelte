<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let activeFilters: Record<string, any> = {};

  const dispatch = createEventDispatcher();

  // Convert active filters to displayable chips
  $: chips = Object.entries(activeFilters)
    .filter(([key, value]) => {
      // Filter out empty or default values
      if (value === null || value === undefined || value === '') return false;
      if (Array.isArray(value) && value.length === 0) return false;
      if (typeof value === 'boolean' && value === false) return false;
      if (Array.isArray(value) && value.length === 2) {
        // For range filters, check if it's not the default full range
        const [min, max] = value;
        if (key === 'priceRange' && min === 0 && max >= 10000) return false;
        if (key === 'releaseYearRange' && min === 1980 && max >= 2024) return false;
        if (key === 'heatupTimeRange' && min === 0 && max >= 600) return false;
        if (key === 'waterTankRange' && min === 0 && max >= 10) return false;
        if (key === 'warrantyRange' && min === 0 && max >= 10) return false;
        if (key === 'weightRange' && min === 0 && max >= 100) return false;
        if (key === 'powerRange' && min === 0 && max >= 3000) return false;
      }
      return true;
    })
    .map(([key, value]) => ({
      key,
      value,
      label: formatFilterLabel(key, value),
    }));

  function formatFilterLabel(key: string, value: any): string {
    switch (key) {
      case 'searchTerm':
        return `Search: "${value}"`;
      case 'brands':
        return Array.isArray(value) ? `Brand: ${value.join(', ')}` : `Brand: ${value}`;
      case 'machineTypes':
        return Array.isArray(value) ? `Type: ${value.join(', ')}` : `Type: ${value}`;
      case 'boilerTypes':
        return Array.isArray(value) ? `Boiler: ${value.join(', ')}` : `Boiler: ${value}`;
      case 'heatingSystems':
        return Array.isArray(value) ? `Heating: ${value.join(', ')}` : `Heating: ${value}`;
      case 'builtInGrinder':
        return Array.isArray(value) ? `Grinder: ${value.join(', ')}` : `Grinder: ${value}`;
      case 'buildMaterials':
        return Array.isArray(value) ? `Material: ${value.join(', ')}` : `Material: ${value}`;
      case 'numberOfBoilers':
        return Array.isArray(value) ? `Boilers: ${value.map(n => `${n} boiler${n > 1 ? 's' : ''}`).join(', ')}` : `Boilers: ${value}`;
      case 'priceRange':
        return `Price: $${value[0].toLocaleString()} - $${value[1].toLocaleString()}`;
      case 'releaseYearRange':
        return `Year: ${value[0]} - ${value[1]}`;
      case 'heatupTimeRange':
        return `Heat-up: ${formatTime(value[0])} - ${formatTime(value[1])}`;
      case 'waterTankRange':
        return `Tank: ${value[0]}L - ${value[1]}L`;
      case 'warrantyRange':
        return `Warranty: ${value[0]} - ${value[1]} years`;
      case 'weightRange':
        return `Weight: ${value[0]} - ${value[1]} lbs`;
      case 'powerRange':
        return `Power: ${value[0]} - ${value[1]}W`;
      case 'hasPid':
        return value ? 'Has PID' : 'No PID';
      case 'hasPreInfusion':
        return value ? 'Has Pre-infusion' : 'No Pre-infusion';
      case 'hasWaterFilter':
        return value ? 'Has Water Filter' : 'No Water Filter';
      case 'isPlumbable':
        return value ? 'Plumbable' : 'Not Plumbable';
      default:
        return `${key}: ${value}`;
    }
  }

  function formatTime(seconds: number): string {
    if (seconds < 60) return `${seconds}s`;
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return remainingSeconds === 0 ? `${minutes}m` : `${minutes}m ${remainingSeconds}s`;
  }

  function removeFilter(key: string) {
    dispatch('removeFilter', key);
  }

  function clearAllFilters() {
    dispatch('clearAll');
  }
</script>

{#if chips.length > 0}
  <div class="flex flex-wrap items-center gap-2 mb-4 p-3 bg-gray-50 rounded-lg">
    <span class="text-sm font-medium text-gray-700">Active Filters:</span>
    
    {#each chips as chip}
      <div class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-indigo-100 text-indigo-800">
        <span class="mr-2">{chip.label}</span>
        <button
          on:click={() => removeFilter(chip.key)}
          class="flex-shrink-0 ml-1 h-4 w-4 rounded-full inline-flex items-center justify-center text-indigo-400 hover:bg-indigo-200 hover:text-indigo-600 focus:outline-none focus:bg-indigo-200 focus:text-indigo-600"
          type="button"
          aria-label="Remove filter"
        >
          <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>
    {/each}
    
    {#if chips.length > 1}
      <button
        on:click={clearAllFilters}
        class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-red-100 text-red-800 hover:bg-red-200 focus:outline-none focus:bg-red-200"
        type="button"
      >
        <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
        </svg>
        Clear All
      </button>
    {/if}
  </div>
{/if} 