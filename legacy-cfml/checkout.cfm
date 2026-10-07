<!---
    checkout.cfm

    Used to check out a trailer (remove it from yard through the gate)
    Required data:
        Trailer number
        Status - UPDATE to 'checked out'
        Date/time checked out
--->

<cfquery name = "counts">
    SELECT
    (SELECT COUNT(*) FROM trailers WHERE status <> 'checked_out') AS on_site,
    (SELECT COUNT(*) FROM locations) AS locations
</cfquery>
<cfquery name = "qTrailers" datasource = "yard">
    SELECT t.*, l.code, l.location_type
    FROM trailers t
    INNER JOIN locations l ON t.location_id=l.id
    WHERE t.status IN ('in_yard', 'at_door')
    ORDER BY l.code
</cfquery>
<cfif structKeyExists(form, "id")>
    <cfquery name = "checkout">
        UPDATE trailers
        SET status = 'checked_out', checked_out_at = now()
        WHERE id = <cfqueryparam value="#form.id#" cfsqltype = "cf_sql_integer"> AND status <> 'checked_out'
    </cfquery>
    <cflocation url = "./index.cfm" addtoken = "false">
</cfif>


<cfoutput>
    <!doctype html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Trailer Checkout (Legacy)</title>
        </head>
        <body>
        <h1>Trailer Checkout Form (Legacy Cold Fusion App)</h1>
        <p>Trailers on site: #counts.on_site# &nbsp;|&nbsp; Locations: #counts.locations#</p>
            <p><a href="/">Go to the modern Node app</a></p>
<form id="check-out-form" method ="post" action="checkout.cfm">
    <label>Gate check-out form</label>
    
    <fieldset>
    <legend>Routing</legend>
    
        <table>
            <tr>
            <th>Check Out</th>
            <th>Trailer</th>
            <th>Carrier</th>
            <th>Location</th>
            <th>Load Status</th>
            <th>Status</th>
            <th>Checked in at</th>
            </tr>
        <cfloop query = "qTrailers">
            <tr>
            <td>
            <input type="radio" name="id" value="#id#" id="#id#" required>
            </td>
            <td>
            <label for="#id#">#code#</label>
            </td>    
            <td>#trailer_number#</td>
            <td>#carrier#</td>
            <td>#code#</td>
            <td>#load_status#</td>
            <td>#status#</td>
            <td>#dateTimeFormat(checked_in_at, "mmm d, h:nn tt")#</td>
            </tr>
        </cfloop>
        </table>
<button type="submit">Check Out Trailer</button>
    </fieldset>
</form>
        <a href= "./index.cfm">Yard Status</a>
        <a href= "./checkin.cfm">Check-In Form</a>
        <a href = "./move.cfm">Move request</a>
        </body>
        </html>
    </cfoutput>