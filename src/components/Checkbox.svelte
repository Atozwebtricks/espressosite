<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  export let checked: boolean = false;
  export let label: string = '';
  export let value: string = '';
  export let disabled: boolean = false;
  export let size: 'sm' | 'md' = 'md';
  export let id: string = '';
  export let centered: boolean = false;

  function handleChange(event: Event) {
    const target = event.target as HTMLInputElement;
    checked = target.checked;
    dispatch('change', { checked, value, label });
  }

  // Generate unique ID if not provided
  $: checkboxId = id || `checkbox-${Math.random().toString(36).substr(2, 9)}`;
</script>

<label 
  for={checkboxId}
  class="group flex items-center {centered ? 'justify-center' : ''} cursor-pointer {disabled ? 'opacity-50 cursor-not-allowed' : ''} rounded transition-colors {size === 'sm' ? 'px-2 py-1.5' : 'px-2 py-2'}"
>
  <input 
    id={checkboxId}
    type="checkbox"
    class="border-primary/80 border-2 group-hover:border-primary/70 rounded custom-checkbox {size === 'sm' ? 'h-4 w-4' : 'h-5 w-5'} text-primary focus:ring-primary focus:ring-offset-0 focus:ring-0"
    bind:checked
    {disabled}
    {value}
    on:change={handleChange}
  />
  {#if label}
    <span class="ml-2 text-gray-800 select-none {size === 'sm' ? 'text-sm' : 'text-base'} group-hover:text-black transition-colors">{label}</span>
  {/if}
  <slot />
</label>

<style>
  .custom-checkbox {
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    transition: background-color 0.15s ease-in-out, border-color 0.15s ease-in-out;
  }
  
  .custom-checkbox:checked {
    background-color: var(--color-primary);
    border-color: var(--color-primary);
    background-image: url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='white' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M15.5119 2.7278c.4374.4374.4374 1.1479 0 1.5853l-8.959 8.959c-.4374.4374-1.1479.4374-1.5853 0l-4.4795-4.4795c-.4375-.4374-.4375-1.1479 0-1.5853s1.1479-.4374 1.5853 0L5.762 10.8924 13.9301 2.7278c.4374-.4374 1.1479-.4374 1.5853 0Z'/%3e%3c/svg%3e");
    background-size: 80% 80%;
    background-position: center;
    background-repeat: no-repeat;
  }
</style> 