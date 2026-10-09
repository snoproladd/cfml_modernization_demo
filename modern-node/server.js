const express = require("express");
const path = require("path");
const db = require("./db");

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

app.get("/api/health", async (req, res) => {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS on_site FROM trailers WHERE status <> 'checked_out'`,
  );
  res.json({ ok: true, trailersOnSite: rows[0].on_site });
});

app.get("/api/trailers", async (req, res) => {
  const { rows } = await db.query(
    `SELECT t.*, l.code, l.location_type
    FROM trailers t
    INNER JOIN locations l ON t.location_id=l.id
    WHERE t.status IN ('in_yard', 'at_door')
    ORDER BY l.code`,
  );
  res.json(rows);
});

// GET all slots in yard

app.get("/api/open_spots_all", async (req, res) => {
  const { rows } = await db.query(
    `SELECT id, code, location_type
    FROM locations
    WHERE id NOT IN (
    SELECT location_id
    FROM trailers
    WHERE status <> 'checked_out'
    AND location_id IS NOT NULL
    )
    ORDER BY code`,
  );
  res.json(rows);
});

// GET Open slots for yard assignment
app.get("/api/open_slots", async (req, res) => {
  const { rows } = await db.query(
    `SELECT id, code, location_type
    FROM locations
    WHERE location_type = 'slot'
    AND id NOT IN (
    SELECT location_id
    FROM trailers
    WHERE status <> 'checked_out'
    AND location_id IS NOT NULL
    )
    ORDER BY code`,
  );
  res.json(rows);
});

app.post("/api/checkin", async (req, res) => {
  const { trailer_number, carrier, seal_number, load_status, location_id } =
    req.body;
  try {
    const seal = seal_number?.trim() || null;
    const trailer = trailer_number?.trim();
    const result = await db.query(
      `INSERT INTO trailers (trailer_number, carrier, seal_number, load_status, location_id, checked_in_at)
    VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *`,
      [trailer, carrier, seal, load_status, location_id],
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/api/checkout", async (req, res) => {
  const { id } = req.body;
  try {
    const result = await db.query(
      `UPDATE trailers
          SET status = 'checked_out', checked_out_at = now()
          WHERE id = $1 AND status <> 'checked_out' RETURNING *`,
      [id],
    );
    if (result.rowCount === 0) {
      return res
        .status(404)
        .json({ error: "Trailer not found or already checked out" });
    }
    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/api/move_trailer", async (req, res) => {
  const { trailer_id, to_location_id } = req.body;
  const client = await db.pool.connect();
  try {
    await client.query("BEGIN");
    const trailerLookup = await client.query(
      `SELECT location_id FROM trailers WHERE id = $1`,
      [trailer_id],
    );

    const from_location_id = trailerLookup.rows[0].location_id;
    const dest_lookup = await client.query(
      `SELECT location_type FROM locations WHERE id = $1`,
      [to_location_id],
    );

    const new_location_code = dest_lookup.rows[0].location_type;
    let new_status = "N/A";
    if (new_location_code === "slot") {
      new_status = "in_yard";
    }
    if (new_location_code === "door") {
      new_status = "at_door";
    }
    const insert_move = await client.query(
      `INSERT INTO moves (trailer_id, from_location_id, to_location_id, completed_at)
      VALUES($1, $2, $3, NOW())`,
      [trailer_id, from_location_id, to_location_id],
    );

    const trailer_move_update = await client.query(
      `UPDATE trailers
        SET
          location_id = $1,
          status = $2
        WHERE id = $3
              AND status <> 'checked_out'`,
      [to_location_id, new_status, trailer_id],
    );
    await client.query("COMMIT"); 
        res.json({ ok: true });
  } catch (error) {
    await client.query("ROLLBACK");
    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    client.release(); 
}});
const port = process.env.PORT || 3001;
app.listen(port, () => console.log(`Modern app listening on ${port}`));
