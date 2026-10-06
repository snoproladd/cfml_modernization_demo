// Shared Postgres connection pool. Settings come from docker-compose.yml.
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

// Always pass values as parameters: query('... WHERE id = $1', [id])
// This is the Node equivalent of <cfqueryparam>.
module.exports = {
  query: (text, params) => pool.query(text, params),
};
