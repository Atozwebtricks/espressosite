<script lang="ts">
  import { onMount } from 'svelte';
  import { createClient } from '@supabase/supabase-js';

  export let machineId: string;
  export let imagePath: string | null = null;
  export let alt: string = '';
  export let title: string = '';
  export let containerClass: string = 'w-16 h-16';
  export let imgClass: string = '';
  export let fillContainer: boolean = false;

  let imageUrl: string | null = null;
  let loading = true;
  let error = false;

  // Initialize Supabase client
  const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
  const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;
  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  async function loadImage() {
    if (!imagePath) {
      loading = false;
      return;
    }

    try {
      console.log(`Loading image for machine ${machineId}: ${imagePath}`);
      
      const { data: signed, error: signError } = await supabase.storage
        .from('espresso-machine-images')
        .createSignedUrl(imagePath, 60 * 60 * 24, {
          transform: { width: 400, resize: 'contain', quality: 100 }
        });

      if (signError || !signed?.signedUrl) {
        console.warn(`❌ Image not found for machine ${machineId} - path: ${imagePath}`, signError);
        error = true;
      } else {
        imageUrl = signed.signedUrl;
      }
    } catch (err) {
      console.error(`Error loading image for machine ${machineId}:`, err);
      error = true;
    } finally {
      loading = false;
    }
  }

  onMount(() => {
    // Small delay to avoid overwhelming the storage API
    setTimeout(loadImage, Math.random() * 100);
  });
</script>

<div class="bg-white rounded overflow-hidden flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors {containerClass}">
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
    />
  {/if}
</div> 