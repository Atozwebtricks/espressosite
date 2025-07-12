<script lang="ts">
  import QuickFilters from './QuickFilters.svelte';
  import AdvancedFilters from './AdvancedFilters.svelte';
  import MachineTable from './MachineTable.svelte';
  import CompareTray from './CompareTray.svelte';
  import Pagination from './Pagination.svelte';
  import { fetchMachineImages } from '../lib/supabase';
  import { onMount } from 'svelte';

  export let allMachines: any[] = [];

  let filteredMachines = allMachines;
  let selectedMachines: any[] = [];
  
  // Pagination state
  let currentPage = 1;
  let itemsPerPage = 20;
  const itemsPerPageOptions = [5, 10, 20, 50, 100];

  // Filter state
  let quickFilters: any = {};
  let advancedFilters: any = {};
  let showAdvancedFilters = false;

  // Clear trigger for child components
  let clearTrigger = 0;

  // Sorting state - moved from MachineTable.svelte
  let sortColumn: string | null = null;
  let sortDirection: 'asc' | 'desc' = 'asc';

  // Image loading state
  let loadedImages = new Set<string>();
  let loadingImages = new Set<string>();

  // URL parameter sync state
  let isInitialized = false;

  // Sortable columns configuration - moved from MachineTable.svelte
  const sortableColumns = [
    { key: 'name', field: 'model_name', type: 'string', label: 'Name' },
    { key: 'brand', field: 'brand', type: 'string', label: 'Brand' },
    { key: 'type', field: 'machine_type', type: 'string', label: 'Type' },
    { key: 'boiler_config', field: 'boiler_configuration', type: 'string', label: 'Boiler Config' },
    { key: 'heating_system', field: 'heating_system', type: 'string', label: 'Heating System' },
    { key: 'heat_up', field: 'heat_up_seconds', type: 'number', label: 'Heat-up' },
    { key: 'pid', field: 'has_pid', type: 'boolean', label: 'PID' },
    { key: 'pre_infusion', field: 'pre_infusion', type: 'string', label: 'Pre-infusion' },
    { key: 'grinder', field: 'built_in_grinder', type: 'string', label: 'Grinder' },
    { key: 'portafilter', field: 'portafilter_mm', type: 'number', label: 'Portafilter' },
    { key: 'steam_wand', field: 'steam_wand_type', type: 'string', label: 'Steam Wand' },
    { key: 'tank', field: 'water_tank_l', type: 'number', label: 'Tank' },
    { key: 'water_filter', field: 'has_water_filter', type: 'boolean', label: 'Water Filter' },
    { key: 'plumbable', field: 'is_plumbable', type: 'boolean', label: 'Plumbable' },
    { key: 'dimensions', field: 'dimensions', type: 'string', label: 'Dimensions' },
    { key: 'weight', field: 'weight_lbs', type: 'number', label: 'Weight' },
    { key: 'build_material', field: 'build_material', type: 'string', label: 'Build Material' },
    { key: 'power', field: 'power_watts', type: 'number', label: 'Power' },
    { key: 'warranty', field: 'warranty_years', type: 'number', label: 'Warranty' }
  ];

  // URL parameter synchronization functions
  function parseFiltersFromURL(): { quickFilters: any; advancedFilters: any; sortColumn: string | null; sortDirection: 'asc' | 'desc'; currentPage: number; itemsPerPage: number } {
    if (typeof window === 'undefined') return { quickFilters: {}, advancedFilters: {}, sortColumn: null, sortDirection: 'asc', currentPage: 1, itemsPerPage: 20 };
    
    const params = new URLSearchParams(window.location.search);
    
    const quickFilters: any = {};
    const advancedFilters: any = {};
    
    // Parse search term
    if (params.has('search')) {
      quickFilters.searchTerm = params.get('search');
    }
    
    // Parse array filters
    if (params.has('brands')) {
      quickFilters.brands = params.get('brands')?.split(',').filter(Boolean) || [];
    }
    if (params.has('types')) {
      quickFilters.machineTypes = params.get('types')?.split(',').filter(Boolean) || [];
    }
    if (params.has('boilers')) {
      quickFilters.boilerTypes = params.get('boilers')?.split(',').filter(Boolean) || [];
    }
    if (params.has('boilerConfigs')) {
      advancedFilters.boilerConfigurations = params.get('boilerConfigs')?.split(',').filter(Boolean) || [];
    }
    if (params.has('heatingSystems')) {
      advancedFilters.heatingSystems = params.get('heatingSystems')?.split(',').filter(Boolean) || [];
    }
    if (params.has('preInfusion')) {
      advancedFilters.preInfusion = params.get('preInfusion')?.split(',').filter(Boolean) || [];
    }
    if (params.has('waterFilter')) {
      advancedFilters.waterFilter = params.get('waterFilter')?.split(',').filter(Boolean) || [];
    }
    if (params.has('buildMaterials')) {
      advancedFilters.buildMaterials = params.get('buildMaterials')?.split(',').filter(Boolean) || [];
    }
    if (params.has('warrantyYears')) {
      advancedFilters.warrantyYears = params.get('warrantyYears')?.split(',').map(Number).filter(n => !isNaN(n)) || [];
    }
    
    // Parse boolean filters
    if (params.has('dualBoiler')) {
      quickFilters.hasDualBoiler = params.get('dualBoiler') === 'true';
    }
    if (params.has('pid')) {
      quickFilters.pidControlOnly = params.get('pid') === 'true';
    }
    if (params.has('grinder')) {
      quickFilters.builtInGrinderOnly = params.get('grinder') === 'true';
    }
    
    // Parse numeric filters
    if (params.has('maxHeatUp')) {
      advancedFilters.maxHeatUpTime = Number(params.get('maxHeatUp'));
    }
    if (params.has('minTank')) {
      advancedFilters.minWaterTank = Number(params.get('minTank'));
    }
    
    // Parse sorting
    const sortCol = params.get('sort');
    const sortDir = params.get('dir') as 'asc' | 'desc';
    
    // Parse pagination
    const page = Number(params.get('page')) || 1;
    const perPage = Number(params.get('perPage')) || 20;
    
    return {
      quickFilters,
      advancedFilters,
      sortColumn: sortCol,
      sortDirection: sortDir || 'asc',
      currentPage: page,
      itemsPerPage: perPage
    };
  }

  function updateURL(filters: any, sort: { column: string | null; direction: 'asc' | 'desc' }, pagination: { page: number; perPage: number }) {
    if (typeof window === 'undefined' || !isInitialized) return;
    
    const params = new URLSearchParams();
    
    // Add search term
    if (filters.searchTerm) {
      params.set('search', filters.searchTerm);
    }
    
    // Add array filters
    if (filters.brands?.length > 0) {
      params.set('brands', filters.brands.join(','));
    }
    if (filters.machineTypes?.length > 0) {
      params.set('types', filters.machineTypes.join(','));
    }
    if (filters.boilerTypes?.length > 0) {
      params.set('boilers', filters.boilerTypes.join(','));
    }
    if (filters.boilerConfigurations?.length > 0) {
      params.set('boilerConfigs', filters.boilerConfigurations.join(','));
    }
    if (filters.heatingSystems?.length > 0) {
      params.set('heatingSystems', filters.heatingSystems.join(','));
    }
    if (filters.preInfusion?.length > 0) {
      params.set('preInfusion', filters.preInfusion.join(','));
    }
    if (filters.waterFilter?.length > 0) {
      params.set('waterFilter', filters.waterFilter.join(','));
    }
    if (filters.buildMaterials?.length > 0) {
      params.set('buildMaterials', filters.buildMaterials.join(','));
    }
    if (filters.warrantyYears?.length > 0) {
      params.set('warrantyYears', filters.warrantyYears.join(','));
    }
    
    // Add boolean filters
    if (filters.hasDualBoiler) {
      params.set('dualBoiler', 'true');
    }
    if (filters.pidControlOnly) {
      params.set('pid', 'true');
    }
    if (filters.builtInGrinderOnly) {
      params.set('grinder', 'true');
    }
    
    // Add numeric filters
    if (filters.maxHeatUpTime !== undefined) {
      params.set('maxHeatUp', filters.maxHeatUpTime.toString());
    }
    if (filters.minWaterTank !== undefined) {
      params.set('minTank', filters.minWaterTank.toString());
    }
    
    // Add sorting
    if (sort.column) {
      params.set('sort', sort.column);
      params.set('dir', sort.direction);
    }
    
    // Add pagination (only if not defaults)
    if (pagination.page > 1) {
      params.set('page', pagination.page.toString());
    }
    if (pagination.perPage !== 20) {
      params.set('perPage', pagination.perPage.toString());
    }
    
    const newURL = params.toString() ? `${window.location.pathname}?${params.toString()}` : window.location.pathname;
    window.history.replaceState({}, '', newURL);
  }

  // Track which machines already have images loaded (from initial load)
  $: initiallyLoadedMachineIds = allMachines
    .filter(machine => machine.signedImageUrl)
    .map(machine => machine.id);

  // Initialize loaded images set
  $: {
    if (initiallyLoadedMachineIds.length > 0) {
      loadedImages = new Set(initiallyLoadedMachineIds);
    }
  }

  // Sorted and paginated results
  $: sortedMachines = sortMachines(filteredMachines, sortColumn, sortDirection);
  $: paginatedMachines = sortedMachines.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  // Load images for paginated machines that don't have them yet
  $: {
    if (paginatedMachines.length > 0) {
      loadImagesForVisibleMachines(paginatedMachines);
    }
  }

  async function loadImagesForVisibleMachines(machines: any[]) {
    const machinesNeedingImages = machines.filter(machine => 
      !machine.signedImageUrl && 
      !loadedImages.has(machine.id) && 
      !loadingImages.has(machine.id)
    );

    if (machinesNeedingImages.length === 0) return;

    const machineIds = machinesNeedingImages.map(machine => machine.id);
    
    // Mark as loading
    machineIds.forEach(id => loadingImages.add(id));
    loadingImages = new Set(loadingImages);

    try {
      console.log(`Loading images for ${machineIds.length} additional machines...`);
      const newImages = await fetchMachineImages(machineIds, 400);
      
      // Update machines with new image URLs
      allMachines = allMachines.map(machine => {
        if (newImages[machine.id]) {
          return {
            ...machine,
            signedImageUrl: newImages[machine.id].url,
            image_caption: newImages[machine.id].image_caption || machine.image_caption,
            image_source: newImages[machine.id].image_source || machine.image_source,
          };
        }
        return machine;
      });

      // Mark as loaded
      machineIds.forEach(id => {
        loadedImages.add(id);
        loadingImages.delete(id);
      });
      loadedImages = new Set(loadedImages);
      loadingImages = new Set(loadingImages);

    } catch (error) {
      console.error('Error loading additional images:', error);
      // Remove from loading set on error
      machineIds.forEach(id => loadingImages.delete(id));
      loadingImages = new Set(loadingImages);
    }
  }

  // Sorting functions - moved from MachineTable.svelte
  function sortMachines(machineList: any[], column: string | null, direction: 'asc' | 'desc') {
    if (!column) return machineList;

    const columnConfig = sortableColumns.find(col => col.key === column);
    if (!columnConfig) return machineList;

    return [...machineList].sort((a, b) => {
      let aValue = getNestedValue(a, columnConfig.field);
      let bValue = getNestedValue(b, columnConfig.field);

      // Handle special cases
      if (columnConfig.key === 'name') {
        aValue = a.model_name || a.name;
        bValue = b.model_name || b.name;
      } else if (columnConfig.key === 'boiler_config') {
        aValue = a.boiler_configuration || a.boiler_type || a.boiler;
        bValue = b.boiler_configuration || b.boiler_type || b.boiler;
      } else if (columnConfig.key === 'tank') {
        aValue = a.water_tank_l || (a.reservoir_ml ? a.reservoir_ml / 1000 : null);
        bValue = b.water_tank_l || (b.reservoir_ml ? b.reservoir_ml / 1000 : null);
      } else if (columnConfig.key === 'warranty') {
        aValue = a.warranty_years || a.warranty;
        bValue = b.warranty_years || b.warranty;
      } else if (columnConfig.key === 'pid') {
        aValue = a.has_pid || a.pid;
        bValue = b.has_pid || b.pid;
      } else if (columnConfig.key === 'plumbable') {
        aValue = a.is_plumbable || a.plumbable;
        bValue = b.is_plumbable || b.plumbable;
      }

      // Convert to appropriate types for comparison
      if (columnConfig.type === 'number') {
        aValue = parseFloat(aValue) || 0;
        bValue = parseFloat(bValue) || 0;
      } else if (columnConfig.type === 'boolean') {
        aValue = Boolean(aValue);
        bValue = Boolean(bValue);
      } else {
        aValue = String(aValue || '').toLowerCase();
        bValue = String(bValue || '').toLowerCase();
      }

      // Handle null/undefined values
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return direction === 'asc' ? 1 : -1;
      if (bValue == null) return direction === 'asc' ? -1 : 1;

      let comparison = 0;
      if (aValue < bValue) comparison = -1;
      else if (aValue > bValue) comparison = 1;

      return direction === 'asc' ? comparison : -comparison;
    });
  }

  function getNestedValue(obj: any, path: string) {
    return path.split('.').reduce((current, key) => current?.[key], obj);
  }

  function handleSort(column: string) {
    if (sortColumn === column) {
      // Cycle through asc, desc, then clear sort
      if (sortDirection === 'asc') {
        sortDirection = 'desc';
      } else {
        sortColumn = null;
        sortDirection = 'asc'; // Reset for next time
      }
    } else {
      // New column, start with ascending
      sortColumn = column;
      sortDirection = 'asc';
    }
    
    // Reset to first page when sorting changes
    currentPage = 1;
  }

  function handleQuickFilter(event: CustomEvent) {
    quickFilters = event.detail;
    applyAllFilters();
  }

  function handleAdvancedFilter(event: CustomEvent) {
    advancedFilters = event.detail;
    applyAllFilters();
  }

  function clearAllFilters() {
    quickFilters = {};
    advancedFilters = {};
    clearTrigger += 1; // Trigger clearing in child components
    applyAllFilters();
  }

  // Calculate if any filters are active
  $: hasActiveFilters = Object.keys(quickFilters).some(key => {
    const value = quickFilters[key];
    if (Array.isArray(value)) {
      return value.length > 0;
    }
    return value !== undefined && value !== null && value !== '';
  }) || Object.keys(advancedFilters).some(key => {
    const value = advancedFilters[key];
    if (Array.isArray(value)) {
      return value.length > 0;
    }
    return value !== undefined && value !== null && value !== '';
  });

  function applyAllFilters() {
    const combinedFilters = { ...quickFilters, ...advancedFilters };
    
    filteredMachines = allMachines.filter(machine => {
      // Search filter
      if (combinedFilters.searchTerm && combinedFilters.searchTerm.trim()) {
        const searchLower = combinedFilters.searchTerm.toLowerCase();
        const matchesSearch = 
          (machine.model_name && machine.model_name.toLowerCase().includes(searchLower)) ||
          (machine.name && machine.name.toLowerCase().includes(searchLower)) ||
          (machine.brand && machine.brand.toLowerCase().includes(searchLower));
        if (!matchesSearch) return false;
      }

      // Brand filter
      if (combinedFilters.brands && combinedFilters.brands.length > 0) {
        if (!combinedFilters.brands.includes(machine.brand)) return false;
      }

      // Machine type filter
      if (combinedFilters.machineTypes && combinedFilters.machineTypes.length > 0) {
        if (!combinedFilters.machineTypes.includes(machine.machine_type)) return false;
      }

      // Quick boiler type filter (simplified)
      if (combinedFilters.boilerTypes && combinedFilters.boilerTypes.length > 0) {
        const boilerConfig = machine.boiler_configuration || machine.boiler_type || machine.boiler;
        const matchesQuickFilter = combinedFilters.boilerTypes.some((type: string) => {
          if (type === 'Single' && (boilerConfig?.includes('Single') || boilerConfig?.includes('Thermoblock') || boilerConfig?.includes('Thermocoil'))) return true;
          if (type === 'Dual' && boilerConfig?.includes('Dual')) return true;
          if (type === 'HX' && (boilerConfig?.includes('Heat-exchange') || boilerConfig?.includes('HX'))) return true;
          return false;
        });
        if (!matchesQuickFilter) return false;
      }

      // Boiler configuration filter (advanced)
      if (combinedFilters.boilerConfigurations && combinedFilters.boilerConfigurations.length > 0) {
        const boilerConfig = machine.boiler_configuration || machine.boiler_type || machine.boiler;
        if (!combinedFilters.boilerConfigurations.some((config: string) => boilerConfig?.includes(config))) return false;
      }

      // Heating system filter (advanced)
      if (combinedFilters.heatingSystems && combinedFilters.heatingSystems.length > 0) {
        const heatingSystem = machine.heating_system;
        if (!heatingSystem || !combinedFilters.heatingSystems.some((system: string) => heatingSystem.includes(system))) return false;
      }

      // Has dual boiler filter (separate boiler for milk)
      if (combinedFilters.hasDualBoiler) {
        const boilerConfig = machine.boiler_configuration || machine.boiler_type || machine.boiler;
        const isDualBoiler = boilerConfig?.toLowerCase().includes('dual boiler') || false;
        if (!isDualBoiler) return false;
      }

      // PID Control Only filter
      if (combinedFilters.pidControlOnly) {
        const hasPid = machine.has_pid || machine.pid;
        if (!hasPid) return false;
      }

      // Built-in Grinder Only filter
      if (combinedFilters.builtInGrinderOnly) {
        const hasBuiltInGrinder = machine.built_in_grinder === 'built-in';
        if (!hasBuiltInGrinder) return false;
      }

      // Max heat-up time filter
      if (combinedFilters.maxHeatUpTime !== undefined) {
        const heatupTime = machine.heat_up_seconds;
        if (heatupTime && heatupTime > combinedFilters.maxHeatUpTime) return false;
      }

      // Pre-infusion filter
      if (combinedFilters.preInfusion && combinedFilters.preInfusion.length > 0) {
        const preInfusion = machine.pre_infusion || 'None';
        if (!combinedFilters.preInfusion.includes(preInfusion)) return false;
      }

      // Min water tank filter
      if (combinedFilters.minWaterTank !== undefined) {
        const tankSize = machine.water_tank_l || (machine.reservoir_ml ? machine.reservoir_ml / 1000 : 0);
        if (tankSize && tankSize < combinedFilters.minWaterTank) return false;
      }

      // Water filter
      if (combinedFilters.waterFilter && combinedFilters.waterFilter.length > 0) {
        const hasFilter = machine.has_water_filter;
        const matchesFilter = combinedFilters.waterFilter.some((filter: string) => {
          if (filter === 'Has Filter' && hasFilter) return true;
          if (filter === 'No Filter' && !hasFilter) return true;
          return false;
        });
        if (!matchesFilter) return false;
      }

      // Build materials filter
      if (combinedFilters.buildMaterials && combinedFilters.buildMaterials.length > 0) {
        if (!combinedFilters.buildMaterials.includes(machine.build_material)) return false;
      }

      // Warranty years filter
      if (combinedFilters.warrantyYears && combinedFilters.warrantyYears.length > 0) {
        const warranty = machine.warranty_years;
        if (!warranty || !combinedFilters.warrantyYears.includes(warranty)) return false;
      }

      return true;
    });

    // Reset to first page when filters change
    currentPage = 1;
  }

  function handleSelect(event: CustomEvent) {
    const { machineId, checked } = event.detail;
    const machine = allMachines.find(m => m.id === machineId);

    if (checked) {
      if (selectedMachines.length < 2) {
        selectedMachines = [...selectedMachines, machine];
      }
    } else {
      selectedMachines = selectedMachines.filter(m => m.id !== machineId);
    }
  }

  function handlePageChange(event: CustomEvent) {
    currentPage = event.detail.page;
    // Scroll to top of table when page changes
    document.querySelector('.machine-table-container')?.scrollIntoView({ 
      behavior: 'smooth', 
      block: 'start' 
    });
  }

  function handleItemsPerPageChange(event: Event) {
    const target = event.target as HTMLSelectElement;
    itemsPerPage = parseInt(target.value);
    currentPage = 1; // Reset to first page when changing items per page
  }

  $: selectedIds = selectedMachines.map(m => m.id);
  
  // Calculate active advanced filters count
  $: activeAdvancedFiltersCount = Object.values(advancedFilters).filter(value => {
    if (Array.isArray(value)) {
      return value.length > 0;
    }
    return value !== undefined && value !== null;
  }).length;

  $: totalPages = Math.ceil(sortedMachines.length / itemsPerPage);

  // Initialize filters from URL on mount
  onMount(() => {
    const urlState = parseFiltersFromURL();
    quickFilters = urlState.quickFilters;
    advancedFilters = urlState.advancedFilters;
    sortColumn = urlState.sortColumn;
    sortDirection = urlState.sortDirection;
    currentPage = urlState.currentPage;
    itemsPerPage = urlState.itemsPerPage;
    isInitialized = true;
    
    // Handle browser back/forward navigation
    const handlePopState = () => {
      const urlState = parseFiltersFromURL();
      quickFilters = urlState.quickFilters;
      advancedFilters = urlState.advancedFilters;
      sortColumn = urlState.sortColumn;
      sortDirection = urlState.sortDirection;
      currentPage = urlState.currentPage;
      itemsPerPage = urlState.itemsPerPage;
    };
    
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  });

  // Update URL when filters, sorting, or pagination changes
  $: if (isInitialized) {
    const combinedFilters = { ...quickFilters, ...advancedFilters };
    updateURL(
      combinedFilters,
      { column: sortColumn, direction: sortDirection },
      { page: currentPage, perPage: itemsPerPage }
    );
  }
