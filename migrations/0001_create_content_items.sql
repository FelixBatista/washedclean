CREATE TABLE IF NOT EXISTS content_items (
  type TEXT NOT NULL CHECK (type IN (
    'stains',
    'fabrics',
    'products',
    'articles',
    'care_symbols',
    'stain_solutions'
  )),
  id TEXT NOT NULL,
  title TEXT NOT NULL,
  payload TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (type, id)
) WITHOUT ROWID;

CREATE INDEX IF NOT EXISTS content_items_type_title
  ON content_items (type, title COLLATE NOCASE);
