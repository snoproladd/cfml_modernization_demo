<cfif structKeyExists(form, "location_id")>
    <!--- the form was submitted: do the INSERT here, then redirect --->
    <cfquery>
        INSERT INTO trailers (trailer_number, carrier, seal_number, load_status, location_id, checked_in_at)
        VALUES (
            <cfqueryparam value="#form.trailer_id_in#" cfsqltype="cf_sql_varchar" maxlength="20"></cfqueryparam>
            <cfqueryparam value="#form.carrier_in#" cfsqltype="cf_sql_varchar" maxlength="60"></cfqueryparam>
            <cfqueryparam value = "#form.seal_number_in#" cfsqltype = "cf_sql_varchar" maxlength = "30" null = "#NOT len(trim(form.seal_number))#">
            
        )
    </cfquery>
<cfelse>
    <!--- first visit: nothing to do, just show the form below --->
</cfif>

<cfquery name = "counts">
    SELECT
    (SELECT COUNT(*) FROM trailers WHERE status <> 'checked_out') AS on_site,
    (SELECT COUNT(*) FROM locations) AS locations
</cfquery>

<cfquery name = "open_spots" datasource = "yard">
    SELECT id, code, location_type
    FROM locations
    WHERE location_type = 'slot'
    AND id NOT IN (
    SELECT location_id
    FROM trailers
    WHERE status <> 'checked_out'
    AND location_id IS NOT NULL
    )
    ORDER BY code;
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
    <form id="check-in-form" method ="post" action="checkin.cfm">
    <label>Gate check-in form</label>
    <fieldset>
    <legend>Trailer Information</legend>
    <input type="text" name="trailer_id_in" placeholder="Trailer ID" maxlength=20 required />
    <input type = "text" name = "carrier_in" placeholder="Carrier" maxlength = 60 required />
    <input type = "text" name = "seal_number_in" placeholder="Seal  Number" maxlength = 30 />
    <select name="empty_full">
    <option value="empty">Empty</option>
    <option value="full">Full</option>
    <option value="partial">Partial</option>
    </select>
    </fieldset>
    <fieldset>
    <legend>Routing</legend>
    <table>
    <tr>
    <th></th>
    <th>Open Slot</th>
    <th>Slot Type</th>
    </tr>
    <cfloop query = "open_spots">
        <tr>
        <td>
        <input type="radio" name="location_id" value="
        #id#
        " id="slot_
        #id#
        " required>
        </td>
        <td>
        <label for="slot_
        #id#
        ">
        #code#
        </label>
        </td>
        <td>#location_type#</td>
        </tr>
    </cfloop></table>
    <button type="submit">Route Trailer</button>
    
    </fieldset>
    </form>
    <a href= "./index.cfm">Yard status</a>
    <a href = "./move.cfm">Move request</a>
    <a href="./checkout">Checkout form</a>
    </body>
    </html>
</cfoutput>