</script>

<div>
  <!-- Filters Row -->
  <div class="mb-6 flex justify-between items-center gap-4">
    <!-- Quick Filters - Inline -->
    <QuickFilters machines={allMachines} {clearTrigger} on:filter={handleQuickFilter} />
    
    
  </div>

  <!-- Advanced Filters Side Drawer -->
  <AdvancedFilters machines={allMachines} bind:isOpen={showAdvancedFilters} on:advancedFilter={handleAdvancedFilter} />
  
  <div class="machine-table-container" data-machinelist-outer>
    <!-- Results count and pagination info -->
    <div class="flex flex-col-reverse sm:flex-row flex-wrap justify-between items-start sm:items-center px-2 md:px-0 gap-4 sm:gap-2 mb-6 sm:mb-4">
      <div class="flex items-center gap-3 text-sm text-gray-700">
        {#if sortedMachines.length > 0}
          <span>
            {#if totalPages > 1}
              Showing <span class="font-medium">{((currentPage - 1) * itemsPerPage) + 1}–{Math.min(currentPage * itemsPerPage, sortedMachines.length)}</span> of <span class="font-medium">{sortedMachines.length}</span> machines
            {:else}
              Showing all <span class="font-medium">{sortedMachines.length}</span> machine{sortedMachines.length === 1 ? '' : 's'}
            {/if}
            {#if filteredMachines.length !== allMachines.length}
              <span class="text-gray-500">(filtered)</span>
            {/if}
          </span>

          {#if allMachines.length > itemsPerPageOptions[0]}
            <span class="border-l border-gray-300 h-4 mx-1"></span>
            <div class="flex items-center gap-1.5">
              <label for="items-per-page" class="text-sm text-gray-600">Show:</label>
              <select 
                id="items-per-page"
                class="text-xs border border-gray-300 rounded px-1.5 py-0.5 bg-white text-gray-700 focus:outline-none focus:ring-1 focus:ring-primary focus:border-primary"
                bind:value={itemsPerPage}
                on:change={handleItemsPerPageChange}
              >
                {#each itemsPerPageOptions as option}
                  {#if allMachines.length >= option}
                    <option value={option}>{option}</option>
                  {/if}
                {/each}
                 {#if !itemsPerPageOptions.includes(allMachines.length) && allMachines.length > itemsPerPageOptions[itemsPerPageOptions.length - 1]}
                  <option value={allMachines.length}>All ({allMachines.length})</option>
                {/if}
              </select>
              <span class="text-sm text-gray-600">per page</span>
            </div>
          {/if}
        {:else}
          <span>No machines found.</span>
        {/if}
      </div>
      
      <!-- Filter Action Buttons -->
      <div class="flex items-center gap-2">
        {#if hasActiveFilters}
          <button
            class="px-3 py-2 text-sm font-semibold text-gray-600 hover:text-gray-800 border border-gray-300 rounded-md  hover:bg-gray-50 transition-all duration-200 shadow-sm"
            on:click={clearAllFilters}
          >
            Clear All
          </button>
        {/if}
        
        <!-- Advanced Filters Button -->
        <button
          class="inline-flex items-center gap-2 px-4 py-2.5 bg-primary text-white text-sm font-semibold rounded-lg hover:bg-primary-dark transition-all duration-200 shadow-sm hover:shadow-md active:scale-[0.98] flex-shrink-0"
          on:click={() => showAdvancedFilters = true}
        >
        <svg class="h-5 w-5" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M6 11.5C6 11.3674 6.05268 11.2402 6.14645 11.1464C6.24021 11.0527 6.36739 11 6.5 11H9.5C9.63261 11 9.75979 11.0527 9.85355 11.1464C9.94732 11.2402 10 11.3674 10 11.5C10 11.6326 9.94732 11.7598 9.85355 11.8536C9.75979 11.9473 9.63261 12 9.5 12H6.5C6.36739 12 6.24021 11.9473 6.14645 11.8536C6.05268 11.7598 6 11.6326 6 11.5ZM4 8.5C4 8.36739 4.05268 8.24021 4.14645 8.14645C4.24021 8.05268 4.36739 8 4.5 8H11.5C11.6326 8 11.7598 8.05268 11.8536 8.14645C11.9473 8.24021 12 8.36739 12 8.5C12 8.63261 11.9473 8.75979 11.8536 8.85355C11.7598 8.94732 11.6326 9 11.5 9H4.5C4.36739 9 4.24021 8.94732 4.14645 8.85355C4.05268 8.75979 4 8.63261 4 8.5ZM2 5.5C2 5.36739 2.05268 5.24021 2.14645 5.14645C2.24021 5.05268 2.36739 5 2.5 5H13.5C13.6326 5 13.7598 5.05268 13.8536 5.14645C13.9473 5.24021 14 5.36739 14 5.5C14 5.63261 13.9473 5.75979 13.8536 5.85355C13.7598 5.94732 13.6326 6 13.5 6H2.5C2.36739 6 2.24021 5.94732 2.14645 5.85355C2.05268 5.75979 2 5.63261 2 5.5Z" fill="currentColor"/>
          </svg>
          
          Advanced Filters
          {#if activeAdvancedFiltersCount > 0}
            <span class="bg-cta text-dark text-xs rounded-full px-2 py-0.5 font-medium">
              {activeAdvancedFiltersCount}
            </span>
          {/if}
        </button>
      </div>
    </div>
    
    <MachineTable 
      machines={paginatedMachines} 
      selectedIds={selectedIds} 
      {sortColumn}
      {sortDirection}
      on:select={handleSelect}
      on:sort={(event) => handleSort(event.detail.column)}
    />
    
    <Pagination 
      {currentPage}
      totalItems={sortedMachines.length}
      {itemsPerPage}
      on:pageChange={handlePageChange}
    />
  </div>
  
  <CompareTray 
    selectedMachines={selectedMachines} 
    on:clear={() => selectedMachines = []}
    on:remove={(event) => {
      const { machineId } = event.detail;
      selectedMachines = selectedMachines.filter(m => m.id !== machineId);
    }}
  />
</div> 