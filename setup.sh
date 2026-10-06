#!/usr/bin/env bash

echo "🚀 Building partsagain.com Scoreboard directly inside $(pwd)..."

# Create required directories in current root
mkdir -p public/.well-known
mkdir -p functions/api/webhooks

# 1. Configuration file
cat << 'EOF' > wrangler.toml
name = "partsagain-scoreboard"
pages_build_output_dir = "public"
compatibility_date = "2024-01-01"

[[d1_databases]]
binding = "DB"
database_name = "partsagain_db"
database_id = "YOUR_D1_DATABASE_ID_HERE"
EOF

# 2. Database Schema (SQLite + FTS5 Zero-FLOP Search)
cat << 'EOF' > schema.sql
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
EOF

# 3. Native Web Push Service Worker
cat << 'EOF' > public/sw.js
self.addEventListener('push', (e) => {
  const data = e.data ? e.data.json() : { title: 'SMZ Vehicle Match', body: 'New vehicle match available at partsagain.com' };
  e.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icon.png',
      data: { url: data.url || '/' }
    })
  );
});

self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  e.waitUntil(clients.openWindow(e.notification.data.url || '/'));
});
EOF

# 4. Clean White Frontend Interface
cat << 'EOF' > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>partsagain.com | SMZ Micro-Action Portal</title>
  <style>
    :root {
      --bg: #f8fafc;
      --card: #ffffff;
      --text: #0f172a;
      --subtext: #64748b;
      --border: #e2e8f0;
      --green: #16a34a;
      --green-bg: #f0fdf4;
      --blue: #2563eb;
      --blue-bg: #eff6ff;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: var(--bg);
      color: var(--text);
      margin: 0;
      padding: 16px 12px;
      display: flex;
      justify-content: center;
    }

    .container { width: 100%; max-width: 440px; }

    .card {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 18px;
      margin-bottom: 14px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.02);
    }

    .dealer-banner {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 10px;
      border-bottom: 1px dashed var(--border);
      margin-bottom: 12px;
    }

    .dealer-name { font-size: 14px; font-weight: 800; color: var(--blue); }
    .dealer-loc { font-size: 11px; color: var(--subtext); }

    .header-row { display: flex; justify-content: space-between; align-items: flex-start; }
    .title { font-size: 18px; font-weight: 800; margin: 0 0 4px 0; }
    .price { font-size: 22px; font-weight: 800; color: var(--green); }

    .decision-grid {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 8px;
      margin: 16px 0;
    }

    .btn-decide {
      background: var(--card);
      border: 2px solid var(--border);
      border-radius: 10px;
      padding: 12px 0;
      font-size: 20px;
      cursor: pointer;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 2px;
    }

    .btn-decide span { font-size: 10px; font-weight: 700; color: var(--subtext); text-transform: uppercase; }

    .btn-checkout {
      display: block;
      width: 100%;
      text-align: center;
      background: var(--green);
      color: #ffffff;
      text-decoration: none;
      font-weight: 800;
      padding: 14px 0;
      border-radius: 10px;
      font-size: 15px;
      margin-top: 10px;
      box-shadow: 0 4px 10px rgba(22, 163, 74, 0.2);
    }

    .payout-btn {
      display: block;
      width: 100%;
      text-align: center;
      background: #008CFF;
      color: #ffffff;
      text-decoration: none;
      font-weight: 700;
      padding: 12px 0;
      border-radius: 10px;
      margin-top: 8px;
      font-size: 13px;
    }

    .payout-btn.zelle { background: #7414CA; }

    .pref-list { list-style: none; padding: 0; margin: 0; }
    .pref-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: var(--bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 10px 12px;
      margin-bottom: 6px;
      font-size: 13px;
      font-weight: 600;
    }

    .drag-handle { cursor: grab; color: var(--subtext); }

    @media print {
      .decision-grid, .btn-checkout, .payout-btn, .drag-handle { display: none !important; }
      body { background: #fff; padding: 0; }
      .card { border: 1px solid #000; box-shadow: none; }
    }
  </style>
</head>
<body>

  <div class="container">

    <div class="card">
      <div class="dealer-banner">
        <div>
          <div class="dealer-name">SMZ Auto Import</div>
          <div class="dealer-loc">10775 Houze Rd, Roswell, GA</div>
        </div>
        <span style="font-size:11px; font-weight:700; background:var(--green-bg); color:var(--green); padding:3px 8px; border-radius:10px;">96% Match</span>
      </div>

      <div class="header-row">
        <div>
          <h1 class="title">2022 Cadillac Escalade</h1>
          <div style="font-size:12px; color:var(--subtext);">Luxury Trim • 6.2L V8</div>
        </div>
        <div class="price">$62,500</div>
      </div>

      <div class="decision-grid">
        <button class="btn-decide" onclick="decide('up')">👍<span>Lock</span></button>
        <button class="btn-decide" onclick="decide('hold')">↔️<span>Unsure</span></button>
        <button class="btn-decide" onclick="decide('down')">👎<span>Pass</span></button>
      </div>

      <a id="checkout-link" href="https://partsagain.com/cart/401293810:1?attributes[salesperson]=%2B17705550199&checkout=true" class="btn-checkout">
        ⚡ Lock Vehicle ($500 Deposit)
      </a>
      <button onclick="window.print()" style="background:none; border:none; color:var(--blue); font-size:12px; font-weight:600; cursor:pointer; width:100%; margin-top:10px; text-decoration:underline;">Print / Save Spec Sheet PDF</button>
    </div>

    <div class="card">
      <div style="font-weight:800; font-size:14px; margin-bottom:4px;">Referral Wallet ($500.00)</div>
      <div style="font-size:11px; color:var(--subtext); margin-bottom:8px;">Launches native app on phone. Zero fees.</div>
      
      <a href="venmo://paycharge?txn=pay&recipients=SalespersonTag&amount=500.00&note=SMZ%20Referral%20Payout" class="payout-btn">
        Pay via Venmo App
      </a>
      <a href="https://www.zellepay.com" target="_blank" class="payout-btn zelle">
        Open Zelle Payout
      </a>
    </div>

    <div class="card">
      <div style="font-weight:800; font-size:14px; margin-bottom:8px;">Preference Ranking</div>
      <ul id="pref-list" class="pref-list">
        <li class="pref-item" draggable="true" data-pref="body"><span>1. Body Style: SUV</span><span class="drag-handle">&#x2630;</span></li>
        <li class="pref-item" draggable="true" data-pref="price"><span>2. Price: Under $75,000</span><span class="drag-handle">&#x2630;</span></li>
        <li class="pref-item" draggable="true" data-pref="location"><span>3. Location: Roswell, GA</span><span class="drag-handle">&#x2630;</span></li>
      </ul>
    </div>

  </div>

  <script>
    const userPhone = new URLSearchParams(window.location.search).get('p') || "+17705550199";

    async function decide(choice) {
      await fetch('/api/telemetry', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ decision: choice, phone: userPhone, timestamp: Date.now() })
      });
    }

    const list = document.getElementById('pref-list');
    let dragged = null;
    list.addEventListener('dragstart', e => { dragged = e.target.closest('.pref-item'); });
    list.addEventListener('dragover', e => {
      e.preventDefault();
      const target = e.target.closest('.pref-item');
      if (target && target !== dragged) {
        const rect = target.getBoundingClientRect();
        if (e.clientY > rect.top + rect.height / 2) target.after(dragged);
        else target.before(dragged);
      }
    });
    list.addEventListener('dragend', () => {
      const order = Array.from(list.children).map(i => i.dataset.pref);
      fetch('/api/telemetry', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pref_order: JSON.stringify(order), phone: userPhone })
      });
    });
  </script>
