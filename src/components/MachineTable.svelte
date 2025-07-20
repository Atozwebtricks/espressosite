<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { normalizeVendors } from '../lib/vendorUtils';
  import { 
    // formatHeatupTime, 
    formatWarranty, 
    formatBuiltInGrinder, 
    formatWaterTank, 
    formatDimensions, 
    formatWeight, 
    formatPower, 
    formatPrice, 
    formatYesNo,
    formatMachineType,
    formatBoilerType,
    formatHeatingSystem,
    formatNumberOfBoilers,
    formatPortafilter,
    formatSteamWand,
    formatPreInfusion
  } from '../lib/formatters';
  import ImageLightbox from './ImageLightbox.svelte';
  import LazyImage from './LazyImage.svelte';
  import SortUp from './icons/SortUp.svelte';
  import SortDown from './icons/SortDown.svelte';
  import SortDefault from './icons/SortDefault.svelte';
  import StatusPill from './StatusPill.svelte';
  import CTADropdown from './CTADropdown.svelte';
  import ScrollButton from './ScrollButton.svelte';
  import Checkbox from './Checkbox.svelte';

  export let machines: any[];
  export let selectedIds: string[] = [];
  export let sortColumn: string | null = null;
  export let sortDirection: 'asc' | 'desc' = 'asc';

  const dispatch = createEventDispatcher();

  function handleSort(column: string) {
    dispatch('sort', { column });
  }

  function getAriaSort(column: string) {
    if (sortColumn !== column) return 'none';
    return sortDirection === 'asc' ? 'ascending' : 'descending';
  }

  function isBooleanLike(value: any): boolean {
    if (value === null || value === undefined) return false;
    
    const strValue = String(value).toLowerCase().trim();
    
    // Check direct boolean-like values
    const booleanValues = ['yes', 'no', 'true', 'false', '1', '0'];
    if (booleanValues.includes(strValue)) return true;
    
    // Also check what the formatted value would be
    const formattedValue = formatPreInfusion(value);
    const formattedStr = String(formattedValue || '').toLowerCase().trim();
    
    return formattedStr === 'yes' || formattedStr === 'no';
  }

  function getMachineTypeClass(machineType: string): string {
    switch (machineType?.toLowerCase()) {
      case 'semi-automatic':
        return 'bg-[#fff5d0] text-black border-[#e2c92b]';
      case 'automatic':
        return 'bg-blue-50 text-blue-800 border-blue-200';  
      case 'super-automatic':
        return 'bg-purple-50 text-black border-purple-200';
      default:
        return 'bg-gray-50 text-gray-800 border-gray-200';
    }
  }



  function handleSelect(machineId: string, checked: boolean) {
    dispatch('select', { machineId, checked });
  }

  // Lightbox functionality
  let lightboxOpen = false;
  let lightboxImage: any = null;

  // CTA Dropdown state
  let openDropdownId: string | null = null;

  // Scroll state
  let scrollContainer: HTMLElement;
  let canScrollLeft = false;
  let canScrollRight = false;
  let buttonsVisible = false;

  function getImageUrl(machine: any): string {
    if (machine.signedImageUrl) {
      return machine.signedImageUrl;
    }
    return '/placeholder-machine.svg';
  }

  function getImageAlt(machine: any): string {
    return machine.image_caption || `${machine.model_name || machine.name} espresso machine`;
  }

  function handleImageClick(machine: any) {
    lightboxImage = {
      src: getImageUrl(machine),
      alt: getImageAlt(machine),
      caption: machine.image_caption || '',
      source: machine.image_source || '',
      machineName: machine.model_name || machine.name || ''
    };
    lightboxOpen = true;
    document.body.classList.add('modal-open');
  }

  function handleImageError(event: Event, machine: any) {
    const img = event.target as HTMLImageElement;
    if (img.src !== '/placeholder-machine.svg') {
      img.src = '/placeholder-machine.svg';
    }
  }

  function closeLightbox() {
    lightboxOpen = false;
    document.body.classList.remove('modal-open');
  }

  function handleCTAToggle(machineId: string) {
    openDropdownId = openDropdownId === machineId ? null : machineId;
  }

  function handleCTAClose() {
    openDropdownId = null;
  }

  // Close dropdown when clicking outside
  function handleClickOutside(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (!target.closest('.cta-dropdown-container')) {
      openDropdownId = null;
    }
  }

  function handleScroll(event: CustomEvent) {
    const { direction } = event.detail;
    if (!scrollContainer) return;

    const scrollAmount = 200; // Pixels to scroll
    const currentScroll = scrollContainer.scrollLeft;
    
    if (direction === 'left') {
      scrollContainer.scrollTo({
        left: currentScroll - scrollAmount,
        behavior: 'smooth'
      });
    } else {
      scrollContainer.scrollTo({
        left: currentScroll + scrollAmount,
        behavior: 'smooth'
      });
    }
  }

  function checkScrollCapability() {
    if (!scrollContainer) return;
    
    const { scrollLeft, scrollWidth, clientWidth } = scrollContainer;
    canScrollLeft = scrollLeft > 0;
    canScrollRight = scrollLeft < scrollWidth - clientWidth - 1; // -1 for rounding
    
    // Check if buttons should be visible based on position
    checkButtonVisibility();
  }

  function checkButtonVisibility() {
    const tableContainer = document.querySelector('[data-machinelist-outer]');
    if (!tableContainer) {
      buttonsVisible = false;
      return;
    }

    const tableRect = tableContainer.getBoundingClientRect();
    const buttonHeight = 48; // Height of the scroll buttons
    const buttonVerticalPosition = window.innerHeight / 2; // Fixed position at 50% of viewport height
    const earlyHideMargin = -100; // Hide buttons 100px earlier when scrolling up

    // Check if the button position overlaps with the table container
    const isWithinTableBounds = 
      buttonVerticalPosition >= tableRect.top - buttonHeight / 2 - earlyHideMargin &&
      buttonVerticalPosition <= tableRect.bottom + buttonHeight / 2;

    buttonsVisible = isWithinTableBounds;
  }

  function onScrollContainerScroll() {
    checkScrollCapability();
  }

  function onWindowScroll() {
    checkButtonVisibility();
  }

  function handleImageLoaded(event: CustomEvent) {
    const { machineId, url } = event.detail;
    const machineIndex = machines.findIndex(m => m.id === machineId);
    if (machineIndex !== -1) {
      machines[machineIndex].signedImageUrl = url;
    }
  }

  // Check scroll capability when component mounts and when machines change
  $: if (scrollContainer && machines) {
    // Use setTimeout to ensure DOM is updated
    setTimeout(checkScrollCapability, 0);
  }
