# Cloudflare deployment

The app uses one Cloudflare Worker to serve the Flutter web build and its read-only content API. The Worker is bound to the `washedclean-content` D1 database in the EU jurisdiction. The database ID and account ID are recorded in `cloudflare.config.ts`.

## Prerequisites

- Node.js 22.23+, 24.22+, or 26.12+ (supported by the pinned `cf` CLI release)
- Flutter SDK with web support
- A Cloudflare account with Workers and D1 access
- The Cloudflare CLI (`cf`) authenticated to the account in `cloudflare.config.ts`
- The Cloudflare Vite plugin configured in `vite.config.ts`

Install the project dependencies and authenticate the CLI:

```bash
npm install
cf auth login
```

## Initialize and seed D1

Create a Cloudflare API token with D1 write access. Set it only in the current shell as `CLOUDFLARE_API_TOKEN`, then run:

```bash
npm run db:seed
```

The script applies the schema in `migrations/0001_create_content_items.sql`, then inserts or updates all 278 source records. It can be run again after content changes. It never deletes existing records.

## Build and deploy

```bash
npm run deploy
```

This builds Flutter Web in release mode, then uses the Cloudflare Vite plugin and `cf deploy` to publish the Worker and assets. The Worker is published at `https://washedclean.felixb-neto.workers.dev`. Its SPA fallback serves Flutter navigation routes such as `/stain/:id` directly.

Check the deployed endpoints:

```text
GET https://washedclean.felixb-neto.workers.dev/api/health
GET https://washedclean.felixb-neto.workers.dev/api/content
```

`/api/content` only accepts reads. Content administration stays in the local import script until authenticated editing is implemented.

## Build the Android app

Pass the public Worker origin as a compile-time value so the mobile app can use the same API:

```bash
flutter build apk --release --dart-define=CLOUDFLARE_API_BASE_URL=https://washedclean.felixb-neto.workers.dev
```

When the value is omitted, the mobile app uses bundled content. No API token or other secret belongs in a Flutter build.

## Free plan usage

Workers Free currently includes 100,000 Worker requests per day. D1 Free currently includes up to 5 million rows read per day, 100,000 rows written per day, and 5 GB storage across the account. The database's API content endpoint reads 278 rows per uncached request. D1 daily quota enforcement can make API requests fail after a cap is reached, while the app falls back to bundled data.

Cloudflare updates plan quotas. Verify the current [Workers limits](https://developers.cloudflare.com/workers/platform/limits/), [D1 pricing](https://developers.cloudflare.com/workers/platform/pricing/#d1), and [Static Assets limits](https://developers.cloudflare.com/workers/static-assets/) before relying on a specific capacity.
