# Washed Clean

Washed Clean is a Flutter app for finding stain treatments, caring for fabrics and products, understanding laundry symbols, saving favorites, and rating guides. The same Flutter source builds for web and Android. The web app is served by Cloudflare Workers Static Assets, with a read-only Worker API and Cloudflare D1 database.

## Features

- Search stains, fabrics, and products with fuzzy matching
- View fabric and product guides, stain instructions, and 226 detailed stain solutions
- Browse laundry care symbols and open the camera scan flow
- Save favorites, ratings, and the demo profile in local browser or device storage
- Load bundled content when the D1 API is unavailable
- Open the app in a browser or install it as a PWA

The camera currently displays the existing demo symbol results after taking a photo. Symbol recognition remains a follow-up task. Profile sign-in is also a local demo flow.

## Cloudflare architecture

| Component | Purpose |
| --- | --- |
| Workers Static Assets | Serves the Flutter Web build and SPA routes |
| Cloudflare Worker | Exposes the public, read-only `/api/content` and `/api/health` endpoints |
| D1 | Stores catalog and stain-solution JSON records in the EU jurisdiction |
| Bundled Flutter assets | Provide an offline fallback, including the full stain-solutions JSONL file |

The D1 database is seeded from the files in this repository. The seed contains 278 records: 12 stains, 8 fabrics, 8 products, 5 articles, 19 care-symbol records, and 226 stain solutions.

## Run locally

Install Flutter, Dart, a Node.js version supported by the pinned `cf` CLI release, and the Cloudflare CLI. Then run:

```bash
flutter pub get
npm install
flutter run -d chrome
```

Without a running local Worker, the app uses its bundled JSON and JSONL content.

## Deploy

See [Cloudflare deployment](CLOUDFLARE_DEPLOYMENT.md) for the Worker and D1 setup, content import, and deployment steps. The browser app uses its own origin for the API. Android builds can use the deployed Worker URL with `CLOUDFLARE_API_BASE_URL`.

The Worker is designed for the Cloudflare Workers Free plan. D1 and Worker usage still shares the account's free quotas, so high traffic can reach the daily caps. Static asset requests are free under the current plan. Check the current [Workers limits](https://developers.cloudflare.com/workers/platform/limits/), [D1 pricing and limits](https://developers.cloudflare.com/workers/platform/pricing/#d1), and [Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/) before increasing usage.

## Mobile builds

The Flutter app and Android project remain in place. To connect an Android build to the deployed API, run:

```bash
flutter build apk --release --dart-define=CLOUDFLARE_API_BASE_URL=https://washedclean.felixb-neto.workers.dev
```

The iOS target can be generated and built from this same Flutter app on macOS. User preferences stay on each device until account sync is implemented.

## Deferred improvements

The remaining work is tracked as GitHub issues in the WashedClean repository. It includes real label recognition, account security and cross-device sync, article browsing, content administration, expanded search, localization, and accessibility work.
