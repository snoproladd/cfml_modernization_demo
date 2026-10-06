-- Sample data so the yard isn't empty on first run.
-- All carriers and numbers are made up.

-- 20 yard slots: Y-01 .. Y-20
INSERT INTO locations (code, location_type)
SELECT 'Y-' || lpad(n::text, 2, '0'), 'slot'
FROM generate_series(1, 20) AS n;

-- 8 dock doors: D-01 .. D-08
INSERT INTO locations (code, location_type)
SELECT 'D-' || lpad(n::text, 2, '0'), 'door'
FROM generate_series(1, 8) AS n;

INSERT INTO trailers (trailer_number, carrier, seal_number, load_status, status, location_id, checked_in_at) VALUES
  ('TRL-48213', 'Northline Freight',   'SL-990134', 'loaded', 'in_yard', (SELECT id FROM locations WHERE code = 'Y-01'), now() - interval '5 hours'),
  ('TRL-55102', 'Blue Ridge Carriers', 'SL-771020', 'loaded', 'in_yard', (SELECT id FROM locations WHERE code = 'Y-02'), now() - interval '4 hours'),
  ('TRL-30877', 'Hudson Valley Haul',  NULL,        'empty',  'in_yard', (SELECT id FROM locations WHERE code = 'Y-05'), now() - interval '9 hours'),
  ('TRL-61450', 'Northline Freight',   'SL-990188', 'loaded', 'at_door', (SELECT id FROM locations WHERE code = 'D-03'), now() - interval '2 hours'),
  ('TRL-22941', 'Summit Transport',    'SL-450092', 'loaded', 'in_yard', (SELECT id FROM locations WHERE code = 'Y-07'), now() - interval '90 minutes'),
  ('TRL-70318', 'Blue Ridge Carriers', NULL,        'empty',  'in_yard', (SELECT id FROM locations WHERE code = 'Y-11'), now() - interval '26 hours'),
  ('TRL-18806', 'Summit Transport',    'SL-450117', 'loaded', 'at_door', (SELECT id FROM locations WHERE code = 'D-06'), now() - interval '45 minutes');
