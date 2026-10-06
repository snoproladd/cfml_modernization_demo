// Modern app: localhost:3000  (Node listens on 3001 inside Docker;
// the gateway publishes it on 3000.)
const express = require('express');
const path = require('path');
const db = require('./db');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Health check: proves Node can reach the same database as the CFML app.
app.get('/api/health', async (req, res) => {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS on_site FROM trailers WHERE status <> 'checked_out'`
  );
  res.json({ ok: true, trailersOnSite: rows[0].on_site });
});

// YOUR TODO LIST (modern side), migrating one legacy page at a time:
//   GET  /api/trailers              - same data as legacy index.cfm

app.get('/api/trailers', async (req, res) =>{
  const {rows} = await db.query(
    `SELECT t.*, l.code, l.location_type
    FROM trailers t
    INNER JOIN locations l ON t.location_id=l.id
    WHERE t.status IN ('in_yard', 'at_door')
    ORDER BY l.code`
  );
  res.json(rows)
}
)
//   POST /api/trailers              - gate check-in (replaces checkin.cfm)
//   POST /api/moves                 - request a move (replaces move.cfm)
//   POST /api/trailers/:id/checkout - check out (replaces checkout.cfm)

const port = process.env.PORT || 3001;
app.listen(port, () => console.log(`Modern app listening on ${port}`));
