# Product Requirements Document: Espresso Machine Comparison Site

## 1. Introduction/Overview

Coffee newcomers and enthusiasts struggle to find consolidated, filterable information on home-espresso machines. This project aims to build a dedicated website that allows users to easily list, filter, and compare espresso machines side-by-side. Users can also view detailed specifications for each machine and access affiliate links for purchasing. A key feature will be the ability to share comparison views via a unique URL.

## 2. Goals

-   Develop a platform to aggregate and display specifications for home espresso machines.
-   Provide powerful filtering and comparison tools to help users make informed purchasing decisions.
-   Create shareable comparison pages to facilitate discussion and recommendations.
-   Monetize through affiliate links.

## 3. User Stories

-   **Discover & Filter:** A user lands on the homepage (`/`), sees a table of machines, uses filters to narrow down the results, and selects two machines to add to a compare tray.
-   **Machine Detail:** A user clicks a machine name, visits its dedicated detail page (`/machines/[id]`), reads detailed specifications, and clicks an affiliate link to an external vendor.
-   **Share Comparison:** A user on a comparison page (`/compare?ids=[id1],[id2]`) copies the URL and sends it to someone else, who can then load the identical side-by-side comparison view.

## 4. Functional Requirements

1.  **Machine Listing:** The system must display all espresso machines in a filterable, sortable table on the main page.
2.  **Filtering:** Users must be able to filter the machine list based on criteria such as:
    -   Brand
    -   Price Range (MSRP)
    -   Boiler Type
    -   PID (Yes/No)
    -   Pump Type
    -   Skill Level
    -   Plumbable (Yes/No)
3.  **Comparison Tray:** Users must be able to select up to two machines to add to a comparison view.
4.  **Side-by-Side Comparison:** The system must generate a dedicated view (`/compare`) that displays the specifications of the two selected machines side-by-side.
5.  **Shareable URLs:** The comparison page URL must be shareable and stateless (e.g., `/compare?ids=a,b`) and render the correct comparison when visited directly.
6.  **Machine Detail Pages:** Each machine must have a unique detail page (`/machines/[id]`) displaying all its specifications from the database.
7.  **Affiliate Links:** Machine detail and comparison pages must display affiliate links for purchasing.

## 5. Non-Goals (Out of Scope for Initial Launch)

-   User accounts and profiles.
-   User-submitted reviews or ratings.
-   Blog content, articles, or buying guides.
-   Comparison of more than two machines at a time.

## 6. Design Considerations

-   **Frontend Framework:** Astro + Svelte for a static/interactive hybrid model.
-   **Styling:** Tailwind CSS, following a utility-first, mobile-first approach.

## 7. Technical Considerations

-   **Database:** Supabase (Postgres).
-   **Data Schema:** A `machines` table will be used with the following structure:
    ```sql
    CREATE TABLE machines (
      id TEXT PRIMARY KEY,
      name TEXT,
      brand TEXT,
      price_msrp NUMERIC,
      boiler TEXT,
      pid BOOLEAN,
      pid_adjustable BOOLEAN,
      pre_infusion TEXT,
      pump TEXT,
      flow_control TEXT,
      opv_adjustable BOOLEAN,
      steam_brew_same BOOLEAN,
      reservoir_ml INTEGER,
      plumbable BOOLEAN,
      dimensions_in TEXT,
      skill_level TEXT,
      asin TEXT,
      affiliate TEXT,
      image_url TEXT
    );
    ```
-   **Future Enhancements (Phase 2):**
    -   Nightly price synchronization using Amazon's Product Advertising (PA-API).
    -   A `prices_live` table to store historical price data.
    -   Sparkline price charts on machine detail pages.
    -   Email alerts for user-subscribed price drops.

## 8. Success Metrics

-   Primary Metric: Click-through rate (CTR) on affiliate links.
-   Secondary Metrics:
    -   Number of comparison pages shared (tracked via analytics on `/compare` page loads with `ids` params).
    -   User engagement: Time on site, pages per session.
    -   Keyword ranking on search engines for relevant terms (e.g., "espresso machine comparison").

## 9. Open Questions

-   What is the definitive source for the initial machine data entry? Will this be a manual process?
-   Are there specific brands or a number of machines we want to launch with? 