</script>

<svelte:window on:click={handleClickOutside} on:scroll={onWindowScroll} on:resize={checkButtonVisibility} />

<div class="relative">
  <!-- Left Scroll Button -->
  <ScrollButton 
    direction="left" 
    disabled={!canScrollLeft}
    visible={buttonsVisible}
    on:scroll={handleScroll}
  />
  
  <!-- Right Scroll Button -->
  <ScrollButton 
    direction="right" 
    disabled={!canScrollRight}
    visible={buttonsVisible}
    on:scroll={handleScroll}
  />

  <div 
    class="overflow-x-auto scrollbar-thin bg-white rounded-xl shadow-lg border border-gray-100"
    bind:this={scrollContainer}
    on:scroll={onScrollContainerScroll}
  >
  <table class="min-w-max w-full">
    <thead class="bg-gradient-to-r from-gray-50 to-gray-100 border-b border-gray-200">
      <tr>
        <th scope="col" class="table-header-select text-left">
          <span class="text-xs font-bold text-gray-800 uppercase tracking-wide">Select</span>
        </th>
        <th scope="col" class="table-header-cell text-left">
          <span class="text-xs font-bold text-gray-800 uppercase tracking-wide">Image</span>
        </th>
        
        <!-- Name (sortable) - Sticky -->
        <th scope="col" class="table-header-sticky text-left sticky-name-header" aria-sort={getAriaSort('name')}>
          <button
            class="group inline-flex items-center space-x-2 text-xs font-bold text-gray-800 uppercase tracking-wide hover:text-primary hover:bg-white/50 focus:outline-none focus:text-primary focus:bg-white/50 rounded-md transition-all duration-200 ease-in-out"
            on:click={() => handleSort('name')}
            aria-label="Sort by Name"
          >
            <span>Name</span>
            <span class="flex-shrink-0 transition-all duration-200 {sortColumn === 'name' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'name'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Brand (sortable) -->
        <th scope="col" class="table-header-cell text-left" aria-sort={getAriaSort('brand')}>
          <button
            class="group inline-flex items-center space-x-2 text-xs font-bold text-gray-800 uppercase tracking-wide hover:text-primary hover:bg-white/50 focus:outline-none focus:text-primary focus:bg-white/50 rounded-md transition-all duration-200 ease-in-out"
            on:click={() => handleSort('brand')}
            aria-label="Sort by Brand"
          >
            <span>Brand</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'brand' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'brand'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Type (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('type')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('type')}
            aria-label="Sort by Type"
          >
            <span>Type</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'type' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'type'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Current Price (non-sortable) -->
        <th scope="col" class="px-6 py-4 text-left">
          <span class="text-xs font-semibold text-gray-900 uppercase tracking-wider">Current Price</span>
        </th>
        
        <!-- Boiler Config (sortable) -->
        <th scope="col" class="px-6 py-4 text-left group-start" aria-sort={getAriaSort('boiler_config')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('boiler_config')}
            aria-label="Sort by Boiler Configuration"
          >
            <span>Boiler Config</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'boiler_config' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'boiler_config'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Heating System (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('heating_system')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('heating_system')}
            aria-label="Sort by Heating System"
          >
            <span>Heating System</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'heating_system' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'heating_system'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Heat-up Time (sortable) - HIDDEN -->
        <!-- <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('heat_up')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('heat_up')}
            aria-label="Sort by Heat-up Time"
          >
            <span>Heat-up</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'heat_up' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'heat_up'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th> -->
        
        <!-- PID (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('pid')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('pid')}
            aria-label="Sort by PID"
          >
            <span>PID temperature
              control</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'pid' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'pid'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Pre-infusion (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('pre_infusion')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('pre_infusion')}
            aria-label="Sort by Pre-infusion"
          >
            <span>Pre-infusion</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'pre_infusion' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'pre_infusion'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Grinder (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('grinder')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('grinder')}
            aria-label="Sort by Grinder"
          >
            <span>Grinder</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'grinder' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'grinder'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Portafilter (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('portafilter')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('portafilter')}
            aria-label="Sort by Portafilter"
          >
            <span>Portafilter</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'portafilter' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'portafilter'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Steam Wand (sortable) - HIDDEN FOR NOW -->
        <!-- <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('steam_wand')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('steam_wand')}
            aria-label="Sort by Steam Wand"
          >
            <span>Steam Wand</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'steam_wand' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'steam_wand'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th> -->
        
        <!-- Water Tank (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('tank')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('tank')}
            aria-label="Sort by Water Tank"
          >
            <span>Tank</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'tank' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'tank'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Water Filter (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('water_filter')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('water_filter')}
            aria-label="Sort by Water Filter"
          >
            <span>Water Filter</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'water_filter' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'water_filter'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Plumbable (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('plumbable')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('plumbable')}
            aria-label="Sort by Plumbable"
          >
            <span>Plumbable</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'plumbable' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'plumbable'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Dimensions (sortable) -->
        <th scope="col" class="px-6 py-4 text-left group-start" aria-sort={getAriaSort('dimensions')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('dimensions')}
            aria-label="Sort by Dimensions"
          >
            <span>Dimensions</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'dimensions' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'dimensions'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Weight (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('weight')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('weight')}
            aria-label="Sort by Weight"
          >
            <span>Weight</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'weight' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'weight'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Build Material (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('build_material')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('build_material')}
            aria-label="Sort by Build Material"
          >
            <span>Build Material</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'build_material' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'build_material'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Power (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('power')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('power')}
            aria-label="Sort by Power"
          >
            <span>Power</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'power' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'power'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
        
        <!-- Warranty (sortable) -->
        <th scope="col" class="px-6 py-4 text-left" aria-sort={getAriaSort('warranty')}>
          <button
            class="group inline-flex items-center space-x-1 text-xs font-semibold text-gray-900 uppercase tracking-wider hover:text-primary focus:outline-none focus:text-primary transition-colors duration-150"
            on:click={() => handleSort('warranty')}
            aria-label="Sort by Warranty"
          >
            <span>Warranty</span>
            <span class="ml-2 flex-shrink-0 transition-transform duration-200 {sortColumn === 'warranty' ? 'text-primary' : 'text-gray-400'}">
              {#if sortColumn === 'warranty'}
                {#if sortDirection === 'asc'}
                  <SortUp />
                {:else}
                  <SortDown />
                {/if}
              {:else}
                <SortDefault />
              {/if}
            </span>
          </button>
        </th>
      </tr>
    </thead>
    
    <tbody class="divide-y divide-gray-100 bg-white">
      {#each machines as machine}
        {@const normalizedVendors = normalizeVendors(machine.vendors)}
        <tr class="hover:bg-gradient-to-r hover:from-orange-50/30 hover:to-amber-50/30 transition-all duration-200 ease-in-out">
          <td class="table-cell-select img-select-cells">
            <Checkbox 
              checked={selectedIds.includes(machine.id)}
              disabled={!selectedIds.includes(machine.id) && selectedIds.length >= 2}
              value={machine.id}
              size="md"
              centered={true}
              on:change={(e) => handleSelect(machine.id, e.detail.checked)}
            />
          </td>
          <td class="table-cell-lg whitespace-nowrap img-select-cells">
            <button
              class="relative w-16 h-16 overflow-hidden rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-all duration-200 bg-white focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
              on:click={() => handleImageClick(machine)}
              aria-label={`View image of ${machine.model_name || machine.name}`}
            >
                             <LazyImage
              machineId={machine.id}
              imagePath={machine.image_path}
              signedImageUrl={machine.signedImageUrl}
              alt={getImageAlt(machine)}
              containerClass="w-full h-full"
              fillContainer={true}
              on:imageLoaded={handleImageLoaded}
            />
            </button>
          </td>
          <td class="table-cell-lg whitespace-nowrap sticky-name-cell">
            <a href={`/machines/${machine.id}`} class="text-xs sm:text-sm font-semibold text-primary hover:text-cta-dark hover:underline transition-all duration-150 block truncate max-w-xs">
              {machine.model_name || machine.name}
            </a>
          </td>
          <td class="table-cell-lg whitespace-nowrap">
            <div class="text-sm font-serif tracking-wide font-medium text-primary">{machine.brand}</div>
          </td>
          <td class="table-cell-lg whitespace-nowrap">
            <span class="px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full border {getMachineTypeClass(machine.machine_type)}">
              {formatMachineType(machine.machine_type)}
            </span>
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {#if normalizedVendors.length > 0}
              <CTADropdown
                vendors={normalizedVendors}
                buttonText="Check Price"
                isOpen={openDropdownId === machine.id}
                on:toggle={() => handleCTAToggle(machine.id)}
                on:close={handleCTAClose}
              />
            {:else}
              <span class="text-gray-400 text-xs">No vendors</span>
            {/if}
          </td>
          <td class="table-cell-lg whitespace-nowrap text-sm text-gray-600 font-medium group-start">
            {formatBoilerType(machine.boiler_configuration || machine.boiler_type || machine.boiler)}
          </td>
          <td class="table-cell-lg whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatHeatingSystem(machine.heating_system)}
          </td>
          <!-- Heat-up Time cell - HIDDEN -->
          <!-- <td class="table-cell-lg whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatHeatupTime(machine.heat_up_seconds)}
          </td> -->
          <td class="table-cell-lg whitespace-nowrap text-sm text-gray-600 font-medium">
            <StatusPill value={machine.has_pid || machine.pid} />
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {#if isBooleanLike(machine.pre_infusion)}
              <StatusPill value={machine.pre_infusion} />
            {:else}
            {formatPreInfusion(machine.pre_infusion)}
            {/if}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatBuiltInGrinder(machine.built_in_grinder)}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatPortafilter(machine.portafilter_mm)}
          </td>
          <!-- <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatSteamWand(machine.steam_wand_type)}
          </td> -->
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatWaterTank(machine.water_tank_l || (machine.reservoir_ml ? machine.reservoir_ml / 1000 : null))}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            <StatusPill value={machine.has_water_filter} />
          </td>
          <td class="table-cell-lg whitespace-nowrap text-sm text-gray-600 font-medium">
            <StatusPill value={machine.is_plumbable || machine.plumbable} />
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium group-start">
            {formatDimensions(machine.dimensions)}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatWeight(machine.weight_lbs)}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {machine.build_material || 'Unknown'}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatPower(machine.power_watts)}
          </td>
          <td class="table-cell-md whitespace-nowrap text-sm text-gray-600 font-medium">
            {formatWarranty(machine.warranty_years || machine.warranty)}
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
  </div>
