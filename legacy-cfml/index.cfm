<!---
    Legacy app home page: localhost:3000/legacy/

    This file only proves Lucee can reach the database.
    Replace it with the yard list once that works.

    YOUR TODO LIST (legacy side):
      1. index.cfm    - list trailers on site with their location (JOIN trailers + locations)
      2. checkin.cfm  - gate check-in form; INSERT using <cfqueryparam> for every value
      3. move.cfm     - request a move from a slot to a door
      4. checkout.cfm - check a trailer out and free its location

    Use RELATIVE links (href="checkin.cfm"), because the gateway serves
    this app under /legacy/.
--->

<cfquery name="counts">
    SELECT
        (SELECT COUNT(*) FROM trailers WHERE status <> 'checked_out') AS on_site,
        (SELECT COUNT(*) FROM locations)                             AS locations
</cfquery>

<cfoutput>
<!doctype html>
<html>
<head><title>Yard Check-In (Legacy CFML)</title></head>
<body>
    <h1>Yard Check-In: legacy ColdFusion app</h1>
    <p>Lucee #server.lucee.version# is connected to Postgres.</p>
    <p>Trailers on site: #counts.on_site# &nbsp;|&nbsp; Locations: #counts.locations#</p>
    <p><a href="/">Go to the modern app</a></p>
</body>
</html>
</cfoutput>
