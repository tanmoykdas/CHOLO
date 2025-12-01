# Google Maps Setup Instructions

## Current Status
✅ API Key: `AIzaSyAI0yrn57RtOq6y1xtJ5ogBhvG763zfoc0`
✅ Android: Configured in `AndroidManifest.xml`
✅ iOS: Configured in `AppDelegate.swift`
✅ Web: Configured in `index.html`

## Why Map Shows Blank (Beige Background)?

The blank map with only markers visible means the Google Maps tiles aren't loading. This happens because:

1. **API Key not activated** in Google Cloud Console
2. **Billing not set up** (Google Maps requires a billing account, but has $200 free tier/month)
3. **Required APIs not enabled**

## How to Fix (Required Steps):

### Step 1: Go to Google Cloud Console
1. Visit: https://console.cloud.google.com
2. Select your project: **cholo-c9f90**
3. If you don't have a project, create one

### Step 2: Enable Billing
1. Go to **Billing** in the left menu
2. Link a billing account (required even for free tier)
3. Google provides **$200 free credit per month**
4. You won't be charged unless you exceed the free tier

### Step 3: Enable Required APIs
1. Go to **APIs & Services** → **Library**
2. Search and enable these APIs:
   - ✅ **Maps SDK for Android** (REQUIRED)
   - ✅ **Maps SDK for iOS** (for iOS builds)
   - ✅ **Maps JavaScript API** (for web)
   - ✅ **Geocoding API** (for address lookup)
   - ✅ **Geolocation API** (for current location)
   - ⚠️ **Places API** (optional, for autocomplete)

### Step 4: Configure API Key
1. Go to **APIs & Services** → **Credentials**
2. Find your API key: `AIzaSyAI0yrn57RtOq6y1xtJ5ogBhvG763zfoc0`
3. Click on it to edit
4. **Application restrictions**: 
   - For testing: Set to **None**
   - For production: Set to **Android apps** and add your package: `com.cholo.cholo`
5. **API restrictions**:
   - Select **Restrict key**
   - Check all the APIs you enabled above
6. Click **Save**

### Step 5: Test
1. Wait 5-10 minutes for changes to propagate
2. Rebuild your app: `flutter run`
3. Try selecting location from map
4. Map tiles should now load properly

## Verification

After setup, you should see:
- ✅ Full map with streets, buildings, labels
- ✅ Ability to zoom and pan
- ✅ Red marker showing selected location
- ✅ Address appearing in the bottom sheet

If still blank:
- Check Google Cloud Console → **APIs & Services** → **Dashboard** for quota/error messages
- Ensure billing is active
- Wait a few more minutes (changes can take time)

## Cost (Free Tier)

Google Maps provides **$200 free credit per month**, which covers:
- ~28,000 map loads
- ~40,000 geocoding requests
- More than enough for development and small-scale apps

You'll only be charged if you exceed these limits.

## Alternative (If Can't Set Up Billing)

If you can't set up billing, you can:
1. Use OpenStreetMap (free, no API key)
2. Use a text-based location picker
3. Let me know and I'll implement an alternative

## Need Help?

If you encounter issues:
1. Check the Flutter console for error messages
2. Check Google Cloud Console → **APIs & Services** → **Dashboard** for API errors
3. Verify billing is active
4. Ensure all required APIs are enabled
