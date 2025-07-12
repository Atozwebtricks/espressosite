## Relevant Files

- `astro.config.mjs` - Main Astro project configuration (integrations for Svelte, Tailwind).
- `tailwind.config.cjs` - Tailwind CSS theme and plugin configuration.
- `.env` - To store Supabase URL and public/private keys securely.
- `src/lib/supabase.ts` - Initializes and exports the Supabase client.
- `db/schema.sql` - SQL script to create the `machines` table as defined in the PRD.
- `db/seed.ts` - A script to populate the `machines` table with initial data for testing and development.
- `src/pages/index.astro` - The homepage, responsible for fetching all machines and displaying the main list.
- `src/components/Filters.svelte` - Interactive component for filtering machines by brand, price, etc.
- `src/components/MachineTable.svelte` - Renders the sortable and filterable table of machines.
- `src/components/CompareTray.svelte` - UI element to show which machines have been selected for comparison.
- `src/pages/machines/[id].astro` - Dynamic route page to display the details of a single machine.
- `src/components/MachineSpecs.svelte` - Component to display detailed specifications and an affiliate link.
- `src/pages/compare.astro` - Page that takes machine IDs from a URL query param to show a comparison.
- `src/components/CompareView.svelte` - Renders the side-by-side comparison table for two machines.

### Notes

- Astro (`.astro`) files will be used for pages (routes) and can contain server-side logic for data fetching.
- Svelte (`.svelte`) components will be used for interactive UI elements on the client-side (`client:load`).
- Use `npx astro dev` to start the development server.
- Supabase credentials should be stored in `.env` and not committed to version control.

## Tasks

- [x] 1.0 Project Setup & Configuration
  - [x] 1.1 Initialize a new Astro project.
  - [x] 1.2 Add and configure the Svelte integration for Astro.
  - [x] 1.3 Add and configure Tailwind CSS for styling.
  - [x] 1.4 Create a `.env` file and add placeholders for Supabase credentials.
  - [x] 1.5 Create a `src/lib/supabase.ts` file to initialize and export the Supabase client.
- [x] 2.0 Database Setup & Data Seeding
  - [x] 2.1 Write the `CREATE TABLE` script for the `machines` table in `db/schema.sql`.
  - [x] 2.2 Create a Supabase project and run the schema script in the SQL editor.
  - [x] 2.3 Create a seed script (`db/seed.ts`) to populate the `machines` table with at least 5-10 sample machines.
  - [x] 2.4 Add the seed script as a runnable command in `package.json`.
- [x] 3.0 Implement Machine Listing & Filtering Page
    - [x] 3.1 On the homepage (`src/pages/index.astro`), fetch all machines from the Supabase `machines` table.
    - [x] 3.2 Create the `MachineTable.svelte` component to receive the machine data as a prop and display it in a table.
    - [x] 3.3 Create the `Filters.svelte` component with controls for the specified filterable fields (brand, price, etc.).
    - [x] 3.4 Implement state management within a parent Svelte component on the homepage to connect `Filters.svelte` and `MachineTable.svelte`.
    - [x] 3.5 Create the `CompareTray.svelte` component, which updates when a user selects a machine from the table (max 2).
    - [x] 3.6 Add a "Compare" button to the tray that navigates to the compare page with the selected machine IDs in the URL.
- [x] 4.0 Implement Machine Detail Page
    - [x] 4.1 In the dynamic route `src/pages/machines/[slug].astro`, fetch data for a single machine using the `slug` parameter.
    - [x] 4.2 Pass the fetched data to a `MachineSpecs.svelte` component.
    - [x] 4.3 The component should render all relevant machine details: name, image, specs, and a clickable affiliate link.
    - [x] 4.4 Ensure the page handles cases where a machine ID is not found.
- [x] 5.0 Implement Side-by-Side Comparison Page
    - [x] 5.1 In `src/pages/compare.astro`, parse the machine IDs from the URL query string (`?ids=...`).
    - [x] 5.2 Fetch the data for both machines from Supabase.
    - [x] 5.3 Create the `CompareView.svelte` component to display the specifications of both machines in a side-by-side table for easy comparison.
    - [x] 5.4 Add a "Share" button that copies the current URL to the user's clipboard.
    - [x] 5.5 Handle potential errors, such as incorrect or missing `ids` in the URL. 