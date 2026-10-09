<!---
    move.cfm

    Use to move trailers from one yard slot to loading door or vice versa
    Caveats:
        Must be available free door or yard slot
        If free door/yard slot not available, submit move request for trailer occupying door
--->

<cfif structKeyExists(form, "trailer_id") AND structKeyExists(form, "to_location_id")>
    <cftransaction>
        <cfquery name="qTrailer">
            SELECT location_id
            FROM trailers
            WHERE id = <cfqueryparam value="#form.trailer_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery name="qDest">
            SELECT location_type
            FROM locations
            WHERE id = <cfqueryparam value="#form.to_location_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif qDest.location_type EQ "door">
            <cfset newStatus = "at_door">
        <cfelse>
            <cfset newStatus = "in_yard">
        </cfif>

        <cfquery>
            INSERT INTO moves (trailer_id, from_location_id, to_location_id, completed_at)
            VALUES (
                <cfqueryparam value="#form.trailer_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#qTrailer.location_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#form.to_location_id#" cfsqltype="cf_sql_integer">,
                now()
            )
        </cfquery>

        <cfquery>
            UPDATE trailers
            SET
                location_id = <cfqueryparam value="#form.to_location_id#" cfsqltype="cf_sql_integer">,
                status = <cfqueryparam value="#newStatus#" cfsqltype="cf_sql_varchar" maxlength="12">
            WHERE id = <cfqueryparam value="#form.trailer_id#" cfsqltype="cf_sql_integer">
              AND status <> 'checked_out'
        </cfquery>
    </cftransaction>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<cfquery name="counts">
    SELECT
    (SELECT COUNT(*) FROM trailers WHERE status <> 'checked_out') AS on_site,
    (SELECT COUNT(*) FROM locations) AS locations
</cfquery>

<cfquery name="qTrailers">
    SELECT t.*, l.code, l.location_type
    FROM trailers t
    INNER JOIN locations l ON t.location_id = l.id
    WHERE t.status IN ('in_yard', 'at_door')
    ORDER BY l.code
</cfquery>
<cfquery name= "qOpenLocations">
    SELECT id, code, location_type
    FROM locations
    WHERE id NOT IN (
    SELECT location_id
    FROM trailers
    WHERE status <> 'checked_out'
    AND location_id IS NOT NULL
    )
    ORDER BY location_type, code
</cfquery>

<cfoutput>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trailer Move (Legacy)</title>
</head>
<body>
    <h1>Trailer Move Request (Legacy ColdFusion App)</h1>
    <p>Trailers on site: #counts.on_site# &nbsp;|&nbsp; Locations: #counts.locations#</p>
    <p><a href="/">Go to the modern Node app</a></p>

    <form id="move-form" method="post" action="move.cfm">
        <fieldset>
            <legend>Trailer to move</legend>
            <table>
                <tr>
                    <th></th>
                    <th>Trailer</th>
                    <th>Carrier</th>
                    <th>Current Location</th>
                    <th>Status</th>
                </tr>
                <cfloop query="qTrailers">
                    <tr>
                        <td><input type="radio" name="trailer_id" value="#id#" id="trailer_#id#" required></td>
                        <td><label for="trailer_#id#">#trailer_number#</label></td>
                        <td>#carrier#</td>
                        <td>#code#</td>
                        <td>#status#</td>
                    </tr>
                </cfloop>
            </table>
        </fieldset>

        <fieldset>
            <legend>Destination</legend>
            <table>
                <tr>
                    <th></th>
                    <th>Location</th>
                    <th>Type</th>
                </tr>
                <cfloop query="qOpenLocations">
                    <tr>
                        <td><input type="radio" name="to_location_id" value="#id#" id="loc_#id#" required></td>
                        <td><label for="loc_#id#">#code#</label></td>
                        <td>#location_type#</td>
                    </tr>
                </cfloop>
                </table>
        </fieldset>

        <button type="submit">Move Trailer</button>
    </form>

    <p>
        <a href="index.cfm">Yard Status</a>
        <a href="checkin.cfm">Check-In Form</a>
        <a href="checkout.cfm">Checkout Form</a>
    </p>
</body>
</html>
</cfoutput>
