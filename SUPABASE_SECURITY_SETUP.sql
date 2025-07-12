-- SUPABASE SECURITY SETUP - Row Level Security (RLS)
-- Run these commands in your Supabase SQL Editor to secure your database

-- STEP 1: Drop existing policies if they exist (prevents "already exists" errors)
DROP POLICY IF EXISTS "Enable read access for all users" ON public.espresso_machines;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.espresso_machines;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON public.espresso_machines;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON public.espresso_machines;

-- STEP 2: Enable Row Level Security on the espresso_machines table
ALTER TABLE public.espresso_machines ENABLE ROW LEVEL SECURITY;

-- STEP 3: Create RLS policies for different access patterns

-- Policy 1: Allow public read access to all espresso machine data
-- This is safe for a comparison site where machine data should be publicly viewable
CREATE POLICY "Enable read access for all users" ON public.espresso_machines
    FOR SELECT 
    USING (true);

-- Policy 2: Restrict INSERT operations to authenticated users only
-- This prevents anonymous users from adding fake machine data
CREATE POLICY "Enable insert for authenticated users only" ON public.espresso_machines
    FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

-- Policy 3: Restrict UPDATE operations to authenticated users only
-- This prevents anonymous users from modifying machine data
CREATE POLICY "Enable update for authenticated users only" ON public.espresso_machines
    FOR UPDATE 
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy 4: Restrict DELETE operations to authenticated users only
-- This prevents anonymous users from deleting machine data
CREATE POLICY "Enable delete for authenticated users only" ON public.espresso_machines
    FOR DELETE 
    USING (auth.role() = 'authenticated');

-- STEP 4: Verify RLS is enabled and policies are active
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'espresso_machines';

-- STEP 5: Check that policies are created correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'espresso_machines';

-- STEP 6: Test the security setup
-- This should work (public read access)
SELECT COUNT(*) FROM public.espresso_machines;

-- STEP 7: Optional - Create more granular policies if needed

-- Example: If you want to allow only specific roles to modify data
-- CREATE POLICY "Enable admin access" ON public.espresso_machines
--     FOR ALL 
--     USING (auth.jwt() ->> 'role' = 'admin')
--     WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Example: If you want to log who made changes (requires user_id column)
-- ALTER TABLE public.espresso_machines ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);
-- ALTER TABLE public.espresso_machines ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES auth.users(id);

-- CREATE POLICY "Users can only modify their own entries" ON public.espresso_machines
--     FOR UPDATE 
--     USING (created_by = auth.uid())
--     WITH CHECK (updated_by = auth.uid());

-- SECURITY SUMMARY:
-- ✅ RLS is now ENABLED on espresso_machines table
-- ✅ Public users can READ all machine data (safe for comparison site)
-- ✅ Only authenticated users can INSERT/UPDATE/DELETE data
-- ✅ Anonymous users cannot modify your database
-- ✅ Database is now secure against unauthorized modifications

-- IMPORTANT NOTES:
-- 1. Your frontend will continue to work normally for reading data
-- 2. If you need to add/edit machines, you'll need to authenticate first
-- 3. This setup is perfect for a public comparison site with admin-controlled data
-- 4. Consider adding audit columns (created_at, updated_at, created_by) for better tracking 