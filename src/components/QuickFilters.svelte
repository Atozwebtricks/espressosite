<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Checkbox from './Checkbox.svelte';
  import Dropdown from './Dropdown.svelte';

  const dispatch = createEventDispatcher();

  export let machines: any[] = [];
  export let clearTrigger: number = 0;

  // Quick filter state
  let searchTerm = '';
  let selectedBrands: string[] = [];
  let selectedMachineTypes: string[] = [];
  let selectedBoilerTypes: string[] = [];
  let hasDualBoiler: boolean = false;
  let pidControlOnly: boolean = false;
  let builtInGrinderOnly: boolean = false;

  // Show/hide dropdowns
  let showBrandDropdown = false;
  let showMachineTypeDropdown = false;
  let showBoilerTypeDropdown = false;

  // Calculate unique values from machines
  $: brands = [...new Set(machines.map(m => m.brand))].filter(Boolean).sort();
  $: machineTypes = ['Semi-automatic', 'Automatic', 'Super-automatic', 'Manual'];
  $: boilerTypes = ['Single', 'Dual', 'HX'];

  // Calculate if any filters are active
  $: hasActiveFilters = searchTerm || selectedBrands.length > 0 || selectedMachineTypes.length > 0 || selectedBoilerTypes.length > 0 || hasDualBoiler || pidControlOnly || builtInGrinderOnly;

  // Clear filters when clearTrigger changes
  $: {
    if (clearTrigger > 0) {
      clearAllFilters();
    }
  }

  // Apply filters when any value changes
  $: {
    searchTerm;
    selectedBrands;
    selectedMachineTypes;
    selectedBoilerTypes;
    hasDualBoiler;
    pidControlOnly;
    builtInGrinderOnly;

    if (machines.length > 0) {
      applyFilters();
    }
  }

  function applyFilters() {
    const filters = {
      searchTerm: searchTerm.trim() || undefined,
      brands: selectedBrands.length > 0 ? selectedBrands : undefined,
      machineTypes: selectedMachineTypes.length > 0 ? selectedMachineTypes : undefined,
      boilerTypes: selectedBoilerTypes.length > 0 ? selectedBoilerTypes : undefined,
      hasDualBoiler: hasDualBoiler || undefined,
      pidControlOnly: pidControlOnly || undefined,
      builtInGrinderOnly: builtInGrinderOnly || undefined,
    };
    dispatch('filter', filters);
  }

  function handleBrandToggle(event: CustomEvent) {
    const { option } = event.detail;
    if (selectedBrands.includes(option)) {
      selectedBrands = selectedBrands.filter(b => b !== option);
    } else {
      selectedBrands = [...selectedBrands, option];
    }
  }

  function handleMachineTypeToggle(event: CustomEvent) {
    const { option } = event.detail;
    if (selectedMachineTypes.includes(option)) {
      selectedMachineTypes = selectedMachineTypes.filter(t => t !== option);
    } else {
      selectedMachineTypes = [...selectedMachineTypes, option];
    }
  }

  function handleBoilerTypeToggle(event: CustomEvent) {
    const { option } = event.detail;
    if (selectedBoilerTypes.includes(option)) {
      selectedBoilerTypes = selectedBoilerTypes.filter(t => t !== option);
    } else {
      selectedBoilerTypes = [...selectedBoilerTypes, option];
    }
  }



  function toggleHasDualBoiler() {
    hasDualBoiler = !hasDualBoiler;
  }

  function clearAllFilters() {
    searchTerm = '';
    selectedBrands = [];
    selectedMachineTypes = [];
    selectedBoilerTypes = [];
    hasDualBoiler = false;
    pidControlOnly = false;
    builtInGrinderOnly = false;
  }

  // Close dropdowns when clicking outside
  function handleClickOutside(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (!target.closest('.dropdown-container')) {
      showBrandDropdown = false;
      showMachineTypeDropdown = false;
      showBoilerTypeDropdown = false;
    }
  }
</script>

<svelte:window on:click={handleClickOutside} />

<div class="grid grid-cols-2 sm:flex items-center gap-3 flex-1 flex-wrap px-2 md:px-0 justify-center md:justify-start font-medium">
  <!-- Search -->
  <div class="relative w-full sm:w-auto">
    <svg class="absolute left-2.5 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
    </svg>
    <input 
      type="text"
      placeholder="Search machines..."
      class="w-full sm:w-48 pl-9 pr-3 py-2 font-medium rounded-md text-sm border-2 border-gray-900 text-gray-700 bg-white/80 placeholder:text-gray-700 transition-colors custom-search-input"
      bind:value={searchTerm}
    />
  </div>

  <!-- Brands Dropdown -->
  <Dropdown
    label="Brands"
    options={brands}
    selectedOptions={selectedBrands}
    isOpen={showBrandDropdown}
    width="w-56"
    on:toggle={handleBrandToggle}
    on:toggle-dropdown={() => showBrandDropdown = !showBrandDropdown}
  />

  <!-- Machine Types Dropdown -->
  <Dropdown
    label="Machine Type"
    options={machineTypes}
    selectedOptions={selectedMachineTypes}
    isOpen={showMachineTypeDropdown}
    width="w-44"
    on:toggle={handleMachineTypeToggle}
    on:toggle-dropdown={() => showMachineTypeDropdown = !showMachineTypeDropdown}
  />

  <!-- Boiler Type Dropdown -->
  <Dropdown
    label="Boiler Type"
    options={boilerTypes}
    selectedOptions={selectedBoilerTypes}
    isOpen={showBoilerTypeDropdown}
    width="w-36"
    on:toggle={handleBoilerTypeToggle}
    on:toggle-dropdown={() => showBoilerTypeDropdown = !showBoilerTypeDropdown}
  />

  <!-- Quick Toggles -->
  <div class="flex items-center gap-1 overflow-auto justify-start md:justify-start col-span-2 mt-4 sm:mt-0">
    <!-- Has Dual Boiler Checkbox -->
    <div class="flex items-center gap-1.5 flex-none sm:flex-auto">
      <Checkbox 
        label="Dual boiler (separate boiler for milk)"
        bind:checked={hasDualBoiler}
      />
    </div>

    <!-- PID Control Checkbox -->
    <div class="flex items-center gap-1.5 flex-none sm:flex-auto">
      <Checkbox 
        label="PID control"
        bind:checked={pidControlOnly}
      />
    </div>

    <!-- Built-in Grinder Checkbox -->
    <div class="flex items-center gap-1.5 flex-none sm:flex-auto">
      <Checkbox 
        label="Built-in grinder"
        bind:checked={builtInGrinderOnly}
      />
    </div>
  </div>


</div>

<style>
  .custom-search-input:focus {
    outline: none;
    border-color: var(--color-primary);
    box-shadow: 0 0 0 3px rgba(88, 0, 0, 0.2);
  }
</style> 