</div>

{#if lightboxOpen}
<ImageLightbox 
    isOpen={lightboxOpen}
  imageSrc={lightboxImage.src}
  imageAlt={lightboxImage.alt}
  imageCaption={lightboxImage.caption}
  imageSource={lightboxImage.source}
  machineName={lightboxImage.machineName}
  on:close={closeLightbox}
/> 
{/if}

<style>
  /* Custom styles for sortable headers */
  th button:hover svg {
    color: #374151;
  }
  
  th button:focus svg {
    color: #374151;
  }
  
  /* Active sort column styling */
  th[aria-sort="ascending"] button,
  th[aria-sort="descending"] button {
    color: #1f2937;
    font-weight: 600;
  }
  
  th[aria-sort="ascending"] svg,
  th[aria-sort="descending"] svg {
    color: #580000;
  }

  .group-start {
    border-left: 2px solid #e5e7eb;
  }

  /* Custom thin scrollbar styling */
  .scrollbar-thin {
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 #f1f5f9;
  }


  .scrollbar-thin::-webkit-scrollbar {
    height: 8px;
  }

  .scrollbar-thin::-webkit-scrollbar-track {
    background: #f1f5f9;
    border-radius: 4px;
  }

  .scrollbar-thin::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 4px;
    border: 1px solid #f1f5f9;
  }

  .scrollbar-thin::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
  }

  .scrollbar-thin::-webkit-scrollbar-thumb:active {
    background: #64748b;
  }

  /* Hide scrollbar corner */
  .scrollbar-thin::-webkit-scrollbar-corner {
    background: #f1f5f9;
  }

  /* Table cell padding classes */
  .table-cell-select {
    padding-left: 0.25rem;  /* px-1 */
    padding-right: 0.25rem; /* px-1 */
    padding-top: 0.5rem;    /* py-2 */
    padding-bottom: 0.5rem; /* py-2 */
    text-align: center;
  }
  
  .table-cell-lg {
    padding-left: 1.5rem;  /* px-6 */
    padding-right: 1.5rem; /* px-6 */
    padding-top: 0.5rem;  /* py-2 */
    padding-bottom: 0.5rem; /* py-2 */
    text-align: center;
  }

  @media(max-width:480px){
    .table-cell-lg {
    padding-left: 0px;  /* px-6 */
    padding-right: 0px; /* px-6 */
    padding-top: 0.5rem;  /* py-2 */
    padding-bottom: 0.5rem; /* py-2 */
    text-align: center;
  }
  }
  
  .table-cell-md {
    padding-left: 1.5rem;  /* px-6 */
    padding-right: 1.5rem; /* px-6 */
    padding-top: 0.5rem;     /* py-2 */
    padding-bottom: 0.5rem;  /* py-2 */
  }
  
  /* Header padding class */
  .table-header-select {
    padding-left: 0.5rem;  /* px-1 */
    padding-right: 0.5rem; /* px-1 */
    padding-top: 1.25rem;   /* py-5 */
    padding-bottom: 1.25rem; /* py-5 */
  }
  
  .table-header-cell {
    padding-left: 1.5rem;  /* px-6 */
    padding-right: 1.5rem; /* px-6 */
    padding-top: 1.25rem;  /* py-5 */
    padding-bottom: 1.25rem; /* py-5 */
  }
  
  /* Sticky header with different padding */
  .table-header-sticky {
    padding-left: 0.5rem;  /* px-2 */
    padding-right: 0.5rem; /* px-2 */
    padding-top: 1rem;     /* py-4 */
    padding-bottom: 1rem;  /* py-4 */
  }

  /* Custom checkbox styling */
  input[type="checkbox"]:checked {
    background-color: #580000 !important;
    border-color: #580000 !important;
    background-image: url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='white' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='m13.854 3.646-7.5 7.5a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6 10.293l7.146-7.147a.5.5 0 0 1 .708.708z'/%3e%3c/svg%3e");
  }
  
  input[type="checkbox"]:focus:checked {
    background-color: #580000 !important;
    border-color: #580000 !important;
  }
  
  input[type="checkbox"]:focus {
    outline: none !important;
    box-shadow: none !important;
  }

  /* Sticky Name column styling */
  .sticky-name-header {
    position: sticky;
    left: 0;
    z-index: 10;
    background: #f8f9fa;
    border-right: 1px solid #e5e7eb;
    box-shadow: inset -2.5px 0px 0px -1px rgb(0 0 0 / 5%);
    min-width: 200px;
  }

  .sticky-name-cell {
    position: sticky;
    left: 0;
    z-index: 10;
    background: #ffffff;
    border-right: 1px solid #e5e7eb;
    box-shadow: inset -2.5px 0px 0px -1px rgb(0 0 0 / 5%);
    min-width: 200px;
    text-align: left;
  }


@media(max-width:520px){
  .sticky-name-cell {
    max-width: 150px;
    padding-left: 0.75rem;
    padding-right: 0.5rem;
  }

}


  /* Hover effect for sticky name cell - higher z-index to stay above row background */
  tr:hover .sticky-name-cell {
    background: white;
    z-index: 11;
  }
  tr:hover .img-select-cells {
    background: white;
    z-index: 22;
  }
</style> 