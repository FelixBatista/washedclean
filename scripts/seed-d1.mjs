import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const accountId = process.env.CLOUDFLARE_ACCOUNT_ID ??
  '5197cbc92b5db4a7abfaf76c38c6d0c5';
const databaseId = process.env.CLOUDFLARE_D1_DATABASE_ID ??
  'cf7cb8cb-0209-4258-a249-bfc7630d68ac';
const apiToken = process.env.CLOUDFLARE_API_TOKEN;
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const endpoint = `https://api.cloudflare.com/client/v4/accounts/${accountId}/d1/database/${databaseId}/query`;

if (!apiToken) {
  throw new Error('Set CLOUDFLARE_API_TOKEN before seeding the D1 database.');
}

async function readJsonFile(filePath) {
  const contents = await readFile(path.join(root, filePath), 'utf8');
  return JSON.parse(contents);
}

function solutionId(title) {
  return title
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '_')
    .replace(/_+/g, '_')
    .trim();
}

function makeRecord(type, data) {
  const title = data.name ?? data.title ?? data.id;
  return {
    sql: `INSERT INTO content_items (type, id, title, payload) VALUES (?, ?, ?, ?) ON CONFLICT(type, id) DO UPDATE SET title = excluded.title, payload = excluded.payload, updated_at = CURRENT_TIMESTAMP`,
    params: [type, data.id, title, JSON.stringify(data)],
  };
}

async function callD1(batch) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${apiToken}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ batch }),
  });
  const result = await response.json();

  if (!response.ok || !result.success) {
    const details = result.errors?.map(({ message }) => message).join('; ');
    throw new Error(`D1 request failed (${response.status}): ${details || 'Unknown error.'}`);
  }

  return result;
}

const migration = await readFile(
  path.join(root, 'migrations', '0001_create_content_items.sql'),
  'utf8',
);
await callD1([{ sql: migration, params: [] }]);

const catalogFiles = [
  ['stains', 'assets/seed/stains.json'],
  ['fabrics', 'assets/seed/fabrics.json'],
  ['products', 'assets/seed/products.json'],
  ['articles', 'assets/seed/articles.json'],
  ['care_symbols', 'assets/seed/care_symbols.json'],
];

const records = [];
for (const [type, filePath] of catalogFiles) {
  const catalog = await readJsonFile(filePath);
  records.push(...catalog.map((data) => makeRecord(type, data)));
}

const solutionsFile = await readFile(
  path.join(root, 'Content', 'stain_solutions.jsonl'),
  'utf8',
);
for (const line of solutionsFile.split(/\r?\n/)) {
  if (!line.trim()) continue;
  const solution = JSON.parse(line);
  const data = { ...solution, id: solution.id ?? solutionId(solution.title) };
  records.push(makeRecord('stain_solutions', data));
}

const batchSize = 50;
for (let start = 0; start < records.length; start += batchSize) {
  await callD1(records.slice(start, start + batchSize));
  const completed = Math.min(start + batchSize, records.length);
  console.log(`Loaded ${completed} of ${records.length} records.`);
}

console.log(`D1 content import completed with ${records.length} records.`);
