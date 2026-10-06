-- Yard Check-In schema
-- Runs automatically the first time the db container starts.
-- To re-run after changes:  docker compose down -v  then  docker compose up

-- Places a trailer can be: parking slots in the yard, and dock doors on the building.
CREATE TABLE locations (
    id            SERIAL PRIMARY KEY,
    code          VARCHAR(10)  NOT NULL UNIQUE,          -- e.g. 'Y-01', 'D-12'
    location_type VARCHAR(10)  NOT NULL CHECK (location_type IN ('slot', 'door'))
);

-- One row per trailer visit, from gate check-in to gate check-out.
CREATE TABLE trailers (
    id              SERIAL PRIMARY KEY,
    trailer_number  VARCHAR(20)  NOT NULL,
    carrier         VARCHAR(60)  NOT NULL,
    seal_number     VARCHAR(30),
    load_status     VARCHAR(10)  NOT NULL CHECK (load_status IN ('loaded', 'empty')),
    status          VARCHAR(12)  NOT NULL DEFAULT 'in_yard'
                    CHECK (status IN ('in_yard', 'at_door', 'checked_out')),
    location_id     INTEGER      REFERENCES locations(id),
    checked_in_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    checked_out_at  TIMESTAMPTZ
);

-- Only one trailer may occupy a location at a time (while still on site).
CREATE UNIQUE INDEX one_trailer_per_location
    ON trailers (location_id)
    WHERE status <> 'checked_out';

-- Spotter move requests: "take trailer X from slot Y-04 to door D-12".
CREATE TABLE moves (
    id                SERIAL PRIMARY KEY,
    trailer_id        INTEGER      NOT NULL REFERENCES trailers(id),
    from_location_id  INTEGER      REFERENCES locations(id),
    to_location_id    INTEGER      NOT NULL REFERENCES locations(id),
    requested_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    completed_at      TIMESTAMPTZ
);
