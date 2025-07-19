// @ts-check
import { defineConfig } from 'astro/config';

import svelte from '@astrojs/svelte';
import cloudflare from '@astrojs/cloudflare';

import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://espressopicker.com',
  output: 'server',
  adapter: cloudflare(),
  integrations: [svelte()],

  vite: {
    plugins: [tailwindcss()]
  }
});