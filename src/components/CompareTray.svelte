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
<div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-2xl z-50">
  <div class="container mx-auto px-4 py-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <!-- Left side - Selected machines -->
      <div class="flex-1">
        <div class="flex items-center gap-3 mb-6">
          <div class="flex items-center gap-2">
            
            <h3 class="text-lg font-semibold text-gray-900">Compare Selection</h3>
          </div>
          <span class="bg-[#fff5d0] border border-[#e5cd43] text-primary text-xs font-medium px-2 py-1 rounded-full">
            {selectedMachines.length}/2
          </span>
        </div>
        
        
        <div class="flex items-center gap-4">
          {#each selectedMachines as machine, i}
            <div class="flex items-center gap-3 bg-gray-50 rounded-xl p-4 border border-gray-200 hover:border-primary/30 transition-all duration-200 relative">
              <button
                on:click={() => handleRemove(machine.id)}
                class="absolute -top-2 -right-2 w-6 h-6 bg-red-500 hover:bg-red-600 text-white rounded-full flex items-center justify-center transition-colors duration-200 shadow-sm hover:shadow-md"
                aria-label="Remove {machine.model_name || machine.name}"
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" class="w-3 h-3">
                  <path d="M18 6 6 18" stroke-width="2"></path>
                  <path d="m6 6 12 12" stroke-width="2"></path>
                </svg>
              </button>
              <div class="min-w-0">
                <p class="text-sm font-medium text-gray-900 truncate max-w-[160px]">
                  {machine.model_name || machine.name}
                </p>
                <p class="text-xs text-gray-500 truncate max-w-[160px]">
                  {machine.brand || 'Unknown Brand'}
                </p>
              </div>
            </div>
          {/each}
          
          {#if selectedMachines.length < 2}
            <div class="flex items-center justify-center h-[68px] w-[200px] rounded-xl border-2 border-dashed border-gray-300 bg-gray-50/50">
              <div class="text-center">
                <div class="w-8 h-8 mx-auto mb-1 rounded-full bg-gray-200 flex items-center justify-center">
                  <span class="text-gray-400 text-lg font-light">+</span>
                </div>
                <p class="text-xs text-gray-500">Select another</p>
              </div>
            </div>
          {/if}
        </div>
      </div>

      <!-- Right side - Actions -->
      <div class="flex items-center gap-3 sm:flex-shrink-0">
        <button 
          on:click={() => dispatch('clear')}
          class="inline-flex items-center gap-2 px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm font-medium rounded-lg transition-all duration-200 hover:shadow-sm active:scale-[0.98]"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
          Clear All
        </button>
        
        <button 
          on:click={handleCompare}
          class="inline-flex items-center gap-2 px-6 py-2.5 bg-primary hover:bg-primary-dark text-white text-sm font-semibold rounded-lg transition-all duration-200 shadow-sm hover:shadow-md active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none {selectedMachines.length === 2 ? 'animate-pulse-subtle' : ''}"
          disabled={selectedMachines.length !== 2}
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
          </svg>
          Compare Machines
        </button>
      </div>
    </div>
  </div>
</div>
{/if}

<style>
  /* Ensure the tray doesn't interfere with page scrolling */
  :global(body.compare-tray-open) {
    padding-bottom: 140px;
  }

  /* Subtle pulse animation for the compare button */
  .animate-pulse-subtle {
    animation: pulse-subtle 4s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  }

  @keyframes pulse-subtle {
    0%, 100% {
      background-color: var(--color-primary);
    }
    50% {
      background-color: var(--color-orange-600);
    }
  }
</style> 