const CONTENT_TYPES = new Set([
  'stains',
  'fabrics',
  'products',
  'articles',
  'care_symbols',
  'stain_solutions',
]);

function jsonResponse(data, status = 200) {
  return Response.json(data, {
    status,
    headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, OPTIONS',
      'access-control-allow-headers': 'Content-Type',
      'cache-control': 'public, max-age=300, stale-while-revalidate=86400',
    },
  });
}

function rawJsonResponse(json, status = 200) {
  return new Response(json, {
    status,
    headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, OPTIONS',
      'access-control-allow-headers': 'Content-Type',
      'cache-control': 'public, max-age=300, stale-while-revalidate=86400',
      'content-type': 'application/json; charset=utf-8',
    },
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname.startsWith('/api/') && request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: {
          'access-control-allow-origin': '*',
          'access-control-allow-methods': 'GET, OPTIONS',
          'access-control-allow-headers': 'Content-Type',
          'access-control-max-age': '86400',
        },
      });
    }

    if (url.pathname === '/api/health') {
      if (request.method !== 'GET') return jsonResponse({ error: 'Method not allowed.' }, 405);
      return jsonResponse({ status: 'ok', aiEnabled: false });
    }

    if (url.pathname !== '/api/content') {
      return jsonResponse({ error: 'Not found.' }, 404);
    }

    if (request.method !== 'GET') {
      return jsonResponse({ error: 'Method not allowed.' }, 405);
    }

    const type = url.searchParams.get('type');
    if (type && !CONTENT_TYPES.has(type)) {
      return jsonResponse({ error: 'Unknown content type.' }, 400);
    }

    try {
      const statement = type
        ? env.CONTENT_DB.prepare(
            `SELECT COALESCE(json_group_array(json_object(
              'type', type,
              'id', id,
              'title', title,
              'data', json(payload)
            )), '[]') AS items
            FROM (
              SELECT type, id, title, payload
              FROM content_items
              WHERE type = ?
              ORDER BY title COLLATE NOCASE
            )`,
          ).bind(type)
        : env.CONTENT_DB.prepare(
            `SELECT COALESCE(json_group_array(json_object(
              'type', type,
              'id', id,
              'title', title,
              'data', json(payload)
            )), '[]') AS items
            FROM (
              SELECT type, id, title, payload
              FROM content_items
              ORDER BY type, title COLLATE NOCASE
            )`,
          );
      const { results } = await statement.all();
      return rawJsonResponse(`{"items":${results[0]?.items ?? '[]'}}`);
    } catch (error) {
      console.error(JSON.stringify({ event: 'content_query_failed', message: String(error) }));
      return jsonResponse({ error: 'Content is temporarily unavailable.' }, 503);
    }
  },
};
