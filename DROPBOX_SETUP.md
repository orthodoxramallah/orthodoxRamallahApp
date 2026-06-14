## Setup Dropbox for Asset Hosting

### Step 1: Organize Your Assets in Dropbox

1. Create a folder in Dropbox: `orthodox_church_ramallah_assets` (or similar)
2. Inside, create subfolders:
   - `prayers/` → Upload all PDF files (1.pdf through 9.pdf)
   - `images/` → Upload saint images (optional)

### Step 2: Create Shareable Links

1. Right-click the `orthodox_church_ramallah_assets` folder
2. Select "Share" or "Get link"
3. Copy the link (format: `https://www.dropbox.com/s/YOUR_FOLDER_ID/...`)

### Step 3: Extract and Configure Folder ID

From the link `https://www.dropbox.com/s/abc123xyz/orthodox_church_ramallah_assets`, extract:
- **Folder ID**: `abc123xyz`

### Step 4: Update asset_cache_service.dart

In `lib/services/asset_cache_service.dart`, replace:
```dart
static const String _dropboxFolderId = 'YOUR_DROPBOX_FOLDER_ID';
```

With your actual ID:
```dart
static const String _dropboxFolderId = 'abc123xyz';
```

### Step 5: Test

- Build and run your app
- On first launch, assets will download automatically
- Subsequent launches use cached versions

### Direct Download URL Format

Dropbox requires `?dl=1` parameter for direct downloads:
```
https://www.dropbox.com/s/abc123xyz/prayers/1.pdf?dl=0  (preview)
https://dl.dropboxusercontent.com/s/abc123xyz/prayers/1.pdf?dl=1  (download)
```

The service automatically handles this conversion.

### Troubleshooting

- **Link not shareable**: Right-click → Share → Toggle "Anyone with the link"
- **404 errors**: Verify folder ID is correct and files exist
- **Slow downloads**: Consider using a CDN alternative (Firebase Storage, AWS S3, etc.)

### Alternative Hosting Options

If Dropbox is too slow, consider:
- **Firebase Storage** (recommended, fastest)
- **AWS S3**
- **Cloudinary** (good for images)
- **GitHub Releases** (for PDFs only)
