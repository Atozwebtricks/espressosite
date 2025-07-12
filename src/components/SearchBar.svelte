<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let machines: any[] = [];
  export let placeholder: string = 'Search by brand or model...';

  const dispatch = createEventDispatcher();

  let searchTerm = '';
  let showSuggestions = false;
  let suggestions: Array<{type: string, value: string, label: string}> = [];
  let searchInput: HTMLInputElement;
  let selectedIndex = -1;

  // Generate suggestions based on search term
  $: {
    if (searchTerm.length >= 2) {
      const term = searchTerm.toLowerCase();
      const brandSuggestions = [...new Set(machines
        .map(m => m.brand)
        .filter(brand => brand && brand.toLowerCase().includes(term))
      )].slice(0, 5).map(brand => ({
        type: 'brand',
        value: brand,
        label: `Brand: ${brand}`
      }));

      const modelSuggestions = [...new Set(machines
        .map(m => m.model_name || m.name)
        .filter(model => model && model.toLowerCase().includes(term))
      )].slice(0, 5).map(model => ({
        type: 'model',
        value: model,
        label: `Model: ${model}`
      }));

      suggestions = [...brandSuggestions, ...modelSuggestions].slice(0, 8);
      showSuggestions = suggestions.length > 0;
      selectedIndex = -1;
    } else {
      suggestions = [];
      showSuggestions = false;
      selectedIndex = -1;
    }
  }

  function handleInput() {
    dispatch('search', searchTerm);
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      selectedIndex = Math.min(selectedIndex + 1, suggestions.length - 1);
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      selectedIndex = Math.max(selectedIndex - 1, -1);
    } else if (event.key === 'Enter') {
      event.preventDefault();
      if (selectedIndex >= 0 && suggestions[selectedIndex]) {
        selectSuggestion(suggestions[selectedIndex]);
      } else {
        handleInput();
      }
    } else if (event.key === 'Escape') {
      showSuggestions = false;
      selectedIndex = -1;
      searchInput.blur();
    }
  }

  function selectSuggestion(suggestion: {type: string, value: string, label: string}) {
    searchTerm = suggestion.value;
    showSuggestions = false;
    selectedIndex = -1;
    dispatch('search', searchTerm);
  }

  function handleBlur() {
    // Delay hiding suggestions to allow for clicks
    setTimeout(() => {
      showSuggestions = false;
      selectedIndex = -1;
    }, 200);
  }

  function handleFocus() {
    if (searchTerm.length >= 2 && suggestions.length > 0) {
      showSuggestions = true;
    }
  }

  function clearSearch() {
    searchTerm = '';
    showSuggestions = false;
    selectedIndex = -1;
    dispatch('search', '');
    searchInput.focus();
  }
</script>

<div class="relative w-full max-w-md">
  <div class="relative">
    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
      <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
      </svg>
    </div>
    
    <input
      bind:this={searchInput}
      bind:value={searchTerm}
      on:input={handleInput}
      on:keydown={handleKeydown}
      on:blur={handleBlur}
      on:focus={handleFocus}
      type="text"
      class="block w-full pl-10 pr-10 py-2  rounded-md leading-5 border-2 border-gray-900 text-gray-700 bg-white/80 placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
      placeholder={placeholder}
      autocomplete="off"
    />
    
    {#if searchTerm}
      <button
        on:click={clearSearch}
        class="absolute inset-y-0 right-0 pr-3 flex items-center"
        type="button"
      >
        <svg class="h-4 w-4 text-gray-400 hover:text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    {/if}
  </div>

  {#if showSuggestions && suggestions.length > 0}
    <div class="absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base ring-1 ring-black ring-opacity-5 overflow-auto focus:outline-none sm:text-sm">
      {#each suggestions as suggestion, index}
        <button
          on:click={() => selectSuggestion(suggestion)}
          class="relative cursor-pointer select-none py-2 pl-3 pr-9 w-full text-left hover:bg-indigo-50 {index === selectedIndex ? 'bg-indigo-50 text-indigo-900' : 'text-gray-900'}"
          type="button"
        >
          <div class="flex items-center">
            <span class="block truncate {index === selectedIndex ? 'font-semibold' : 'font-normal'}">
              {suggestion.label}
            </span>
          </div>
          
          {#if suggestion.type === 'brand'}
            <span class="absolute inset-y-0 right-0 flex items-center pr-4">
              <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
              </svg>
            </span>
          {:else}
            <span class="absolute inset-y-0 right-0 flex items-center pr-4">
              <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>
              </svg>
            </span>
          {/if}
        </button>
      {/each}
    </div>
  {/if}
</div> 