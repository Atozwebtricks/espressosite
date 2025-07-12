<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let min: number = 0;
  export let max: number = 100;
  export let value: [number, number] = [min, max];
  export let step: number = 1;
  export let label: string = '';
  export let unit: string = '';
  export let presets: Array<{label: string, value: [number, number]}> = [];
  export let formatValue: ((value: number) => string) | null = null;

  const dispatch = createEventDispatcher();

  function handleLeftChange(event: Event) {
    const target = event.target as HTMLInputElement;
    const newValue = Number(target.value);
    const newLeftValue = Math.min(newValue, value[1]);
    value = [newLeftValue, value[1]];
    dispatch('change', value);
  }

  function handleRightChange(event: Event) {
    const target = event.target as HTMLInputElement;
    const newValue = Number(target.value);
    const newRightValue = Math.max(newValue, value[0]);
    value = [value[0], newRightValue];
    dispatch('change', value);
  }

  function selectPreset(preset: [number, number]) {
    value = [...preset];
    dispatch('change', value);
  }

  function formatDisplayValue(val: number): string {
    if (formatValue) {
      return formatValue(val);
    }
    return `${val.toLocaleString()}${unit}`;
  }

  // Calculate positions for the visual slider
  $: leftPercent = ((value[0] - min) / (max - min)) * 100;
  $: rightPercent = ((value[1] - min) / (max - min)) * 100;
</script>

<div class="range-slider">
  {#if label}
    <label class="block text-sm font-medium text-gray-700 mb-2">
      {label}: {formatDisplayValue(value[0])} - {formatDisplayValue(value[1])}
    </label>
  {/if}

  <div class="relative mb-4">
    <!-- Track -->
    <div class="absolute top-1/2 transform -translate-y-1/2 w-full h-2 bg-gray-200 rounded-full"></div>
    
    <!-- Active range -->
    <div 
      class="absolute top-1/2 transform -translate-y-1/2 h-2 bg-indigo-500 rounded-full"
      style="left: {leftPercent}%; width: {rightPercent - leftPercent}%"
    ></div>

    <!-- Left handle -->
    <input
      type="range"
      {min}
      {max}
      {step}
      value={value[0]}
      on:input={handleLeftChange}
      class="absolute w-full h-2 bg-transparent appearance-none cursor-pointer range-slider-thumb"
      style="z-index: 1"
    />

    <!-- Right handle -->
    <input
      type="range"
      {min}
      {max}
      {step}
      value={value[1]}
      on:input={handleRightChange}
      class="absolute w-full h-2 bg-transparent appearance-none cursor-pointer range-slider-thumb"
      style="z-index: 2"
    />
  </div>

  {#if presets.length > 0}
    <div class="flex flex-wrap gap-2 mt-2">
      {#each presets as preset}
        <button
          on:click={() => selectPreset(preset.value)}
          class="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full border border-gray-300 transition-colors"
          type="button"
        >
          {preset.label}
        </button>
      {/each}
    </div>
  {/if}
</div>

<style>
  .range-slider-thumb::-webkit-slider-thumb {
    appearance: none;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: #4f46e5;
    cursor: pointer;
    border: 2px solid white;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
  }

  .range-slider-thumb::-moz-range-thumb {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: #4f46e5;
    cursor: pointer;
    border: 2px solid white;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
  }

  .range-slider-thumb::-webkit-slider-track {
    background: transparent;
  }

  .range-slider-thumb::-moz-range-track {
    background: transparent;
  }

  .range-slider-thumb:focus {
    outline: none;
  }

  .range-slider-thumb:focus::-webkit-slider-thumb {
    ring: 2px;
    ring-color: #4f46e5;
    ring-opacity: 0.5;
  }
</style> 