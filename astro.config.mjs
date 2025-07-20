// @ts-check
import { defineConfig, envField } from 'astro/config';

import svelte from '@astrojs/svelte';
import cloudflare from '@astrojs/cloudflare';

import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://espressopicker.com',
  output: 'server',
  adapter: cloudflare({
    imageService: 'passthrough'
  }),
  
  env: {
    schema: {
      PUBLIC_SUPABASE_URL: envField.string({
        context: 'client',
        access: 'public',
      }),
      PUBLIC_SUPABASE_ANON_KEY: envField.string({
        context: 'client', 
        access: 'public',
      }),
      SUPABASE_URL: envField.string({
        context: 'server',
        access: 'secret',
        optional: true,
      }),
      SUPABASE_SERVICE_ROLE_KEY: envField.string({
        context: 'server',
        access: 'secret', 
        optional: true,
      }),
    }
  },

  integrations: [svelte()],

  vite: {
    plugins: [tailwindcss()],
    esbuild: {
      drop: ['console', 'debugger'],
    },
  }
});