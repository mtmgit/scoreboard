CREATE TABLE IF NOT EXISTS assets (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  price REAL NOT NULL,
  category TEXT,
  location TEXT DEFAULT 'SMZ Roswell Lot',
  vin_stock TEXT,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE VIRTUAL TABLE IF NOT EXISTS inventory_fts USING fts5(
  id,
  title,
  category,
  vin_stock,
  location,
  tokenize = 'porter ascii'
);

CREATE TABLE IF NOT EXISTS micro_telemetry (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_phone TEXT,
  match_id TEXT,
  decision TEXT,
  pref_order TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
