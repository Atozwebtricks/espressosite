import { createClient } from '@supabase/supabase-js';

export async function GET() {
  const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
  const supabaseKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;
  
  // Base static pages
  const staticPages = [
    'https://espressopicker.com/',
    'https://espressopicker.com/compare/'
  ];

  let machinePages = [];
  
  if (supabaseUrl && supabaseKey) {
    try {
      const supabase = createClient(supabaseUrl, supabaseKey);
      const { data: machines, error } = await supabase
        .from('espresso_machines')
        .select('id')
        .not('id', 'is', null);

      if (!error && machines) {
        machinePages = machines.map(machine => `https://espressopicker.com/machines/${machine.id}`);
      }
    } catch (error) {
      console.error('Error fetching machines for sitemap:', error);
    }
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
    },
  });
} 