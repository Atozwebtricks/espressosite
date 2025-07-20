<script lang="ts">
  import { onMount } from 'svelte';
  import { normalizeVendors, formatPrice } from '../lib/vendorUtils';
  import { 
    // formatHeatupTime, 
    formatWarranty, 
    formatBuiltInGrinder, 
    formatWaterTank, 
    formatDimensions, 
    formatWeight, 
    formatPower, 
    formatPrice as formatPriceNum, 
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
  import StatusPill from './StatusPill.svelte';
  import LazyImage from './LazyImage.svelte';
  import CTADropdown from './CTADropdown.svelte';
  
  export let machines: any[];

  let machine1 = machines?.[0];
  let machine2 = machines?.[1];
  
  $: normalizedVendors1 = normalizeVendors(machine1?.vendors);
  $: normalizedVendors2 = normalizeVendors(machine2?.vendors);

  // Load images for both machines on mount
  onMount(async () => {
    if (machine1?.id && machine2?.id && typeof window !== 'undefined') {
      try {
        // Dynamically import store only in browser
        const { fetchMachineImages } = await import('../lib/machinesStore');
        const machineIds = [machine1.id, machine2.id];
        const images = await fetchMachineImages(machineIds);
        
        // Update machine1 with signed image URL
        if (images[machine1.id]) {
          machine1 = {
            ...machine1,
            signedImageUrl: images[machine1.id].url,
            image_caption: images[machine1.id].image_caption || machine1.image_caption,
            image_source: images[machine1.id].image_source || machine1.image_source
          };
        }
        
        // Update machine2 with signed image URL
        if (images[machine2.id]) {
          machine2 = {
            ...machine2,
            signedImageUrl: images[machine2.id].url,
            image_caption: images[machine2.id].image_caption || machine2.image_caption,
            image_source: images[machine2.id].image_source || machine2.image_source
          };
        }
      } catch (error) {
        console.error('Error loading images for comparison:', error);
      }
    }
  });

  // Mobile view toggle state
  let mobileViewMode: 'stacked' | 'side-by-side' = 'stacked';

  // CTA Dropdown state
  let openDropdownId: string | null = null;

  function handleCTAToggle(machineId: string) {
    openDropdownId = openDropdownId === machineId ? null : machineId;
  }

  function handleCTAClose() {
    openDropdownId = null;
  }

  // Lightbox state
  let lightboxOpen = false;
  let lightboxImage = {
    src: '',
    alt: '',
    caption: '',
    source: '',
    machineName: ''
  };

  // Function to get the best available image URL with fallbacks
  function getImageUrl(machine: any): string {
    return machine.signedImageUrl || '/placeholder-machine.svg';
  }

  // Function to get image alt text
  function getImageAlt(machine: any): string {
    return machine.image_caption || machine.model_name || machine.name || 'Espresso Machine';
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

  function isBooleanLike(value: any): boolean {
    if (value === null || value === undefined) return false;
    
    const strValue = String(value).toLowerCase().trim();
    const booleanValues = ['yes', 'no', 'true', 'false', '1', '0'];
    if (booleanValues.includes(strValue)) return true;
    
    const formattedValue = formatPreInfusion(value);
    const formattedStr = String(formattedValue || '').toLowerCase().trim();
    
    return formattedStr === 'yes' || formattedStr === 'no';
  }

  function formatValue(value: any, key: string): string {
    if (value === null || value === undefined || value === '') {
      return 'N/A';
    }
    
    switch (key) {
      case 'price_usd':
        return formatPriceNum(value);
      case 'machine_type':
        return formatMachineType(value);
      case 'boiler_configuration':
        return formatBoilerType(value);
      case 'heating_system':  
        return formatHeatingSystem(value);
      case 'number_of_boilers':
        return formatNumberOfBoilers(value);
          // case 'heat_up_seconds':
    //   return formatHeatupTime(value); // HIDDEN
      case 'has_pid':
        return formatYesNo(value);
      case 'pre_infusion':
        return formatPreInfusion(value);
      case 'built_in_grinder':
        return formatBuiltInGrinder(value);
      case 'portafilter_mm':
        return formatPortafilter(value);
      case 'steam_wand_type':
        return formatSteamWand(value);
      case 'is_plumbable':
        return formatYesNo(value);
      case 'water_tank_l':
        return formatWaterTank(value);
      case 'has_water_filter':
        return formatYesNo(value);
      case 'dimensions':
        return formatDimensions(value);
      case 'weight_lbs':
        return formatWeight(value);
      case 'power_watts':
        return formatPower(value);
      case 'warranty':
        return formatWarranty(value);
      default:
        if (typeof value === 'boolean') {
          return formatYesNo(value);
        }
        return value.toString();
    }
  }

  const specOrder = [
    { key: 'release_year', label: 'Release Year' },
    { key: 'machine_type', label: 'Machine Type', isSpecial: true },
    { key: 'boiler_configuration', label: 'Boiler Configuration' },
    { key: 'heating_system', label: 'Heating System' },
    { key: 'number_of_boilers', label: 'Number of Boilers' },
    // { key: 'heat_up_seconds', label: 'Heat-up Time' }, // HIDDEN
    { key: 'has_pid', label: 'PID Control', isBooleanLike: true },
    { key: 'pre_infusion', label: 'Pre-infusion', isBooleanLike: true },
    { key: 'built_in_grinder', label: 'Built-in Grinder' },
    { key: 'portafilter_mm', label: 'Portafilter Size' },
    // { key: 'steam_wand_type', label: 'Steam Wand' }, // HIDDEN FOR NOW
    { key: 'is_plumbable', label: 'Plumbable', isBooleanLike: true },
    { key: 'water_tank_l', label: 'Water Tank' },
    { key: 'has_water_filter', label: 'Water Filter Compatible', isBooleanLike: true },
    { key: 'dimensions', label: 'Dimensions' },
    { key: 'weight_lbs', label: 'Weight' },
    { key: 'power_watts', label: 'Power' },
    { key: 'build_material', label: 'Build Material' },
    { key: 'warranty', label: 'Warranty' },
  ];

  // Function to open lightbox with machine image
  function openLightbox(machine: any) {
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

  // Function to close lightbox
  function closeLightbox() {
    lightboxOpen = false;
    document.body.classList.remove('modal-open');
  }

  // Close dropdown when clicking outside
  function handleClickOutside(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (!target.closest('.cta-dropdown-container')) {
      openDropdownId = null;
    }
  }
</script>

<svelte:window on:click={handleClickOutside} />

{#if machine1 && machine2}
<div class="overflow-hidden">
  <!-- Header Section -->
  <div class="mb-8 lg:mb-16">
    <div class="text-center">
      <h1 class="text-2xl md:text-3xl lg:text-4xl text-gray-800 leading-tight">
        <span class="text-primary font-serif">{machine1.model_name || machine1.name}</span>
        <br class="hidden md:block">
        <span class="text-gray-800 mx-2 md:mx-4">vs</span>
        <br class="hidden md:block">
        <span class="text-primary font-serif">{machine2.model_name || machine2.name}</span>
      </h1>
    </div>
  </div>

  <!-- Mobile View Toggle -->
  <div class="block lg:hidden mb-6">
    <div class="flex items-center justify-center">
      <div class="inline-flex rounded-lg border border-gray-200 bg-gray-50 p-1">
        <button
          class="px-3 leading-none items-center py-1.5 flex justify-center text-sm font-medium rounded-md transition-colors duration-200 {mobileViewMode === 'stacked' ? 'bg-white font-medium text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700'}"
          on:click={() => mobileViewMode = 'stacked'}
        >
          <svg class="w-4 h-4 mr-1.5 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
          Stacked
        </button>
        <button
          class="px-3 leading-none items-center py-1.5 flex justify-center text-sm font-medium rounded-md transition-colors duration-200 {mobileViewMode === 'side-by-side' ? 'bg-white font-medium text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700'}"
          on:click={() => mobileViewMode = 'side-by-side'}
        >
          <svg class="w-4 h-4 mr-1.5 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2"></path>
          </svg>
          Side by Side
        </button>
      </div>
    </div>
  </div>

  <!-- Mobile Layout: Stacked Cards -->
  <div class="block lg:hidden {mobileViewMode === 'stacked' ? 'block' : 'hidden'} space-y-8">
    <!-- Machine 1 Card -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
      <div class="bg-gradient-to-r from-primary/10 to-primary/5 px-4 py-3 border-b border-gray-100">
        <h2 class="text-lg font-bold text-gray-800 text-center">
          {machine1.model_name || machine1.name}
        </h2>
      </div>
      
      <!-- Machine 1 Image -->
      <div class="p-4">
        <div class="cursor-pointer transition-opacity duration-200 group mb-4" on:click={() => openLightbox(machine1)}>
          <div class="aspect-square w-full max-w-xs mx-auto">
            <LazyImage
              machineId={machine1.id}
              imagePath={machine1.image_path}
              signedImageUrl={machine1.signedImageUrl}
              alt={getImageAlt(machine1)}
              containerClass="w-full h-full !rounded-xl shadow-md"
              imgClass="group-hover:scale-105 p-4 transition-transform duration-300"
            />
          </div>
        </div>
        
        <!-- Machine 1 CTA -->
        <div class="text-center mb-4">
          <CTADropdown
            vendors={normalizedVendors1}
            buttonText="Check Price"
            isOpen={openDropdownId === machine1.id}
            on:toggle={() => handleCTAToggle(machine1.id)}
            on:close={handleCTAClose}
          />
        </div>
        
        <!-- Machine 1 Specs -->
        <div class="space-y-3">
          {#each specOrder as spec}
            <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
              <span class="text-sm font-medium text-gray-600 flex-1">
                {spec.label}
              </span>
              <div class="flex-1 text-right">
                {#if spec.isSpecial && spec.key === 'machine_type'}
                  <span class="px-2 py-1 inline-flex text-xs leading-4 font-bold rounded-full border {getMachineTypeClass(machine1.machine_type)}">
                    {formatValue(machine1[spec.key], spec.key)}
                  </span>
                {:else if spec.isBooleanLike && isBooleanLike(machine1[spec.key])}
                  <StatusPill value={machine1[spec.key]} />
                {:else}
                  <span class="text-sm font-medium text-gray-800">
                    {formatValue(machine1[spec.key] || (spec.key === 'boiler_configuration' ? machine1.boiler_type || machine1.boiler : null), spec.key)}
                  </span>
                {/if}
              </div>
            </div>
          {/each}
        </div>
      </div>
    </div>

    <!-- Machine 2 Card -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
      <div class="bg-gradient-to-r from-primary/10 to-primary/5 px-4 py-3 border-b border-gray-100">
        <h2 class="text-lg font-bold text-gray-800 text-center">
          {machine2.model_name || machine2.name}
        </h2>
      </div>
      
      <!-- Machine 2 Image -->
      <div class="p-4">
        <div class="cursor-pointer transition-opacity duration-200 group mb-4" on:click={() => openLightbox(machine2)}>
          <div class="aspect-square w-full max-w-xs mx-auto">
            <LazyImage
              machineId={machine2.id}
              imagePath={machine2.image_path}
              signedImageUrl={machine2.signedImageUrl}
              alt={getImageAlt(machine2)}
              containerClass="w-full h-full !rounded-xl shadow-md"
              imgClass="group-hover:scale-105 p-4 transition-transform duration-300"
            />
          </div>
        </div>
        
        <!-- Machine 2 CTA -->
        <div class="text-center mb-4">
          <CTADropdown
            vendors={normalizedVendors2}
            buttonText="Check Price"
            isOpen={openDropdownId === machine2.id}
            on:toggle={() => handleCTAToggle(machine2.id)}
            on:close={handleCTAClose}
          />
        </div>
        
        <!-- Machine 2 Specs -->
        <div class="space-y-3">
          {#each specOrder as spec}
            <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
              <span class="text-sm font-medium text-gray-600 flex-1">
                {spec.label}
              </span>
              <div class="flex-1 text-right">
                {#if spec.isSpecial && spec.key === 'machine_type'}
                  <span class="px-2 py-1 inline-flex text-xs leading-4 font-bold rounded-full border {getMachineTypeClass(machine2.machine_type)}">
                    {formatValue(machine2[spec.key], spec.key)}
                  </span>
                {:else if spec.isBooleanLike && isBooleanLike(machine2[spec.key])}
                  <StatusPill value={machine2[spec.key]} />
                {:else}
                  <span class="text-sm font-medium text-gray-800">
                    {formatValue(machine2[spec.key] || (spec.key === 'boiler_configuration' ? machine2.boiler_type || machine2.boiler : null), spec.key)}
                  </span>
                {/if}
              </div>
            </div>
          {/each}
        </div>
      </div>
    </div>
  </div>

  <!-- Mobile Layout: Side-by-Side with Horizontal Scroll -->
  <div class="block lg:hidden {mobileViewMode === 'side-by-side' ? 'block' : 'hidden'}">
    <div class="overflow-x-auto pb-4 mobile-horizontal-scroll">
      <div class="flex space-x-4 min-w-max px-4">
        <!-- Machine 1 Card -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden w-80 flex-shrink-0">
          <div class="bg-gradient-to-r from-primary/10 to-primary/5 px-4 py-3 border-b border-gray-100">
            <h2 class="text-lg font-bold text-gray-800 text-center">
              {machine1.model_name || machine1.name}
            </h2>
          </div>
          
          <!-- Machine 1 Image -->
          <div class="p-4">
            <div class="cursor-pointer transition-opacity duration-200 group mb-4" on:click={() => openLightbox(machine1)}>
              <div class="aspect-square w-full">
                            <LazyImage
              machineId={machine1.id}
              imagePath={machine1.image_path}
              signedImageUrl={machine1.signedImageUrl}
              alt={getImageAlt(machine1)}
              containerClass="w-full h-full !rounded-xl shadow-md"
              imgClass="group-hover:scale-105 p-4 transition-transform duration-300"
            />
              </div>
            </div>
            
            <!-- Machine 1 CTA -->
            <div class="text-center mb-4">
              <CTADropdown
                vendors={normalizedVendors1}
                buttonText="Check Price"
                isOpen={openDropdownId === machine1.id}
                on:toggle={() => handleCTAToggle(machine1.id)}
                on:close={handleCTAClose}
              />
            </div>
            
            <!-- Machine 1 Specs -->
            <div class="space-y-3">
              {#each specOrder as spec}
                <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                  <span class="text-sm font-medium text-gray-600 flex-1 pr-2">
                    {spec.label}
                  </span>
                  <div class="flex-1 text-right">
                    {#if spec.isSpecial && spec.key === 'machine_type'}
                      <span class="px-2 py-1 inline-flex text-xs leading-4 font-bold rounded-full border {getMachineTypeClass(machine1.machine_type)}">
                        {formatValue(machine1[spec.key], spec.key)}
                      </span>
                    {:else if spec.isBooleanLike && isBooleanLike(machine1[spec.key])}
                      <StatusPill value={machine1[spec.key]} />
                    {:else}
                      <span class="text-sm font-medium text-gray-800">
                        {formatValue(machine1[spec.key] || (spec.key === 'boiler_configuration' ? machine1.boiler_type || machine1.boiler : null), spec.key)}
                      </span>
                    {/if}
                  </div>
                </div>
              {/each}
            </div>
          </div>
        </div>

        <!-- Machine 2 Card -->
        <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden w-80 flex-shrink-0">
          <div class="bg-gradient-to-r from-primary/10 to-primary/5 px-4 py-3 border-b border-gray-100">
            <h2 class="text-lg font-bold text-gray-800 text-center">
              {machine2.model_name || machine2.name}
            </h2>
          </div>
          
          <!-- Machine 2 Image -->
          <div class="p-4">
            <div class="cursor-pointer transition-opacity duration-200 group mb-4" on:click={() => openLightbox(machine2)}>
              <div class="aspect-square w-full">
                <LazyImage
                  machineId={machine2.id}
                  imagePath={machine2.image_path}
                  signedImageUrl={machine2.signedImageUrl}
                  alt={getImageAlt(machine2)}
                  containerClass="w-full h-full !rounded-xl shadow-md"
                  imgClass="group-hover:scale-105 p-4 transition-transform duration-300"
                />
              </div>
            </div>
            
            <!-- Machine 2 CTA -->
            <div class="text-center mb-4">
              <CTADropdown
                vendors={normalizedVendors2}
                buttonText="Check Price"
                isOpen={openDropdownId === machine2.id}
                on:toggle={() => handleCTAToggle(machine2.id)}
                on:close={handleCTAClose}
              />
            </div>
            
            <!-- Machine 2 Specs -->
            <div class="space-y-3">
              {#each specOrder as spec}
                <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                  <span class="text-sm font-medium text-gray-600 flex-1 pr-2">
                    {spec.label}
                  </span>
                  <div class="flex-1 text-right">
                    {#if spec.isSpecial && spec.key === 'machine_type'}
                      <span class="px-2 py-1 inline-flex text-xs leading-4 font-bold rounded-full border {getMachineTypeClass(machine2.machine_type)}">
                        {formatValue(machine2[spec.key], spec.key)}
                      </span>
                    {:else if spec.isBooleanLike && isBooleanLike(machine2[spec.key])}
                      <StatusPill value={machine2[spec.key]} />
                    {:else}
                      <span class="text-sm font-medium text-gray-800">
                        {formatValue(machine2[spec.key] || (spec.key === 'boiler_configuration' ? machine2.boiler_type || machine2.boiler : null), spec.key)}
                      </span>
                    {/if}
                  </div>
                </div>
              {/each}
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Scroll Indicator -->
    <div class="text-center mt-2">
      <p class="text-xs text-gray-500">
        <svg class="w-4 h-4 inline-block mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16l-4-4m0 0l4-4m-4 4h18"></path>
        </svg>
        Swipe to compare
        <svg class="w-4 h-4 inline-block ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3"></path>
        </svg>
      </p>
    </div>
  </div>

  <!-- Desktop Layout: Specifications Comparison Table -->
  <div class="hidden lg:block">
    <div class="overflow-x-auto rounded-xl border border-primary/20">
      <table class="min-w-full divide-y divide-primary/20">
        <thead class="bg-gradient-to-r from-primary/5 to-primary/10">
          <tr>
            <th scope="col" class="px-6 py-4 text-left text-xs font-bold text-gray-800 uppercase tracking-wide w-1/3">
              Specification
            </th>
            <th scope="col" class="px-6 py-4 text-center text-lg font-bold text-gray-800 uppercase tracking-wide w-1/3 border-l border-primary/20">
              {machine1.model_name || machine1.name}
            </th>
            <th scope="col" class="px-6 py-4 text-center text-lg font-bold text-gray-800 uppercase tracking-wide w-1/3 border-l border-primary/20">
              {machine2.model_name || machine2.name}
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-primary/20">
          <!-- Images Row -->
          <tr class="bg-primary/5">
            <td class="px-6 py-4 text-sm font-semibold text-gray-700">
              Image
            </td>
            <td class="px-6 py-8 text-center border-l border-primary/20">
              <div class="cursor-pointer transition-opacity duration-200 group" on:click={() => openLightbox(machine1)}>
                <div class="aspect-square flex items-center justify-center">
                  <LazyImage
                    machineId={machine1.id}
                    imagePath={machine1.image_path}
                    signedImageUrl={machine1.signedImageUrl}
                    alt={getImageAlt(machine1)}
                     containerClass="w-full h-full !rounded-2xl shadow-md"
                    imgClass="group-hover:scale-105 p-8 transition-transform duration-300 h-full"
                  />
                </div>
              </div>
            </td>
            <td class="px-6 py-8 text-center border-l border-primary/20">
              <div class="cursor-pointer transition-opacity duration-200 group" on:click={() => openLightbox(machine2)}>
                <div class="aspect-square flex items-center justify-center">
                  <LazyImage
                    machineId={machine2.id}
                    imagePath={machine2.image_path}
                    signedImageUrl={machine2.signedImageUrl}
                    alt={getImageAlt(machine2)}
                    containerClass="w-full h-full !rounded-2xl shadow-md"
                    imgClass="group-hover:scale-105 p-8 transition-transform duration-300"
                  />
                </div>
              </div>
            </td>
          </tr>

          <!-- Vendor Links Row -->
          <tr class="bg-primary/5">
            <td class="px-6 py-4 text-sm font-semibold text-gray-700">
              Current Price
            </td>
            <td class="px-6 py-4 text-center border-l border-primary/20">
              <CTADropdown
                vendors={normalizedVendors1}
                buttonText="Check Price"
                isOpen={openDropdownId === machine1.id}
                on:toggle={() => handleCTAToggle(machine1.id)}
                on:close={handleCTAClose}
              />
            </td>
            <td class="px-6 py-4 text-center border-l border-primary/20">
              <CTADropdown
                vendors={normalizedVendors2}
                buttonText="Check Price"
                isOpen={openDropdownId === machine2.id}
                on:toggle={() => handleCTAToggle(machine2.id)}
                on:close={handleCTAClose}
              />
            </td>
          </tr>

          {#each specOrder as spec, index}
            <tr class="{index % 2 === 0 ? 'bg-white' : 'bg-primary/5'} transition-all duration-200">
              <td class="px-6 py-4 text-sm font-semibold text-gray-700">
                {spec.label}
              </td>
              
              <!-- Machine 1 Value -->
              <td class="px-6 py-4 text-center text-sm text-gray-800 border-l border-primary/20">
                {#if spec.isSpecial && spec.key === 'machine_type'}
                  <span class="px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full border {getMachineTypeClass(machine1.machine_type)}">
                    {formatValue(machine1[spec.key], spec.key)}
                  </span>
                {:else if spec.isBooleanLike && isBooleanLike(machine1[spec.key])}
                  <StatusPill value={machine1[spec.key]} />
                {:else}
                  <span class="font-medium">
                    {formatValue(machine1[spec.key] || (spec.key === 'boiler_configuration' ? machine1.boiler_type || machine1.boiler : null), spec.key)}
                  </span>
                {/if}
              </td>
              
              <!-- Machine 2 Value -->
              <td class="px-6 py-4 text-center text-sm text-gray-800 border-l border-primary/20">
                {#if spec.isSpecial && spec.key === 'machine_type'}
                  <span class="px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full border {getMachineTypeClass(machine2.machine_type)}">
                    {formatValue(machine2[spec.key], spec.key)}
                  </span>
                {:else if spec.isBooleanLike && isBooleanLike(machine2[spec.key])}
                  <StatusPill value={machine2[spec.key]} />
                {:else}
                  <span class="font-medium">
                    {formatValue(machine2[spec.key] || (spec.key === 'boiler_configuration' ? machine2.boiler_type || machine2.boiler : null), spec.key)}
                  </span>
                {/if}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- Lightbox Modal -->
<ImageLightbox 
  bind:isOpen={lightboxOpen}
  imageSrc={lightboxImage.src}
  imageAlt={lightboxImage.alt}
  imageCaption={lightboxImage.caption}
  imageSource={lightboxImage.source}
  machineName={lightboxImage.machineName}
  on:close={closeLightbox}
/>
{:else}
  <div class="text-center py-12">
    <p class="text-gray-600">Loading comparison data...</p>
  </div>
{/if}

<style>
  /* Custom scrollbar styling to match MachineTable */
  .overflow-x-auto {
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 #f1f5f9;
  }

  .overflow-x-auto::-webkit-scrollbar {
    height: 8px;
  }

  .overflow-x-auto::-webkit-scrollbar-track {
    background: #f1f5f9;
    border-radius: 4px;
  }

  .overflow-x-auto::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 4px;
    border: 1px solid #f1f5f9;
  }

  .overflow-x-auto::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
  }

  /* Enhanced mobile horizontal scroll */
  .mobile-horizontal-scroll {
    scroll-behavior: smooth;
    -webkit-overflow-scrolling: touch;
  }

  .mobile-horizontal-scroll::-webkit-scrollbar {
    height: 6px;
  }

  .mobile-horizontal-scroll::-webkit-scrollbar-track {
    background: #f1f5f9;
    border-radius: 3px;
  }

  .mobile-horizontal-scroll::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 3px;
  }

  .mobile-horizontal-scroll::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
  }
</style> 