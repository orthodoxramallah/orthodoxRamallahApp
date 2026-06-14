# Remote Media Setup

## Goal
Enable your app to load audio, video, and PDF files from a public JSON catalog without Firebase.

## 1. Prepare your media files
You can use Dropbox to host your files:
- Upload each audio, video, and PDF file to Dropbox.
- Copy the share link.
- Convert it to a direct link by changing `dl=0` to `dl=1`.

Example:
- share link: `https://www.dropbox.com/s/abcd1234efgh/audio1.mp3?dl=0`
- direct link: `https://www.dropbox.com/s/abcd1234efgh/audio1.mp3?dl=1`

## 2. Create `media_catalog.json`
Use this format:

```json
{
  "audio": [
    {
      "id": "audio-1",
      "title": "ترنيمة القداس",
      "description": "جوقة الكنيسة",
      "path": "https://www.dropbox.com/s/abcd1234efgh/audio1.mp3?dl=1",
      "thumbnail": "https://www.dropbox.com/s/abcd1234efgh/audio1-cover.jpg?dl=1"
    }
  ],
  "video": [
    {
      "id": "video-1",
      "title": "تراتيل عيد الفصح",
      "description": "جوقة الكنيسة في عيد الفصح",
      "path": "https://www.dropbox.com/s/abcd1234efgh/video1.mp4?dl=1",
      "thumbnail": "https://www.dropbox.com/s/abcd1234efgh/video1-thumb.jpg?dl=1"
    }
  ],
  "books": [
    {
      "id": "book-1",
      "title": "كتاب الصلاة اليومية",
      "author": "الأب يوحنا",
      "coverUrl": "https://www.dropbox.com/s/abcd1234efgh/book1-cover.jpg?dl=1",
      "pdfUrl": "https://www.dropbox.com/s/abcd1234efgh/book1.pdf?dl=1"
    }
  ]
}
```

## 3. Host the JSON file publicly
You can use one of these options:

### Option A: GitHub (simple)
1. Create a GitHub repository.
2. Commit `media_catalog.json` to the repo.
3. Use a raw GitHub URL:
   `https://raw.githubusercontent.com/<user>/<repo>/main/media_catalog.json`

### Option B: Netlify / Cloudflare Pages
1. Create a new site.
2. Upload `media_catalog.json`.
3. Use the published URL.

### Option C: GitHub Pages
1. Create a repo.
2. Put `media_catalog.json` in the `docs/` folder.
3. Enable GitHub Pages.
4. Use the generated URL.

## 4. Update your app
In `lib/services/media_service.dart`, set:

```dart
static const String _remoteCatalogUrl = 'https://your-public-url/media_catalog.json';
```

Then run:

```bash
flutter pub get
```

## 5. What happens next
- Your app will try to fetch the remote JSON first.
- If the remote URL is unavailable, it will use the local `assets/data/media_catalog.json` fallback.
- To add new media later, just update the JSON and file links.

## 6. Important note
If your app has already been published with this remote JSON logic, you do not need to publish again after changing the JSON file. Only media links and the JSON content are updated.
