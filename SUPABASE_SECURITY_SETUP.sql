-- SUPABASE SECURITY SETUP - Row Level Security (RLS) - CORRECTED
-- Run these commands in your Supabase SQL Editor to secure your database

-- STEP 1: Drop existing policies if they exist (prevents "already exists" errors)
DROP POLICY IF EXISTS "Enable read access for all users" ON public.espresso_machines;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.espresso_machines;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.espresso_machines;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.espresso_machines;

-- STEP 2: Enable Row Level Security on the espresso_machines table
ALTER TABLE public.espresso_machines ENABLE ROW LEVEL SECURITY;

-- STEP 3: Create CORRECTED RLS policies for a read-only comparison site

-- Policy 1: Allow PUBLIC read access to all espresso machine data
-- This is safe for a comparison site where machine data should be publicly viewable
CREATE POLICY "Enable read access for all users" ON public.espresso_machines
    FOR SELECT 
    TO public
    USING (true);

-- Policy 2: Restrict INSERT operations to AUTHENTICATED users only
-- This prevents anonymous users from adding fake machine data
CREATE POLICY "Enable insert for authenticated users only" ON public.espresso_machines
    FOR INSERT 
    TO authenticated
    WITH CHECK (true);

-- Policy 3: Restrict UPDATE operations to AUTHENTICATED users only  
-- This prevents anonymous users from modifying machine data
CREATE POLICY "Enable update for authenticated users only" ON public.espresso_machines
    FOR UPDATE 
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy 4: Restrict DELETE operations to AUTHENTICATED users only
-- This prevents anonymous users from deleting machine data
CREATE POLICY "Enable delete for authenticated users only" ON public.espresso_machines
    FOR DELETE 
    TO authenticated
    USING (true);

-- STEP 4: OPTIONAL - For maximum security, disable write operations entirely
-- Uncomment these lines if you want a completely read-only database:
-- DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.espresso_machines;
-- DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.espresso_machines;
-- DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.espresso_machines;

-- STEP 5: Verify RLS is enabled and policies are active
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'espresso_machines';

-- STEP 6: Check that policies are created correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'espresso_machines';

-- STEP 7: Test the security setup
-- This should work (public read access)
SELECT COUNT(*) FROM public.espresso_machines;

-- STEP 8: Storage Security for Images
-- Secure the espresso-machine-images storage bucket
-- Run these in the Supabase Storage policies section:

-- Allow public to read images (for your comparison site)
CREATE POLICY "Public can view images" ON storage.objects
    FOR SELECT 
    TO public
    USING (bucket_id = 'espresso-machine-images');

-- Only authenticated users can upload images
CREATE POLICY "Authenticated users can upload images" ON storage.objects
    FOR INSERT 
    TO authenticated
    WITH CHECK (bucket_id = 'espresso-machine-images');

-- Only authenticated users can update images
CREATE POLICY "Authenticated users can update images" ON storage.objects
    FOR UPDATE 
    TO authenticated
    USING (bucket_id = 'espresso-machine-images');

-- Only authenticated users can delete images
CREATE POLICY "Authenticated users can delete images" ON storage.objects
    FOR DELETE 
    TO authenticated
    USING (bucket_id = 'espresso-machine-images');

-- STEP 9: API Security - Check your API settings
-- In Supabase Dashboard > Authentication > Settings:
-- ✅ Enable "Confirm email" if you add auth later
-- ✅ Set appropriate rate limits
-- ✅ Configure CORS for your domain only

-- STEP 10: Environment Variables Security Check
-- ✅ PUBLIC_SUPABASE_URL - Safe to expose (needed for frontend)
-- ✅ PUBLIC_SUPABASE_ANON_KEY - Safe to expose (has limited permissions)
-- ❌ SUPABASE_SERVICE_ROLE_KEY - NEVER expose to frontend! Only use on server
-- ❌ SUPABASE_URL - Can be same as PUBLIC_SUPABASE_URL

-- SECURITY SUMMARY:
-- ✅ RLS is now ENABLED on espresso_machines table
-- ✅ Public users can READ all machine data (safe for comparison site)
-- ✅ Only authenticated users can INSERT/UPDATE/DELETE data
-- ✅ Anonymous users CANNOT modify your database
-- ✅ Storage bucket is secured for images
-- ✅ Database is now secure against unauthorized modifications

-- IMPORTANT NOTES:
-- 1. Your frontend will continue to work normally for reading data
-- 2. If you need to add/edit machines, you'll need to authenticate first
-- 3. This setup is perfect for a public comparison site with admin-controlled data
-- 4. The service role key should only be used on your server (SSR), never exposed to clients
-- 5. Consider adding audit columns (created_at, updated_at, created_by) for better tracking

-- NEXT STEPS:
-- 1. Run this script in your Supabase SQL Editor
-- 2. Test that your site still works (it should!)
-- 3. Verify policies are correctly applied using STEP 6 query
-- 4. Set up proper authentication if you need to add/edit machines
-- 5. Consider adding rate limiting for API calls 