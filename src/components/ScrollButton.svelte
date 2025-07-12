<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  export let direction: 'left' | 'right' = 'left';
  export let disabled: boolean = false;
  export let visible: boolean = true;

  function handleClick() {
    if (!disabled) {
      dispatch('scroll', { direction });
    }
  }
</script>

{#if visible}
  <button
    class="fixed top-1/2 transform -translate-y-1/2 z-50 flex items-center justify-center w-12 h-12 bg-white text-black border border-gray-300 rounded-full shadow-md hover:scale-100 hover:shadow-lg hover:bg-gray-50 transition-all duration-200 {disabled ? 'opacity-50 cursor-not-allowed' : 'hover:border-gray-400'} {direction === 'left' ? 'left-3' : 'right-3'}"
    on:click={handleClick}
    {disabled}
    aria-label={direction === 'left' ? 'Scroll left' : 'Scroll right'}
  >
    {#if direction === 'left'}
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
      </svg>
    {:else}
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
      </svg>
    {/if}
  </button>
{/if} 