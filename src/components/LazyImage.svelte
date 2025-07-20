<script lang="ts">
  import { onMount, createEventDispatcher } from 'svelte';

  export let machineId: string;
  export let imagePath: string | null = null;
  export let signedImageUrl: string | null = null; // Pre-loaded image URL
  export let alt: string = '';
  export let title: string = '';
  export let containerClass: string = 'w-16 h-16';
  export let imgClass: string = '';
  export let fillContainer: boolean = false;

  let imageUrl: string | null = null;
  let loading = true;
  let error = false;
  const dispatch = createEventDispatcher();

  async function loadImage() {
    // First, check if we already have a signed URL (pre-loaded)
    if (signedImageUrl) {
      imageUrl = signedImageUrl;
      loading = false;
      return;
    }

    // If no pre-loaded URL and no image path, show placeholder
    if (!imagePath) {
      loading = false;
      error = true;
      return;
    }

    // Fallback: try to fetch the image (only in browser)
    if (typeof window === 'undefined') {
      error = true;
      return;
    }
    
    try {
      console.log(`Fetching image for machine ${machineId}: ${imagePath}`);
      
      // Dynamically import store only in browser
      const { fetchMachineImage } = await import('../lib/machinesStore');
      const imageData = await fetchMachineImage(machineId, 400);

      if (!imageData || !imageData.url) {
        console.warn(`❌ Image not found for machine ${machineId} - path: ${imagePath}`);
        error = true;
      } else {
        imageUrl = imageData.url;
        dispatch('imageLoaded', { machineId, url: imageUrl });
      }
    } catch (err) {
      console.error(`Error loading image for machine ${machineId}:`, err);
      error = true;
    } finally {
      loading = false;
    }
  }

  onMount(() => {
    // Load immediately if we have a signed URL, otherwise add small delay
    if (signedImageUrl) {
      loadImage();
    } else {
      setTimeout(loadImage, Math.random() * 100);
    }
  });

  // Reactively update when signedImageUrl changes
  $: if (signedImageUrl && signedImageUrl !== imageUrl) {
    imageUrl = signedImageUrl;
    loading = false;
    error = false;
  }
</script>

<div class="bg-white rounded overflow-hidden flex items-center justify-center cursor-pointer transition-colors {containerClass}">
  {#if loading}
    <!-- Loading placeholder -->
    <div class="animate-pulse bg-gray-200 h-full w-full flex items-center justify-center">
      <svg class="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd" />
      </svg>
    </div>
  {:else if error || !imageUrl}
    <!-- Error/fallback placeholder -->
    <img 
      class:w-full={fillContainer}
      class:h-full={fillContainer}
      class:object-cover={fillContainer}
      class:max-h-full={!fillContainer}
      class:max-w-full={!fillContainer}
      class:object-contain={!fillContainer}
      class={imgClass}
      src="/placeholder-machine.svg" 
      {alt} 
      {title} 
      loading="lazy"
    />
  {:else}
    <!-- Actual image -->
    <img 
      class:w-full={fillContainer}
      class:h-full={fillContainer}
      class:object-cover={fillContainer}
      class:max-h-full={!fillContainer}
      class:max-w-full={!fillContainer}
      class:object-contain={!fillContainer}
      class={imgClass}
      src={imageUrl} 
      {alt} 
      {title} 
      loading="lazy"
      on:error={() => {
        console.warn(`Image failed to load: ${imageUrl}`);
        error = true;
        imageUrl = null;
      }}
    />
  {/if}
</div> 