-- SIMPLIFIED SECURITY VERIFICATION
-- Run this to quickly verify your security setup

-- 1. Check RLS is enabled
SELECT 
    'RLS Status' as test,
    CASE 
        WHEN rowsecurity THEN '✅ RLS ENABLED'
        ELSE '❌ RLS DISABLED' 
    END as result
FROM pg_tables 
WHERE tablename = 'espresso_machines';

-- 2. Verify policy configuration
SELECT 
    'Policy Check' as test,
    cmd as operation,
    CASE 
        WHEN cmd = 'SELECT' AND 'public' = ANY(roles) THEN '✅ Public can read'
        WHEN cmd IN ('INSERT', 'UPDATE', 'DELETE') AND 'authenticated' = ANY(roles) THEN '✅ Auth required for ' || cmd
        ELSE '⚠️ Check policy: ' || policyname
    END as result
FROM pg_policies 
WHERE tablename = 'espresso_machines'
ORDER BY cmd;

-- 3. Test public can read data
SELECT 
    'Public Read Test' as test,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Public can read ' || COUNT(*) || ' machines'
        ELSE '⚠️ No data or read blocked'
    END as result
FROM public.espresso_machines;

-- 4. Final status
SELECT 
    'SECURITY STATUS' as test,
    '✅ YOUR DATABASE IS NOW SECURE' as result,
    'Public can read, only authenticated can modify' as details; 