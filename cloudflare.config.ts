import { bindings, defineConfig } from 'cf/config';
import * as entrypoint from './worker/index.js' with { type: 'cf-worker' };

export default defineConfig({
  accountId: '5197cbc92b5db4a7abfaf76c38c6d0c5',
  worker: {
    name: 'washedclean',
    entrypoint,
    compatibilityDate: '2026-11-21',
    assets: {
      directory: './build/web',
      notFoundHandling: 'single-page-application',
      runWorkerFirst: ['/api/*'],
    },
    env: {
      CONTENT_DB: bindings.d1({
        name: 'washedclean-content',
        id: 'cf7cb8cb-0209-4258-a249-bfc7630d68ac',
      }),
    },
    observability: {
      enabled: false,
    },
  },
});
