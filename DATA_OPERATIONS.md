# Content data

The D1 catalog is generated from source-controlled files:

- `assets/seed/stains.json`
- `assets/seed/fabrics.json`
- `assets/seed/products.json`
- `assets/seed/articles.json`
- `assets/seed/care_symbols.json`
- `Content/stain_solutions.jsonl`

Run `npm run db:seed` to apply the schema and upsert the full catalog. The same catalog files are bundled into Flutter Web and Android builds. If the Worker or D1 is unreachable, the app loads these packaged copies.

Only operators should use a Cloudflare API token for the seed script. Keep `CLOUDFLARE_API_TOKEN` in the shell environment, limit the token to D1 write access, and never place it in Flutter code, `cloudflare.config.ts`, or the repository.

The public Worker endpoint is read-only. It returns catalog records and stain solutions from D1, and the health endpoint reports that AI is disabled. Favorites, ratings, and the demo profile remain in local device storage. Account-based synchronization and a protected editing interface are tracked as future issues.
