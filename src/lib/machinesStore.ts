import { writable, type Writable } from 'svelte/store';
import { createClient } from '@supabase/supabase-js';

interface Machine {
  id: string;
  name: string;
  brand: string;
  model_name: string;
  [key: string]: any;
}

interface MachineStoreState {
  machines: Machine[];
  loading: boolean;
  error: string | null;
  lastUpdated: number;
}

const CACHE_KEY = 'machinesCache';
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes in milliseconds
const REFRESH_THRESHOLD = 2 * 60 * 1000; // Only refresh if data is older than 2 minutes

// Initialize Supabase client for the store (Cloudflare Workers compatible)
const supabase = createClient(
  import.meta.env.PUBLIC_SUPABASE_URL,
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY,
  {
    auth: {
      persistSession: false,
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
    // Real-time features disabled for Cloudflare Workers compatibility
  }
);

// Helper function to safely access localStorage
function getFromLocalStorage(): Machine[] {
  if (typeof window === 'undefined') return [];
  
  try {
    const cached = localStorage.getItem(CACHE_KEY);
    if (cached) {
      const parsed = JSON.parse(cached);
      // Always return cached data regardless of age - persistence is key
      console.log('Loading machines from cache');
      return parsed.data || [];
    }
  } catch (error) {
    console.warn('Failed to load machines from localStorage:', error);
  }
  return [];
}

function saveToLocalStorage(machines: Machine[]): void {
  if (typeof window === 'undefined') return;
  
  try {
    localStorage.setItem(CACHE_KEY, JSON.stringify({
      data: machines,
      timestamp: Date.now()
    }));
  } catch (error) {
    console.warn('Failed to save machines to localStorage:', error);
  }
}

// Create the store
function createMachinesStore(): Writable<MachineStoreState> & { refresh: (silent?: boolean) => Promise<void>; clearCache: () => void } {
  const initialState: MachineStoreState = {
    machines: getFromLocalStorage(),
    loading: false,
    error: null,
    lastUpdated: 0
  };

  const { subscribe, set, update } = writable(initialState);

  // Main fetch function
  async function fetchMachines(silent = false): Promise<void> {
    if (!silent) {
      update(state => ({ ...state, loading: true, error: null }));
    }

    try {
      console.log('Fetching machines from Supabase...');
      
      // Fetch machines data (no session refresh needed for read-only app)
      const { data: machines, error } = await supabase
        .from('espresso_machines')
        .select('*')
        .order('brand', { ascending: true });

      if (error) {
        throw error;
      }

      if (!machines || machines.length === 0) {
        console.warn('No machines found in database');
        update(state => ({ 
          ...state, 
          loading: false, 
          error: 'No machines found in database'
        }));
        return;
      }

      // Update store and cache
      const newState: MachineStoreState = {
        machines,
        loading: false,
        error: null,
        lastUpdated: Date.now()
      };

      set(newState);
      saveToLocalStorage(machines);
      
      console.log(`Successfully loaded ${machines.length} machines`);
    } catch (error) {
      console.error('Error fetching machines:', error);
      
      // Always try to use cached data, never show errors to users
      const cachedMachines = getFromLocalStorage();
      if (cachedMachines.length > 0) {
        console.log('Using cached data due to connection issue');
        update(state => ({ 
          ...state, 
          machines: cachedMachines, 
          loading: false, 
          error: null // Don't show error to user
        }));
      } else {
        // Even if no cached data, don't show error - just empty state
        console.log('No cached data available');
        update(state => ({ 
          ...state, 
          loading: false, 
          error: null // Don't show error to user
        }));
      }
    }
  }

  // Auto-refresh logic - only try once on initial load
  if (typeof window !== 'undefined') {
    // Initial load - only try if no cached data exists
    const cachedData = getFromLocalStorage();
    if (cachedData.length === 0) {
      console.log('No cached data found, attempting initial fetch...');
      fetchMachines();
    } else {
      console.log('Using cached data, skipping initial fetch');
    }

    // Optional: Very gentle refresh only when user returns after long absence
    // This is much less aggressive than before
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible') {
        const cached = getFromLocalStorage();
        if (cached.length > 0) {
          try {
            const cachedData = localStorage.getItem(CACHE_KEY);
            if (cachedData) {
              const parsed = JSON.parse(cachedData);
              const timeSinceLastUpdate = Date.now() - (parsed.timestamp || 0);
              
              // Only refresh if data is very old (1 hour+) and user explicitly returns
              if (timeSinceLastUpdate > 60 * 60 * 1000) {
                console.log('Data is very old, attempting background refresh...');
                fetchMachines(true); // Silent refresh
              }
            }
          } catch (error) {
            console.warn('Error checking cache staleness:', error);
          }
        }
      }
    });

    // No periodic refresh - prioritize persistence over freshness
  }

  return {
    subscribe,
    set,
    update,
    // Expose methods for manual control
    refresh: fetchMachines,
    clearCache: () => {
      if (typeof window !== 'undefined') {
        localStorage.removeItem(CACHE_KEY);
      }
    }
  };
}

// Export the store instance
export const machinesStore = createMachinesStore();

// Export helper functions for image loading
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