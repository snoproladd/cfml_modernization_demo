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

<cfquery name="qTrailers" datasource="yard">
    SELECT t.*, l.code, l.location_type
    FROM trailers t
    INNER JOIN locations l ON t.location_id=l.id
    WHERE t.status IN ('in_yard', 'at_door')
    ORDER BY l.code
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
    <table>
        <tr>
            <th>Trailer</th>
            <th>Carrier</th>
            <th>Location</th>
            <th>Load Status</th>
            <th>Status</th>
            <th>Checked in at</th>
        </tr>
        <cfloop query="qTrailers">
            <tr>
                <td>#trailer_number#</td>
                <td>#carrier#</td>
                <td>#code#</td>
                <td>#load_status#</td>
                <td>#status#</td>
                <td>#dateTimeFormat(checked_in_at, "mmm d, h:nn tt")#</td>
            </tr>
        </cfloop>
    </table>
</body>
</html>
</cfoutput>
