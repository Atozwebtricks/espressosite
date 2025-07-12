import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false, // We don't need auth sessions for this read-only app
    autoRefreshToken: false,
  },
  db: {
    schema: 'public',
  },
  global: {
    headers: {
      'cache-control': 'no-cache',
    },
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
})

// Image helper for fetching signed URLs with resizing
export async function fetchMachineImage(id: string, w = 800) {
  try {
    // 1. get path + caption from DB
    const { data: row, error } = await supabase
      .from('espresso_machines')
      .select('image_path, image_caption, image_source')
      .eq('id', id)
      .single();
    
    if (error || !row?.image_path) {
      console.warn(`No image found for machine ${id}:`, error);
      return null;
    }

    // 2. sign URL (24 hours instead of 6) + resize to prevent expiration issues
    const { data: signed, error: signError } = await supabase.storage
      .from('espresso-machine-images')
      .createSignedUrl(row.image_path, 60 * 60 * 24, {
        transform: { width: w, resize: 'contain', quality: 100 }
      });

    if (signError || !signed?.signedUrl) {
      console.error(`❌ Image not found for machine ${id} - path: ${row.image_path}`, signError);
      return null;
    }

    return { 
      url: signed.signedUrl, 
      image_caption: row.image_caption,
      image_source: row.image_source 
    };
  } catch (error) {
    console.error(`Error fetching machine image for ${id}:`, error);
    return null;
  }
}

// Batch fetch images for multiple machines
export async function fetchMachineImages(machineIds: string[], w = 400) {
  try {
    // 1. Get all image paths from DB
    const { data: rows, error } = await supabase
      .from('espresso_machines')
      .select('id, image_path, image_caption, image_source')
      .in('id', machineIds);
    
    if (error || !rows) {
      console.warn('Error fetching machine image data:', error);
      return {};
    }

    // 2. Create signed URLs for machines that have image_path (24 hours expiry)
    const imagePromises = rows
      .filter(row => row.image_path)
      .map(async (row) => {
        const { data: signed, error: signError } = await supabase.storage
          .from('espresso-machine-images')
          .createSignedUrl(row.image_path, 60 * 60 * 24, {
            transform: { width: w, resize: 'contain', quality: 100 }
          });

        if (signError || !signed?.signedUrl) {
          console.error(`❌ Batch: Image not found for machine ${row.id} - path: ${row.image_path}`, signError);
          return [row.id, null];
        }

        return [row.id, {
          url: signed.signedUrl,
          image_caption: row.image_caption,
          image_source: row.image_source
        }];
      });

    const results = await Promise.all(imagePromises);
    return Object.fromEntries(results);
  } catch (error) {
    console.error('Error batch fetching machine images:', error);
    return {};
  }
} 