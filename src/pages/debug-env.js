export async function GET() {
  const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
  const supabaseKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;
  
  const debugInfo = {
    hasSupabaseUrl: !!supabaseUrl,
    hasSupabaseKey: !!supabaseKey,
    supabaseUrlLength: supabaseUrl ? supabaseUrl.length : 0,
    supabaseKeyLength: supabaseKey ? supabaseKey.length : 0,
    envKeys: Object.keys(import.meta.env).filter(key => key.includes('SUPABASE')),
    timestamp: new Date().toISOString()
  };

  return new Response(JSON.stringify(debugInfo, null, 2), {
    headers: {
      'Content-Type': 'application/json',
    },
  });
} 