</body>
</html>
EOF

# 5. Search Endpoint
cat << 'EOF' > functions/api/search.js
export async function onRequestGet(context) {
  const url = new URL(context.request.url);
  const q = url.searchParams.get("q") || "";

  if (!q) {
    const { results } = await context.env.DB.prepare("SELECT * FROM assets ORDER BY updated_at DESC LIMIT 10").all();
    return Response.json(results);
  }

  const { results } = await context.env.DB.prepare(`
    SELECT a.* FROM assets a
    JOIN inventory_fts f ON a.id = f.id
    WHERE inventory_fts MATCH ?1
    ORDER BY rank
    LIMIT 10
  `).bind(q).all();

  return Response.json(results);
}
EOF

# 6. Shopify Sync Endpoint
cat << 'EOF' > functions/api/webhooks/shopify.js
export async function onRequestPost(context) {
  try {
    const payload = await context.request.json();
    const id = String(payload.id);
    const title = payload.title;
    const price = parseFloat(payload.variants?.[0]?.price || 0);

    await context.env.DB.prepare(`
      INSERT INTO assets (id, title, price)
      VALUES (?1, ?2, ?3)
      ON CONFLICT(id) DO UPDATE SET title = excluded.title, price = excluded.price;
    `).bind(id, title, price).run();

    await context.env.DB.prepare(`
      INSERT INTO inventory_fts (id, title) VALUES (?1, ?2);
    `).bind(id, title).run();

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
}
EOF

# 7. Telemetry Endpoint
cat << 'EOF' > functions/api/telemetry.js
export async function onRequestPost(context) {
  try {
    const { decision, pref_order, phone } = await context.request.json();
    await context.env.DB.prepare(`
      INSERT INTO micro_telemetry (user_phone, decision, pref_order)
      VALUES (?1, ?2, ?3)
    `).bind(phone || 'anonymous', decision || null, pref_order || null).run();

    return Response.json({ success: true });
  } catch (err) {
    return Response.json({ error: err.message }), { status: 500 });
  }
}
EOF

# 8. Apple Merchant Verification File Placeholder
touch public/.well-known/apple-developer-merchantid-domain-association

echo "✅ Setup script completed inside $(pwd)!"
