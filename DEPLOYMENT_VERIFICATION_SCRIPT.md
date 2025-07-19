# 🧪 Deployment Verification Script
**Run these tests after deploying to Cloudflare Pages**

## ⚡ Quick 5-Minute Verification

### 1. Basic Site Functionality
```bash
# Test that your site loads
curl -I https://your-site.pages.dev

# Expected: 200 OK status
# Expected: Content-Type: text/html
```

### 2. Security Headers Check
```bash
# Test security headers are present
curl -I https://your-site.pages.dev | grep -E "(X-Frame-Options|X-Content-Type-Options|Strict-Transport-Security)"

# Expected output should include:
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff
# Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

### 3. Database Security Test
```bash
# REPLACE with your actual Supabase URL and anon key
SUPABASE_URL="https://your-project.supabase.co"
ANON_KEY="your-anon-key-here"

# Test 1: Public read should work
curl -X GET "${SUPABASE_URL}/rest/v1/espresso_machines?select=id,name&limit=1" \
  -H "apikey: ${ANON_KEY}" \
  -H "Content-Type: application/json"

# Expected: JSON response with machine data
# Expected: No error messages

# Test 2: Unauthorized write should fail
curl -X POST "${SUPABASE_URL}/rest/v1/espresso_machines" \
  -H "apikey: ${ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"id": "hack-test", "name": "Unauthorized Machine"}' \
  -w "HTTP Status: %{http_code}\n"

# Expected: HTTP Status: 401 or 403 (Unauthorized/Forbidden)
# Expected: Error message about insufficient permissions
```

## 🔒 Comprehensive Security Audit

### Manual Checks in Browser

1. **Open your deployed site** in a new incognito window

2. **Check Console for Errors:**
   - Press F12 → Console tab
   - ✅ No red errors
   - ✅ Machine data loads properly

3. **Test Core Functionality:**
   - ✅ Homepage displays espresso machines
   - ✅ Filtering works
   - ✅ Pagination works
   - ✅ Machine detail pages load
   - ✅ Compare functionality works
   - ✅ Images load properly

4. **Mobile Responsiveness:**
   - Press F12 → Toggle device toolbar
   - ✅ Site works on mobile viewport
   - ✅ Navigation is usable

### Performance Testing

1. **Google PageSpeed Insights:**
   ```
   Visit: https://pagespeed.web.dev/
   Enter your site URL: https://your-site.pages.dev
   
   Target Scores:
   ✅ Performance: 90+
   ✅ Accessibility: 95+
   ✅ Best Practices: 95+
   ✅ SEO: 95+
   ```

2. **Security Headers Test:**
   ```
   Visit: https://securityheaders.com/
   Enter your site URL: https://your-site.pages.dev
   
   Target Score:
   ✅ Grade A or A+
   ```

## 🐛 Common Issues & Solutions

### Issue: Site loads but no machine data
**Check:**
```bash
# Verify environment variables are set correctly
curl https://your-site.pages.dev | grep -o "PUBLIC_SUPABASE_URL"
# Should NOT find the literal text "PUBLIC_SUPABASE_URL" - it should be replaced with actual URL
```
**Fix:** Double-check environment variables in Cloudflare Pages settings

### Issue: Images not loading
**Check:**
```bash
# Test image access directly
curl -I "${SUPABASE_URL}/storage/v1/object/public/espresso-machine-images/test-image.jpg"
# Expected: 200 OK or 404 (not 403 Forbidden)
```
**Fix:** Configure storage bucket policies in Supabase

### Issue: Security headers missing
**Check:** Your `public/_headers` file exists and has correct syntax
**Fix:** Redeploy with the correct `_headers` file

### Issue: CORS errors in console
**Fix:** Update CORS settings in Supabase Dashboard to include your production domain

## ✅ Success Checklist

After running all tests above, confirm:

**Security:**
- [ ] ✅ Security headers present (A+ grade on securityheaders.com)
- [ ] ✅ Database prevents unauthorized writes
- [ ] ✅ Storage bucket allows public reads, blocks unauthorized writes
- [ ] ✅ No service role key exposed to client

**Functionality:**
- [ ] ✅ All pages load correctly
- [ ] ✅ Machine data displays properly
- [ ] ✅ Filtering and pagination work
- [ ] ✅ Images load from Supabase storage
- [ ] ✅ Compare functionality works
- [ ] ✅ Mobile responsive design

**Performance:**
- [ ] ✅ PageSpeed Insights scores 90+
- [ ] ✅ Site loads in < 3 seconds
- [ ] ✅ No console errors

**SEO:**
- [ ] ✅ Meta tags present in page source
- [ ] ✅ robots.txt accessible
- [ ] ✅ Proper heading structure (H1, H2, etc.)

## 🚨 Emergency Actions

### If security test fails:
1. **Immediately:** Check Supabase RLS policies are enabled
2. **Run:** `SIMPLE_SECURITY_CHECK.sql` in Supabase SQL Editor
3. **Verify:** No unauthorized data modifications occurred

### If site is down:
1. **Check:** Cloudflare Pages deployment status
2. **Check:** Build logs for errors
3. **Rollback:** To previous working deployment if needed

### If performance is poor:
1. **Check:** Cloudflare cache settings
2. **Verify:** All assets have proper cache headers
3. **Monitor:** Real User Monitoring in Cloudflare

---

## 📞 Support Resources

- **Cloudflare Pages Docs:** https://developers.cloudflare.com/pages/
- **Supabase RLS Docs:** https://supabase.com/docs/guides/auth/row-level-security
- **Security Headers Guide:** https://securityheaders.com/
- **PageSpeed Insights:** https://pagespeed.web.dev/

---

**🎉 Congratulations!** If all checks pass, your espresso machine comparison site is production-ready with enterprise-grade security! 