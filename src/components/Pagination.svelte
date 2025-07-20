<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let currentPage = 1;
  export let totalItems = 0;
  export let itemsPerPage = 20;
  export let maxVisiblePages = 5;

  const dispatch = createEventDispatcher();

  $: totalPages = Math.ceil(totalItems / itemsPerPage);
  $: startItem = (currentPage - 1) * itemsPerPage + 1;
  $: endItem = Math.min(currentPage * itemsPerPage, totalItems);

  // Calculate visible page numbers
  $: {
    let start = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let end = Math.min(totalPages, start + maxVisiblePages - 1);
    
    // Adjust start if we're near the end
    if (end - start + 1 < maxVisiblePages) {
      start = Math.max(1, end - maxVisiblePages + 1);
    }
    
    visiblePages = Array.from({ length: end - start + 1 }, (_, i) => start + i);
  }

  let visiblePages: number[] = [];

  function goToPage(page: number) {
    if (page >= 1 && page <= totalPages && page !== currentPage) {
      dispatch('pageChange', { page });
    }
  }

  function previousPage() {
    goToPage(currentPage - 1);
  }

  function nextPage() {
    goToPage(currentPage + 1);
  }
</script>

{#if totalPages > 1}
  <div class="flex flex-col items-center gap-4 mt-6 py-8">
    <!-- Results info -->
    <div class="text-sm text-gray-700">
      Showing <span class="font-medium">{startItem}</span> to <span class="font-medium">{endItem}</span> of <span class="font-medium">{totalItems}</span> results
    </div>

    <!-- Pagination controls -->
    <nav class="flex items-center justify-center" aria-label="Pagination">
      <!-- Previous button -->
      <button
        on:click={previousPage}
        disabled={currentPage === 1}
        class="flex h-10 w-10 sm:w-auto sm:h-auto items-center cursor-pointer justify-center sm:px-4 sm:py-2 mx-1 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white transition-colors sm:min-w-[90px]"
        aria-label="Previous page"
      >
        <svg class="w-4 h-4 sm:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        <span class="hidden sm:block">Previous</span>
      </button>

      <!-- Page numbers -->
      <div class="flex items-center mx-2">
        {#if visiblePages[0] > 1}
          <button
            on:click={() => goToPage(1)}
            class="flex cursor-pointer items-center justify-center w-10 h-10 mx-1 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
          >
            1
          </button>
          {#if visiblePages[0] > 2}
            <span class="flex items-center justify-center w-10 h-10 mx-1 text-sm font-medium text-gray-500">
              ...
            </span>
          {/if}
        {/if}

        {#each visiblePages as page}
          <button
            on:click={() => goToPage(page)}
            class="flex cursor-pointer items-center justify-center w-10 h-10 mx-1 text-sm font-medium border border-gray-300 rounded-md transition-colors {page === currentPage 
              ? 'bg-primary text-white border-primary' 
              : 'text-gray-700 bg-white hover:bg-gray-50'}"
            aria-current={page === currentPage ? 'page' : undefined}
          >
            {page}
          </button>
        {/each}

        {#if visiblePages[visiblePages.length - 1] < totalPages}
          {#if visiblePages[visiblePages.length - 1] < totalPages - 1}
            <span class="flex items-center justify-center w-10 h-10 mx-1 text-sm font-medium text-gray-500">
              ...
            </span>
          {/if}
          <button
            on:click={() => goToPage(totalPages)}
            class="flex items-center justify-center w-10 h-10 mx-1 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
          >
            {totalPages}
          </button>
        {/if}
      </div>

      <!-- Next button -->
      <button
        on:click={nextPage}
        disabled={currentPage === totalPages}
        class="flex cursor-pointer items-center h-10 w-10 sm:w-auto sm:h-auto justify-center sm:px-4 sm:py-2 mx-1 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white transition-colors sm:min-w-[90px]"
        aria-label="Next page"
      >
        <span class="hidden sm:block">Next</span>
        <svg class="w-4 h-4 sm:ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </button>
    </nav>
  </div>
{/if} 