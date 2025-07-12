<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let isOpen: boolean = false;
  export let imageSrc: string = '';
  export let imageAlt: string = '';
  export let imageCaption: string = '';
  export let imageSource: string = '';
  export let machineName: string = '';

  const dispatch = createEventDispatcher();

  let imageLoaded = false;
  let imageError = false;
  let imageElement: HTMLImageElement;

  // Reset loading state when lightbox opens with new image
  $: if (isOpen && imageSrc) {
    preloadImage();
  }

  // Reset loading state when lightbox closes
  $: if (!isOpen) {
    imageLoaded = false;
    imageError = false;
  }

  function preloadImage() {
    if (!imageSrc) return;
    
    imageLoaded = false;
    imageError = false;
    
    // Create a new image to preload
    const img = new Image();
    img.onload = () => {
      imageLoaded = true;
      imageError = false;
    };
    img.onerror = () => {
      imageError = true;
      imageLoaded = false;
      // Fallback to placeholder
      if (imageSrc !== '/placeholder-machine.svg') {
        imageSrc = '/placeholder-machine.svg';
        preloadImage(); // Try loading placeholder
      }
    };
    img.src = imageSrc;
  }

  function closeModal() {
    isOpen = false;
    dispatch('close');
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      closeModal();
    }
  }

  function handleBackdropClick(event: MouseEvent) {
    if (event.target === event.currentTarget) {
      closeModal();
    }
  }

  function handleImageLoad() {
    imageLoaded = true;
    imageError = false;
  }

  function handleImageError() {
    imageError = true;
    imageLoaded = false;
    // Fallback to placeholder
    if (imageElement && imageElement.src !== '/placeholder-machine.svg') {
      imageElement.src = '/placeholder-machine.svg';
    }
  }
</script>

<svelte:window on:keydown={handleKeydown} />

{#if isOpen}
  <!-- Modal backdrop with improved styling -->
  <div 
    class="fixed inset-0 bg-gray-900/80 backdrop-blur-sm flex items-center justify-center z-50 p-4 transition-all duration-300 ease-out"
    on:click={handleBackdropClick}
    role="dialog"
    aria-modal="true"
    aria-labelledby="lightbox-title"
  >
    <!-- Modal content with modern design -->
    <div class="relative max-w-6xl max-h-[90vh] w-full bg-white rounded-2xl shadow-2xl overflow-hidden transform transition-all duration-300 ease-out scale-100">
      <!-- Header with close button and machine name -->
      <div class="relative bg-gradient-to-r from-primary/5 to-primary/10 px-6 py-4 border-b border-primary/20">
        {#if machineName}
          <h3 id="lightbox-title" class="text-xl font-bold text-gray-800 font-serif pr-12">
            {machineName}
          </h3>
        {/if}
        
        <!-- Close button -->
        <button 
          class="absolute top-4 right-4 p-2 rounded-full bg-white/90 hover:bg-white text-gray-600 hover:text-gray-800 transition-all duration-200 shadow-md hover:shadow-lg group"
          on:click={closeModal}
          aria-label="Close lightbox"
        >
          <svg class="w-5 h-5 group-hover:scale-110 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>

      <!-- Image container with loading state -->
      <div class="flex-1 flex items-center justify-center p-8 bg-gradient-to-br from-gray-50 to-white min-h-[400px] relative">
        <!-- Loading spinner -->
        {#if !imageLoaded && !imageError}
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="flex flex-col items-center space-y-4">
              <!-- Animated spinner -->
              <div class="animate-spin rounded-full h-12 w-12 border-4 border-gray-200 border-t-primary"></div>
              <p class="text-sm text-gray-500 font-medium">Loading image...</p>
            </div>
          </div>
        {/if}

        <!-- Image container -->
        <div class="relative max-w-full max-h-full {imageLoaded ? 'opacity-100' : 'opacity-0'} transition-opacity duration-300 ease-in-out">
          <img 
            bind:this={imageElement}
            src={imageSrc}
            alt={imageAlt}
            class="max-w-full max-h-[60vh] object-contain rounded-xl shadow-lg"
            on:load={handleImageLoad}
            on:error={handleImageError}
          />
          
          <!-- Subtle loading placeholder behind image -->
          <div class="absolute inset-0 bg-gray-200 rounded-xl -z-10"></div>
        </div>

        <!-- Error state -->
        {#if imageError}
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="text-center space-y-3">
              <svg class="w-16 h-16 text-gray-400 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
              <p class="text-sm text-gray-500">Unable to load image</p>
            </div>
          </div>
        {/if}
      </div>

      <!-- Image info with improved styling and centered text -->
      {#if imageCaption || imageSource}
        <div class="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-5 border-t border-gray-200">
          <div class="text-center space-y-3">
            {#if imageCaption}
              <div class="flex items-center justify-center">
                <svg class="w-4 h-4 mr-2 text-primary flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <p class="text-sm text-gray-700 leading-relaxed font-medium">
                  {imageCaption}
                </p>
              </div>
            {/if}
            {#if imageSource}
              <div class="flex items-center justify-center pt-1">
                <svg class="w-3 h-3 mr-1.5 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                </svg>
                <p class="text-xs text-gray-500 font-medium tracking-wide">
                  Image source: <span class="text-gray-600">{imageSource}</span>
                </p>
              </div>
            {/if}
            
            <!-- Keyboard shortcut hint centered at bottom -->
            <div class="pt-2 border-t border-gray-200/60">
              <div class="inline-flex items-center justify-center bg-gray-800/80 text-white text-xs px-3 py-1.5 rounded-md backdrop-blur-sm">
                <svg class="w-3 h-3 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1721 9z"></path>
                </svg>
                Press ESC to close
              </div>
            </div>
          </div>
        </div>
      {:else}
        <!-- Show keyboard shortcut even when no caption/source -->
        <div class="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 border-t border-gray-200">
          <div class="text-center">
            <div class="inline-flex items-center justify-center bg-gray-800/80 text-white text-xs px-3 py-1.5 rounded-md backdrop-blur-sm">
              <svg class="w-3 h-3 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"></path>
              </svg>
              Press ESC to close
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
  :global(body.modal-open) {
    overflow: hidden;
  }

  /* Animation for modal entrance */
  .fixed {
    animation: fadeIn 0.3s ease-out;
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  /* Enhanced modal scaling animation */
  .relative.max-w-6xl {
    animation: scaleIn 0.3s ease-out;
  }

  @keyframes scaleIn {
    from {
      opacity: 0;
      transform: scale(0.9);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }

  /* Smooth image loading effect */
  img {
    transition: opacity 0.3s ease-in-out;
  }

  img[src="/placeholder-machine.svg"] {
    opacity: 0.7;
  }

  /* Custom scrollbar for any overflow */
  .overflow-auto {
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 #f1f5f9;
  }

  .overflow-auto::-webkit-scrollbar {
    width: 6px;
  }

  .overflow-auto::-webkit-scrollbar-track {
    background: #f1f5f9;
    border-radius: 3px;
  }

  .overflow-auto::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 3px;
  }

  .overflow-auto::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
  }

  /* Spinner animation enhancement */
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .animate-spin {
    animation: spin 1s linear infinite;
  }
</style> 