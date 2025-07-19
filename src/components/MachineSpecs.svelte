<script>
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
  import LazyImage from './LazyImage.svelte';
  import { fetchMachineImages } from '../lib/machinesStore';
  
  export let machine;

  // Load images for the machine on mount
  onMount(async () => {
    if (machine?.id) {
      try {
        const machineIds = [machine.id];
        const images = await fetchMachineImages(machineIds);
        
        // Update machine with signed image URL
        if (images[machine.id]) {
          machine = {
            ...machine,
            signedImageUrl: images[machine.id].url,
            image_caption: images[machine.id].image_caption || machine.image_caption,
            image_source: images[machine.id].image_source || machine.image_source
          };
        }
      } catch (error) {
        console.error('Error loading image for machine:', error);
      }
    }
  });

  // Lightbox state
  let lightboxOpen = false;
  let lightboxImage = {
    src: '',
    alt: '',
    caption: '',
    source: '',
    machineName: ''
  };

  function getVendorUrl(vendor) {
    let finalUrl = vendor.url;
    
    // Add Amazon affiliate tracking ID for Amazon links
    if (vendor.url.includes('amazon.com') || vendor.url.includes('amzn.to')) {
      const affiliateTag = 'espressopicker-20';
      
      try {
        const url = new URL(vendor.url);
        
        // For shortened Amazon URLs (amzn.to), add the tag as a query parameter
        if (vendor.url.includes('amzn.to')) {
          url.searchParams.set('tag', affiliateTag);
        } else {
          // For full Amazon URLs, add the tag parameter
          url.searchParams.set('tag', affiliateTag);
        }
        
        finalUrl = url.toString();
      } catch (error) {
        // Fallback: if URL parsing fails, append manually
        const separator = vendor.url.includes('?') ? '&' : '?';
        finalUrl = `${vendor.url}${separator}tag=${affiliateTag}`;
      }
    }
    return finalUrl;
  }

  $: normalizedVendors = normalizeVendors(machine.vendors);

  // Sort vendors to show Amazon first
  $: sortedVendors = machine?.vendors ? [...normalizeVendors(machine.vendors)].sort((a, b) => {
    const aIsAmazon = a.name.toLowerCase().includes('amazon');
    const bIsAmazon = b.name.toLowerCase().includes('amazon');
    if (aIsAmazon && !bIsAmazon) return -1;
    if (!aIsAmazon && bIsAmazon) return 1;
    return 0;
  }) : [];

  // Function to get the best available image URL with fallbacks
  function getImageUrl(machine) {
    // Priority: signedImageUrl (from Supabase Storage) > placeholder
    // Never use raw image_path as it would try to load from local server
    return machine.signedImageUrl || '/placeholder-machine.svg';
  }

  // Function to get image alt text
  function getImageAlt(machine) {
    return machine.image_caption || machine.model_name || machine.name || 'Espresso Machine';
  }

  // Function to get image title (for hover tooltip)
  function getImageTitle(machine) {
    return machine.image_source ? `Source: ${machine.image_source}` : undefined;
  }

  // Function to open lightbox with machine image
  function openLightbox() {
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

  // Local helper to style machine type badge consistently with the rest of the site
  function getMachineTypeClass(machineType) {
    switch ((machineType || '').toLowerCase()) {
      case 'semi-automatic':
        return 'bg-[#fff5d0] text-black';
      case 'automatic':
        return 'bg-blue-50 text-blue-800';
      case 'super-automatic':
        return 'bg-purple-50 text-black';
      default:
        return 'bg-gray-50 text-gray-800';
    }
  }

  const specLabels = {
    brand: 'Brand',
    // price_usd: 'Price (MSRP)', // HIDDEN FOR NOW
    release_year: 'Release Year',
    machine_type: 'Machine Type',
    boiler_configuration: 'Boiler Configuration',
    heating_system: 'Heating System',
    number_of_boilers: 'Number of Boilers',
    // heat_up_seconds: 'Heat-up Time', // HIDDEN
    has_pid: 'PID Control',
    pre_infusion: 'Pre-infusion',
    built_in_grinder: 'Built-in Grinder',
    portafilter_mm: 'Portafilter Size',
    steam_wand_type: 'Steam Wand',
    is_plumbable: 'Plumbable',
    water_tank_l: 'Water Tank Capacity',
    has_water_filter: 'Water Filter Compatible',
    dimensions: 'Dimensions',
    weight_lbs: 'Weight',
    power_watts: 'Power',
    build_material: 'Build Material',
    warranty: 'Warranty'
  };

  const formatValue = (key, value) => {
    if (value === null || value === undefined || value === '') {
      return 'N/A';
    }
    
    switch (key) {
      case 'price_usd':
        return formatPriceNum(value);
      case 'machine_type':
        return formatMachineType(value);
      case 'boiler_configuration':
        // Handle both new and legacy field names
        return formatBoilerType(value || machine.boiler_type || machine.boiler);
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
        return value;
    }
  };

  // Get specs that have values to display
  $: displaySpecs = Object.entries(specLabels).filter(([key, label]) => {
    const value = machine[key];
    return value !== null && value !== undefined && value !== '';
  });
</script>

<div class="flex flex-col lg:flex-row gap-8 lg:gap-12 p-6 lg:p-8">
  <!-- Left Column: Image -->
  <div class="flex-shrink-0 lg:basis-[45%] lg:max-w-[45%]">
    <div
      class="w-full aspect-square mx-auto lg:mx-0 relative bg-gray-50 flex items-center justify-center cursor-pointer hover:bg-gray-100 transition-colors rounded-xl group shadow-lg"
      on:click={openLightbox}
    >
      <LazyImage
        machineId={machine.id}
        imagePath={machine.image_path}
        signedImageUrl={machine.signedImageUrl}
        alt={getImageAlt(machine)}
        containerClass="w-full h-full !rounded-xl"
        imgClass="p-4 group-hover:scale-105 transition-transform duration-300"
        fillContainer={true}
      />

      <!-- Click to expand hint -->
      <div
        class="absolute top-3 right-3 bg-black/60 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <svg
          class="w-3 h-3 inline-block mr-1"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
          >
          </path>
        </svg>
        Expand
      </div>
    </div>
  </div>

  <!-- Right Column: Details -->
  <div class="flex-1 min-w-0 lg:flex-1">
    <!-- Tags -->
    <div class="mb-6">
      <div class="flex flex-wrap gap-3">
        <!-- Machine type badge -->
        <span class="inline-flex items-center px-4 py-1.5 rounded-full text-xs font-semibold border-2 border-primary {getMachineTypeClass(machine.machine_type)}">
          {machine.machine_type || 'Espresso Machine'}
        </span>

        <!-- Boiler configuration badge -->
        {#if machine.boiler_configuration}
          <span class="inline-flex items-center px-4 py-1.5 rounded-full text-xs font-semibold border-2 border-primary bg-gray-50 text-gray-800">
            {machine.boiler_configuration}
          </span>
        {/if}

        <!-- PID Control badge -->
        {#if machine.has_pid}
          <span class="inline-flex items-center px-4 py-1.5 rounded-full text-xs font-semibold border-2 border-primary bg-green-100 text-gray-800">
            PID Control
          </span>
        {/if}
      </div>
    </div>

    <!-- Machine Name and Brand -->
    <div class="mb-6">
      <h1 class="font-serif font-bold text-3xl lg:text-4xl text-gray-900 leading-tight mb-3">
        {machine.model_name || machine.name}
      </h1>
      {#if machine.description}
        <p class="text-lg text-gray-600 italic mb-4">
          {machine.description}
        </p>
      {/if}
      <div class="flex items-center gap-2 text-gray-500">
        <span class="font-medium">{machine.brand}</span>
       
      </div>
    </div>

    <!-- Description -->
    {#if machine.description && machine.description.length > 100}
      <div class="mb-6">
        <p class="text-gray-700 leading-relaxed">
          {machine.description.slice(0, 200)}...
          <button class="text-primary hover:underline ml-1">Show more</button>
        </p>
      </div>
    {/if}

    <!-- Vendor Links -->
    {#if sortedVendors.length > 0}
      <div class="mb-6">
        <div class="space-y-3">
          {#each sortedVendors as vendor}
            {@const isAmazon = vendor.name.toLowerCase().includes('amazon')}
            <a
              href={getVendorUrl(vendor)}
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center justify-center w-full px-6 py-3 font-semibold rounded-lg transition-all duration-200 active:scale-[0.97] {isAmazon ? 'cta-btn-primary bg-cta text-dark border border-cta-dark hover:bg-cta/90 text-base' : 'cta-btn-secondary bg-white text-gray-800 border border-gray-300 hover:bg-gray-50'}"
            >
              <span>{isAmazon ? 'Check Price on Amazon' : `Buy at ${vendor.name}`}</span>
            </a>
          {/each}
        </div>
      </div>
    {/if}

    <!-- Key Stats -->
    <div class="mb-12 mt-12">
      <div class="grid grid-cols-3 lg:grid-cols-5 gap-6 text-center">
        {#if machine.boiler_configuration}
          <div>
            <div class="text-2xl lg:text-2xl font-bold text-gray-900">
              {machine.boiler_configuration.includes('Dual') ? '2' : '1'}
            </div>
            <div class="text-sm text-gray-500">Boiler{machine.boiler_configuration.includes('Dual') ? 's' : ''}</div>
          </div>
        {/if}
        
        {#if machine.portafilter_mm}
          <div>
            <div class="text-2xl lg:text-2xl font-bold text-gray-900">{machine.portafilter_mm}mm</div>
            <div class="text-sm text-gray-500">Portafilter</div>
          </div>
        {/if}
        
        {#if machine.water_tank_l}
          <div>
            <div class="text-2xl lg:text-2xl font-bold text-gray-900">{machine.water_tank_l}L</div>
            <div class="text-sm text-gray-500">Water Tank</div>
          </div>
        {/if}
        
        {#if machine.power_watts}
          <div>
            <div class="text-2xl lg:text-2xl font-bold text-gray-900">{machine.power_watts}W</div>
            <div class="text-sm text-gray-500">Power</div>
          </div>
        {/if}
        
        {#if machine.warranty_years || machine.warranty}
          <div>
            <div class="text-2xl lg:text-2xl font-bold text-gray-900">
              {machine.warranty_years || machine.warranty.replace(/[^0-9]/g, '') || '1'}Y
            </div>
            <div class="text-sm text-gray-500">Warranty</div>
          </div>
        {/if}
      </div>
    </div>



    <!-- Full Specifications -->
    <div class="mt-8">
      <h3 class="text-lg font-serif font-semibold text-gray-900 mb-4">
        Full Specifications
      </h3>
      <div class="grid gap-3">
        {#each displaySpecs as [key, label]}
          <div class="flex justify-between items-center py-2 border-b border-gray-200 last:border-b-0">
            <span class="text-sm font-medium text-gray-700">{label}</span>
            <span class="text-sm font-semibold text-gray-900 text-right">{formatValue(key, machine[key])}</span>
          </div>
        {/each}
      </div>
    </div>
  </div>
</div>

{#if lightboxOpen}
  <ImageLightbox
    isOpen={lightboxOpen}
    image={lightboxImage}
    on:close={closeLightbox}
  />
{/if}

<style>
  .cta-btn-primary {
    box-shadow: 0px 2px 0px #AF8A1D, inset 0px 3px 4px rgba(255, 255, 255, 0.25);
    transition: all 200ms ease;
  }

  .cta-btn-primary:active {
      box-shadow: 0px 0px 0px #AF8A1D, inset 0px 3px 4px rgba(255, 255, 255, 0.25);
  }

  .cta-btn-secondary {
    box-shadow: 0px 2px 0px #d1d5db; /* gray-300 */
    transition: all 200ms ease;
  }

  .cta-btn-secondary:active {
      box-shadow: 0px 0px 0px #d1d5db;
  }
</style> 