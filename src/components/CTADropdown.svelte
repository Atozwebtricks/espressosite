<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  export let vendors: Array<{name: string, url: string}> = [];
  export let isOpen: boolean = false;
  export let buttonText: string = 'Check Price';
  export let disabled: boolean = false;

  function handleButtonClick() {
    if (disabled || vendors.length === 0) return;
    
    // Always show dropdown regardless of vendor count
    dispatch('toggle');
  }

  function handleVendorClick(vendor: {name: string, url: string}) {
    window.open(vendor.url, '_blank', 'noopener,noreferrer');
    dispatch('close');
  }
</script>

<div class="relative inline-block text-left cta-dropdown-container">
  <button 
    class="cta-btn inline-flex items-center gap-1.5 px-3 py-2 bg-cta border border-cta-dark text-dark leading-none text-sm font-semibold rounded-lg hover:bg-cta/90 focus:outline-none focus:ring-2 focus:ring-cta/50 transition-all duration-200 active:scale-[0.97] {disabled || vendors.length === 0 ? 'opacity-50 cursor-not-allowed' : ''} {isOpen ? 'is-opened' : ''}"
    on:click={handleButtonClick}
    {disabled}
  >
    <span>{buttonText}</span>
    {#if vendors.length > 0}
      <svg class="h-3 w-3 text-dark transition-transform duration-200 {isOpen ? 'rotate-180' : ''}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    {/if}
  </button>
  
  {#if isOpen && vendors.length > 0}
    <div class="absolute left-0 top-full z-30 mt-1 w-48 bg-white border border-gray-200 rounded-lg shadow-lg is-open">
      <div class="py-1">
        {#each vendors as vendor}
          <button
            class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 transition-colors duration-150 flex items-center gap-2"
            on:click={() => handleVendorClick(vendor)}
          >
            <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
            </svg>
            Check on {vendor.name}
          </button>
        {/each}
      </div>
    </div>
  {/if}
</div>

<style>
  .cta-dropdown-container {
    min-width: fit-content;
  }


.cta-btn{
    box-shadow: 0px 2px 0px #AF8A1D, inset 0px 3px 4px rgba(255, 255, 255, 0.25);
    transition: all 200ms ease;
}

.cta-btn.is-opened{
    box-shadow: 0px 0px 0px #AF8A1D, inset 0px 3px 4px rgba(255, 255, 255, 0.25);
}




</style> 