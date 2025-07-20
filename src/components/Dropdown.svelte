<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Checkbox from './Checkbox.svelte';

  const dispatch = createEventDispatcher();

  export let label: string;
  export let options: string[] = [];
  export let selectedOptions: string[] = [];
  export let isOpen: boolean = false;
  export let dropdownClass: string = '';
  export let maxHeight: string = 'max-h-48';
  export let width: string = 'w-44';

  function toggleOption(option: string) {
    dispatch('toggle', { option });
  }

  function handleButtonClick() {
    dispatch('toggle-dropdown');
  }
</script>

<div class="relative dropdown-container w-full sm:w-auto">
  <button 
    class="w-full sm:w-auto inline-flex items-center gap-2 px-3 py-2  rounded-md text-sm font-medium border-2 border-gray-900 text-gray-700 bg-white/80 hover:bg-gray-50 focus:outline-none custom-dropdown-button transition-all duration-200"
    on:click={handleButtonClick}
  >
    <span class="text-sm text-gray-900">{label}</span>
    {#if selectedOptions.length > 0}
      <span class="inline-flex items-center justify-center min-w-[20px] h-5 px-1.5 bg-primary text-white text-xs font-semibold rounded-full">
        {selectedOptions.length}
      </span>
    {/if}
    <svg class="h-3 w-3 text-gray-600 transition-transform duration-200 {isOpen ? 'rotate-180' : ''}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
  </button>
  
  {#if isOpen}
    <div class="absolute z-20 mt-1 {width} bg-white border border-gray-200 rounded-md shadow-lg {dropdownClass}">
      <div class="{maxHeight} overflow-y-auto p-1">
        {#each options as option}
          <Checkbox 
            size="sm"
            label={option}
            value={option}
            checked={selectedOptions.includes(option)}
            on:change={() => toggleOption(option)}
          />
        {/each}
      </div>
    </div>
  {/if}
</div>

<style>
  .custom-dropdown-button:focus {
    border-color: var(--color-primary);
    box-shadow: 0 0 0 3px rgba(88, 0, 0, 0.2);

  }
</style> 