// @ts-check
import { defineConfig } from 'astro/config';

import svelte from '@astrojs/svelte';
import node from '@astrojs/node';

import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  output: 'server',
  adapter: node({
    mode: 'standalone'
  }),
  integrations: [svelte()],

  vite: {
    plugins: [tailwindcss()]
  }
});