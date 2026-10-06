// Front-end JavaScript for the modern app. Vanilla JS, no framework,
// matching the stack in the job posting.

async function checkHealth() {
  const el = document.getElementById('status');
  try {
    const res = await fetch('/api/health');
    const data = await res.json();
    el.textContent = `Connected to Postgres. Trailers on site: ${data.trailersOnSite}`;
  } catch (err) {
    el.textContent = 'Could not reach the API.';
  }
}

checkHealth();
yardList();

// TODO (you): load /api/trailers and render the yard list.
async function yardList() {
  const el_h = document.getElementById("trailer_table_head");
  const el_b = document.getElementById("trailer_table_body")

  try{
    const res = await fetch('/api/trailers');
    const data = await res.json();
    const dataFields = {"Trailer Number":"trailer_number", "Carrier":"carrier", "Location":"code", "Load Status":"load_status", "Status":"status","Checked in:":"checked_in_at"}
    for (let key in dataFields){
      const th = document.createElement('th');
      th.textContent = key
      el_h.appendChild(th)  
      }
    let keys = Object.keys(data);
        // One row per trailer
    for (let k = 0; k < data.length; k++) {
      const trailer = data[k];                 // the current trailer object
      const tr = document.createElement('tr');

      // One cell per column, in the same order as the headers
      for (let label in dataFields) {
        const field = dataFields[label];       // e.g. "Carrier" -> "carrier"
        let value = trailer[field];            // brackets: look up the property named by `field`

        if (field === 'checked_in_at') {
          value = new Date(value).toLocaleString();
        }

        const td = document.createElement('td');
        td.textContent = value;
        tr.appendChild(td);                    // cell goes into the row
      }

      el_b.appendChild(tr);                    // finished row goes into the table
    };

    }catch (err){
    
  el_b.textContent = 'No trailers found.';
 }
}
