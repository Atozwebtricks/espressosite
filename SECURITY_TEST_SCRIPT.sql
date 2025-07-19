-- SECURITY TEST SCRIPT
-- Run this after applying the corrected RLS policies to verify they work

-- ============================================================================
-- SECURITY VERIFICATION TESTS
-- ============================================================================

-- Test 1: Verify RLS is enabled on the table
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled,
    CASE 
        WHEN rowsecurity THEN '✅ RLS is ENABLED'
        ELSE '❌ RLS is DISABLED - SECURITY RISK!'
    END as status
FROM pg_tables 
WHERE tablename = 'espresso_machines';

-- Test 2: Check all current policies are correctly configured
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd as operation,
    CASE 
        WHEN cmd = 'SELECT' AND 'public' = ANY(roles) THEN '✅ Public can read'
        WHEN cmd IN ('INSERT', 'UPDATE', 'DELETE') AND 'authenticated' = ANY(roles) THEN '✅ Only authenticated can modify'
        ELSE '⚠️ Check policy configuration'
    END as policy_status
FROM pg_policies 
WHERE tablename = 'espresso_machines'
ORDER BY cmd, policyname;

-- Test 3: Verify public can read data (this should work)
SELECT 
    'Test 3: Public Read Access' as test_name,
    COUNT(*) as machine_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Public can read data successfully'
        ELSE '⚠️ No data found or read access blocked'
    END as result
FROM public.espresso_machines;

-- Test 4: Test that policies prevent unauthorized writes
-- These commands should fail with permission denied errors

-- Test 4a: Try to insert without authentication (should fail)
DO $$
BEGIN
    -- This should fail if security is properly configured
    INSERT INTO public.espresso_machines (id, name, brand) 
    VALUES ('security-test-1', 'Test Machine', 'Test Brand');
    
    -- If we get here, security is NOT working
    RAISE EXCEPTION 'SECURITY FAILURE: Unauthenticated INSERT succeeded!';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE '✅ Test 4a PASSED: INSERT correctly blocked for unauthenticated users';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ Test 4a: Unexpected error: %', SQLERRM;
END $$;

-- Test 4b: Try to update without authentication (should fail)
DO $$
BEGIN
    -- This should fail if security is properly configured
    UPDATE public.espresso_machines 
    SET name = 'Hacked Machine' 
    WHERE id = (SELECT id FROM public.espresso_machines LIMIT 1);
    
    -- If we get here, security is NOT working
    RAISE EXCEPTION 'SECURITY FAILURE: Unauthenticated UPDATE succeeded!';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE '✅ Test 4b PASSED: UPDATE correctly blocked for unauthenticated users';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ Test 4b: Unexpected error: %', SQLERRM;
END $$;

-- Test 4c: Try to delete without authentication (should fail)
DO $$
BEGIN
    -- This should fail if security is properly configured
    DELETE FROM public.espresso_machines 
    WHERE id = (SELECT id FROM public.espresso_machines LIMIT 1);
    
    -- If we get here, security is NOT working
    RAISE EXCEPTION 'SECURITY FAILURE: Unauthenticated DELETE succeeded!';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE '✅ Test 4c PASSED: DELETE correctly blocked for unauthenticated users';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️ Test 4c: Unexpected error: %', SQLERRM;
END $$;

-- Test 5: Check for any existing test data that needs cleanup
SELECT 
    'Test 5: Security Test Cleanup' as test_name,
    COUNT(*) as test_records_found,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ No test records found'
        ELSE '⚠️ Found test records that should be cleaned up'
    END as result
FROM public.espresso_machines 
WHERE id LIKE 'security-test-%' OR name LIKE '%Test%' OR brand = 'Test Brand';

-- Test 6: Verify storage bucket policies (if configured)
-- Note: This requires storage policies to be set up first
SELECT 
    'Test 6: Storage Security' as test_name,
    'Check storage policies manually in Supabase Dashboard > Storage > Policies' as instruction,
    'Verify: Public can SELECT, only authenticated can INSERT/UPDATE/DELETE' as expected_result;

-- ============================================================================
-- SUMMARY REPORT
-- ============================================================================

SELECT 
    '🔐 SECURITY TEST SUMMARY' as title,
    'If all tests above show ✅, your security is properly configured' as summary,
    'If any tests show ❌ or ⚠️, review the security setup' as action_needed;

-- ============================================================================
-- QUICK SECURITY HEALTH CHECK
-- ============================================================================

WITH security_check AS (
    SELECT 
        (SELECT rowsecurity FROM pg_tables WHERE tablename = 'espresso_machines') as rls_enabled,
        (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'espresso_machines' AND cmd = 'SELECT' AND 'public' = ANY(roles)) as public_read_policies,
        (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'espresso_machines' AND cmd = 'INSERT' AND 'authenticated' = ANY(roles)) as auth_insert_policies,
        (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'espresso_machines' AND cmd = 'UPDATE' AND 'authenticated' = ANY(roles)) as auth_update_policies,
        (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'espresso_machines' AND cmd = 'DELETE' AND 'authenticated' = ANY(roles)) as auth_delete_policies
)
SELECT 
    'SECURITY HEALTH CHECK' as check_type,
    CASE 
        WHEN rls_enabled AND public_read_policies > 0 AND auth_insert_policies > 0 AND auth_update_policies > 0 AND auth_delete_policies > 0 
        THEN '✅ SECURITY IS PROPERLY CONFIGURED'
        ELSE '❌ SECURITY ISSUES DETECTED - REVIEW POLICIES'
    END as status,
    CASE 
        WHEN NOT rls_enabled THEN 'RLS is not enabled on espresso_machines table'
        WHEN public_read_policies = 0 THEN 'Missing public read policy'
        WHEN auth_insert_policies = 0 THEN 'Missing authenticated insert policy'
        WHEN auth_update_policies = 0 THEN 'Missing authenticated update policy'
        WHEN auth_delete_policies = 0 THEN 'Missing authenticated delete policy'
        ELSE 'All policies are in place'
    END as details
FROM security_check;

-- ============================================================================
-- MANUAL VERIFICATION STEPS
-- ============================================================================

SELECT 
    'MANUAL VERIFICATION' as step_type,
    'Test your application at ' || current_setting('server_version') as instruction_1,
    'Verify that your website still loads and displays machine data' as instruction_2,
    'Try to access the API directly with curl (should work for GET, fail for POST/PUT/DELETE)' as instruction_3,
    'Check Supabase Dashboard > Authentication > Settings for rate limits and CORS' as instruction_4;

-- ============================================================================
-- FINAL NOTES
-- ============================================================================

SELECT 
    '📋 FINAL SECURITY CHECKLIST' as title,
    'Run this test script after applying security fixes' as step_1,
    'All tests should show ✅ for proper security' as step_2,
    'Test your application to ensure it still works' as step_3,
    'Configure storage policies if you have an espresso-machine-images bucket' as step_4,
    'Set up rate limiting and CORS in Supabase Dashboard' as step_5,
    'Your database should now be secure against unauthorized modifications' as final_note; 