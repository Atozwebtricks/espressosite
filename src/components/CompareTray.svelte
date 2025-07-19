<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  export let selectedMachines: any[] = [];
  const dispatch = createEventDispatcher();

  function handleCompare() {
    if (selectedMachines.length !== 2) return;
    const ids = selectedMachines.map(m => m.id).join(',');
    window.location.href = `/compare?ids=${ids}`;
  }

  function handleRemove(machineId: string) {
    dispatch('remove', { machineId });
  }
</script>

{#if selectedMachines.length > 0}
<div class="fixed bottom-0 left-0 right-0 bg-white border-t-2 border-primary shadow-2xl z-50">
  <div class="container mx-auto px-3 sm:px-4 py-4 sm:py-6">
    <div class="flex flex-col gap-8">
      <!-- Header section -->
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2 sm:gap-3">
          <h3 class="text-base sm:text-lg font-semibold text-primary">Compare Selection</h3>
          <span class="bg-white border-2 border-primary text-primary text-xs font-semibold px-2 sm:px-3 py-1 sm:py-1.5 rounded-lg">
            {selectedMachines.length}/2
          </span>
        </div>
        
        <!-- Clear button - moved to header on mobile -->
        <button 
          on:click={() => dispatch('clear')}
          class="sm:hidden inline-flex items-center gap-1 px-3 py-2 bg-white border-2 border-primary text-primary text-xs font-semibold rounded-lg transition-all duration-200 hover:bg-primary/5 active:scale-[0.98]"
        >
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
          Clear
        </button>
      </div>
      
      <!-- Content section -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <!-- Selected machines -->
        <div class="flex-1">
          <div class="flex items-center gap-2 sm:gap-4 pb-2 sm:pb-0">
            {#each selectedMachines as machine, i}
              <div class="flex-shrink-0 flex items-center gap-2 sm:gap-3 bg-white/50 rounded-lg p-3 sm:p-4 border-2 border-primary hover:bg-white transition-all duration-200 relative min-w-[140px] sm:min-w-0">
                <button
                  on:click={() => handleRemove(machine.id)}
                  class="absolute -top-1.5 sm:-top-2 -right-1.5 sm:-right-2 w-5 h-5 sm:w-6 sm:h-6 bg-primary hover:bg-primary/80 text-white rounded-full flex items-center justify-center transition-colors duration-200 shadow-sm hover:shadow-md border-2 border-white"
                  aria-label="Remove {machine.model_name || machine.name}"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" class="w-2.5 h-2.5 sm:w-3 sm:h-3">
                    <path d="M18 6 6 18" stroke-width="2"></path>
                    <path d="m6 6 12 12" stroke-width="2"></path>
                  </svg>
                </button>
                <div class="min-w-0 flex-1">
                  <p class="text-xs sm:text-sm font-semibold text-primary truncate max-w-[100px] sm:max-w-[160px]">
                    {machine.model_name || machine.name}
                  </p>
                  <p class="text-xs text-gray-600 truncate max-w-[100px] sm:max-w-[160px] font-medium">
                    {machine.brand || 'Unknown Brand'}
                  </p>
                </div>
              </div>
            {/each}
            
            {#if selectedMachines.length < 2}
              <div class="flex-shrink-0 flex items-center justify-center h-[60px] sm:h-[68px] w-[140px] sm:w-[200px] rounded-lg border-2 border-dashed border-primary/60 bg-white/20">
                <div class="text-center">
                  <div class="w-6 h-6 sm:w-8 sm:h-8 mx-auto mb-1 rounded-full bg-primary/10 border-2 border-primary/30 flex items-center justify-center">
                    <span class="text-primary text-sm sm:text-lg font-bold">+</span>
                  </div>
                  <p class="text-xs text-primary font-medium">Select another</p>
                </div>
              </div>
            {/if}
          </div>
        </div>

        <!-- Actions - desktop only for clear button -->
        <div class="flex items-center gap-3 sm:flex-shrink-0">
          <button 
            on:click={() => dispatch('clear')}
            class="hidden sm:inline-flex items-center gap-2 px-4 py-2.5 bg-white border-2 border-primary text-primary text-sm font-semibold rounded-lg transition-all duration-200 hover:bg-primary/5 active:scale-[0.98]"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
            Clear All
          </button>
          
          <button 
            on:click={handleCompare}
            class="flex-1 sm:flex-initial inline-flex items-center justify-center gap-2 px-4 sm:px-6 py-3 sm:py-2.5 bg-primary hover:bg-primary/90 text-white text-sm font-semibold rounded-lg transition-all duration-200 shadow-sm hover:shadow-md active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none border-2 border-primary {selectedMachines.length === 2 ? 'animate-pulse-subtle' : ''}"
            disabled={selectedMachines.length !== 2}
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
            <span class="hidden xs:inline">Compare Machines</span>
            <span class="xs:hidden">Compare</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</div>
{/if}

<style>
  /* Ensure the tray doesn't interfere with page scrolling */
  :global(body.compare-tray-open) {
    padding-bottom: 120px; /* Reduced for mobile */
  }

  /* Adjust padding for larger screens */
  @media (min-width: 640px) {
    :global(body.compare-tray-open) {
      padding-bottom: 140px;
    }
  }

  /* Custom scrollbar for horizontal scroll on mobile */
  .overflow-x-auto {
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 transparent;
  }

  .overflow-x-auto::-webkit-scrollbar {
    height: 4px;
  }

  .overflow-x-auto::-webkit-scrollbar-track {
    background: transparent;
  }

  .overflow-x-auto::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 2px;
  }

  .overflow-x-auto::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
  }

  /* Subtle pulse animation for the compare button */
  .animate-pulse-subtle {
    animation: pulse-subtle 4s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }

  @keyframes pulse-subtle {
    0%, 100% {
      background-color: var(--color-primary);
      border-color: var(--color-primary);
    }
    50% {
      background-color: var(--color-orange-600);
      border-color: var(--color-orange-600);
    }
  }

  /* Extra small breakpoint for xs:hidden and xs:inline */
  @media (min-width: 475px) {
    .xs\:hidden {
      display: none;
    }
    .xs\:inline {
      display: inline;
    }
  }
</style> 