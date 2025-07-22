export async function GET() {
  const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
  const supabaseKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;
  
  // Base static pages
  const staticPages = [
    'https://espressopicker.com/',
    'https://espressopicker.com/compare/'
  ];

  let machinePages = [];
  
  // Add some known machine pages as fallback
  const fallbackMachinePages = [
    'https://espressopicker.com/machines/breville-barista-express-impress',
    'https://espressopicker.com/machines/gaggia-classic-pro',
    'https://espressopicker.com/machines/breville-bambino-plus',
    'https://espressopicker.com/machines/rancilio-silvia',
    'https://espressopicker.com/machines/la-pavoni-europiccola'
  ];
  
  if (supabaseUrl && supabaseKey) {
    try {
      // Use direct fetch instead of Supabase client for better Cloudflare compatibility
      const response = await fetch(`${supabaseUrl}/rest/v1/espresso_machines?select=id&id=not.is.null`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json',
        },
      });

      if (response.ok) {
        const machines = await response.json();
        if (machines && Array.isArray(machines)) {
          machinePages = machines.map(machine => `https://espressopicker.com/machines/${machine.id}`);
        }
      } else {
        console.error('Supabase API error:', response.status, response.statusText);
        // Use fallback pages if API fails
        machinePages = fallbackMachinePages;
      }
    } catch (error) {
      console.error('Error fetching machines for sitemap:', error);
      // Use fallback pages if there's an error
      machinePages = fallbackMachinePages;
    }
  } else {
    // Use fallback pages if no environment variables
    machinePages = fallbackMachinePages;
  }

  // Combine all pages
  const allPages = [...staticPages, ...machinePages];

  // Generate sitemap XML
  const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${allPages.map(url => `  <url>
    <loc>${url}</loc>
    <lastmod>${new Date().toISOString()}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>`).join('\n')}
</urlset>`;

  return new Response(sitemap, {
    headers: {
      'Content-Type': 'application/xml',
      'Cache-Control': 'public, max-age=3600', // Cache for 1 hour
    },
  });
} 