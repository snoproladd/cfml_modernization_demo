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

// Yard list: same query as legacy index.cfm, returned as JSON.
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
// GET Open slots for yard assignment
app.get('/api/open_slots', async (req,res) =>{
  const {rows} = await db.query(
    `SELECT id, code, location_type
    FROM locations
    WHERE location_type = 'slot'
    AND id NOT IN (
    SELECT location_id
    FROM trailers
    WHERE status <> 'checked_out'
    AND location_id IS NOT NULL
    )
    ORDER BY code`
  );
  res.json(rows)
})
//   POST /api/trailers              - gate check-in (replaces checkin.cfm)

app.post('/api/checkin', async (req, res) =>{
  const {trailer_number, carrier, seal_number, load_status, location_id} = req.body
  try{
    const seal = seal_number?.trim() || null;
    const trailer = trailer_number?.trim()
    const result = await db.query(
    `INSERT INTO trailers (trailer_number, carrier, seal_number, load_status, location_id, checked_in_at)
    VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *`,
    [trailer, carrier, seal, load_status, location_id]
  );
  res.status(201).json(result.rows[0])
}catch(error){
  console.error(error);
  res.status(500).json({ error: "Internal server error"})
}})
//   POST /api/moves                 - request a move (replaces move.cfm)
//   POST /api/trailers/:id/checkout - check out (replaces checkout.cfm)

const port = process.env.PORT || 3001;
app.listen(port, () => console.log(`Modern app listening on ${port}`));
