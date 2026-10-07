<!---
    move.cfm

    Use to move trailers from one yard slot to loading door or vice versa
    Caveats:
        Must be available free door or yard slot
        If free door/yard slot not available, submit move request for trailer occupying door
--->

<cfif structKeyExists(form, "trailer_id") AND structKeyExists(form, "to_location_id")>
    <!--- Form submitted: record the move and relocate the trailer together --->
    <cftransaction>
        <!--- TODO: INSERT INTO moves (trailer_id, from_location_id, to_location_id, completed_at) --->

        <!--- TODO: UPDATE trailers SET location_id = ..., status = ... WHERE id = ... --->
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

<!--- TODO: qOpenLocations - every empty slot AND door (id, code, location_type) --->

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
                <!--- TODO: loop qOpenLocations - radio name="to_location_id", value = location id --->
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
