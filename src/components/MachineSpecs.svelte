<script>
  import { normalizeVendors, formatPrice } from '../lib/vendorUtils';
  import { 
    formatHeatupTime, 
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
  
  export let machine;

  // Lightbox state
  let lightboxOpen = false;
  let lightboxImage = {
    src: '',
    alt: '',
    caption: '',
    source: '',
    machineName: ''
  };
  
  $: normalizedVendors = normalizeVendors(machine.vendors);

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

  const specLabels = {
    brand: 'Brand',
    price_usd: 'Price (MSRP)',
    release_year: 'Release Year',
    machine_type: 'Machine Type',
    boiler_configuration: 'Boiler Configuration',
    heating_system: 'Heating System',
    number_of_boilers: 'Number of Boilers',
    heat_up_seconds: 'Heat-up Time',
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
      case 'heat_up_seconds':
        return formatHeatupTime(value);
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

  // Track image loading state
  let imageLoaded = false;
  let imageError = false;

  function handleImageLoad() {
    imageLoaded = true;
    imageError = false;
  }

  function handleImageError(event) {
    imageError = true;
    // Fallback to placeholder if image fails to load
    if (event.target.src !== '/placeholder-machine.svg') {
      event.target.src = '/placeholder-machine.svg';
    }
  }
</script>

<div class="bg-white shadow-lg rounded-lg overflow-hidden">
  <div class="md:flex">
    <div class="md:w-1/2 relative bg-gray-100 flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors" style="aspect-ratio: 1;" on:click={openLightbox}>
      <!-- Loading state -->
      {#if !imageLoaded && !imageError}
        <div class="w-full h-full bg-gray-200 animate-pulse flex items-center justify-center">
          <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
          </svg>
        </div>
      {/if}
      
      <img 
        class="max-w-full max-h-full object-contain {!imageLoaded ? 'hidden' : ''}" 
        src={getImageUrl(machine)}
        alt={getImageAlt(machine)}
        title={getImageTitle(machine)}
        loading="lazy"
        on:load={handleImageLoad}
        on:error={handleImageError}
      />
      
      {#if machine.image_caption && imageLoaded}
        <div class="absolute bottom-0 left-0 right-0 p-2 bg-black bg-opacity-75 text-white text-sm text-center">
          {machine.image_caption}
        </div>
      {/if}

      <!-- Click to expand hint -->
      <div class="absolute top-2 left-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded opacity-0 hover:opacity-100 transition-opacity">
        Click to expand
      </div>
    </div>
    <div class="md:w-1/2 p-8">
      <h1 class="text-3xl font-bold mb-2 text-gray-900">{machine.model_name || machine.name}</h1>
      <p class="text-lg text-gray-600 mb-4">{machine.brand}</p>
      
      {#if machine.price_usd}
        <p class="text-xl font-semibold text-gray-900 mb-6">{formatValue('price_usd', machine.price_usd)}</p>
      {/if}
      
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
        {#each displaySpecs as [key, label]}
          <div>
            <p class="font-semibold text-gray-600">{label}</p>
            <p class="text-gray-800">{formatValue(key, machine[key])}</p>
          </div>
        {/each}
      </div>
      
      {#if normalizedVendors.length > 0}
        <div class="space-y-2">
          <h3 class="font-semibold text-gray-700 mb-3">Available from:</h3>
          {#each normalizedVendors as vendor}
            <a 
              href={vendor.url} 
              target="_blank" 
              rel="noopener noreferrer"
              class="w-full text-center bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-lg transition duration-300 ease-in-out block"
            >
              Buy at {vendor.name}{vendor.price ? ` - ${formatPrice(vendor.price)}` : ''}
            </a>
          {/each}
        </div>
      {:else}
        <div class="w-full text-center bg-gray-400 text-white font-bold py-3 px-4 rounded-lg">
          No vendors available
        </div>
      {/if}
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