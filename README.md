# Yard Check-In: CFML to JavaScript Migration Demo

A small yard management app built twice: once in **ColdFusion (CFML)** as the legacy system, and once in **Node.js / Express with vanilla JavaScript** as its replacement. Both run side by side against the **same Postgres database**, behind a router that sends each URL to the old or new app. This is the "strangler fig" pattern: migrate one feature at a time, without a risky big-bang rewrite.

## The domain

Trailers arrive at a distribution center gate, get checked in, and wait in a numbered yard slot. When the warehouse is ready, a spotter moves the trailer to a dock door. When it's done, the trailer is checked out and its slot is freed.

## Run it

Requires Docker Desktop.

```
docker compose up
```

| URL | What it is |
|---|---|
| http://localhost:3000 | Modern Node/Express app |
| http://localhost:3000/legacy/ | Legacy ColdFusion app (Lucee) |
| http://localhost:8888 | Lucee directly (debugging) |
| localhost:5433 | Postgres (user `yard`, password `yard_dev_password`) |
| http://localhost:8080 | Adminer database browser (System: PostgreSQL, Server: `db`, user/password/database as above) |

The first start downloads images and seeds the database, so give it a minute.

## Project layout

```
docker-compose.yml     all five services (gateway, lucee, node, db, adminer)
gateway/nginx.conf     routes /legacy/* to Lucee, everything else to Node
db/init/               schema + sample data (runs on first start only)
legacy-cfml/           ColdFusion app (Lucee serves this folder)
modern-node/           Node/Express API + vanilla JS front end
```

## Migration progress

| Feature | Legacy (CFML) | Modern (JS) |
|---|---|---|
| Yard list | [x] | [x] |
| Gate check-in | [x] | [x] |
| Move request (slot to door) | [x] | [ ] |
| Check-out | [x] | [x] |

## Migration approach

_To be written: what moved first and why, how both apps share data safely, and how routes are switched over in the gateway._

## Troubleshooting

- **Changed the SQL in `db/init` and nothing happened?** Init scripts only run on an empty database. Reset with `docker compose down -v`, then `docker compose up`.
- **CFML change not showing?** Restart Lucee: `docker compose restart lucee`.
- **Links broken under /legacy/?** Use relative links in CFML (`checkin.cfm`, not `/checkin.cfm`).
