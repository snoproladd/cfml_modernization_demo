// Front-end JavaScript for the modern app. Vanilla JS, no framework,
// matching the stack in the job posting.

async function checkHealth() {
  const el = document.getElementById("status");
  try {
    const res = await fetch("/api/health");
    const data = await res.json();
    el.textContent = `Connected to Postgres. Trailers on site: ${data.trailersOnSite}`;
  } catch (err) {
    el.textContent = "Could not reach the API.";
  }
}

async function open_slots() {
  const el = document.getElementById("trailer_table_checkin_body");
  if (!el) {
    return;
  }
  try {
    const res = await fetch("/api/open_slots");
    const data = await res.json();

    for (let s = 0; s <= data.length - 1; s++) {
      const slot = data[s];
      const tr = document.createElement("tr");

      const rb_cell = document.createElement("td");
      const rb = document.createElement("input");
      rb.type = "radio";
      rb.name = "location_id";
      rb.required = true;
      rb.value = slot.id;
      rb.id = `slot_${slot.id}`;
      rb_cell.appendChild(rb);
      tr.appendChild(rb_cell);

      const code_cell = document.createElement("td");
      const lab = document.createElement("label");
      lab.htmlFor = rb.id;
      lab.textContent = slot.code;
      code_cell.appendChild(lab);
      tr.appendChild(code_cell);

      const type_cell = document.createElement("td");
      type_cell.textContent = slot.location_type;
      tr.appendChild(type_cell);

      el.appendChild(tr);
    }
  } catch (err) {
    el.textContent = "No Slots available";
  }
}

// Yard list: fetch trailers from the API and build the table rows.
async function yardList() {
  const el_h = document.getElementById("trailer_table_head");
  const el_b = document.getElementById("trailer_table_body");
  if (!el_h || !el_b) {
    return;
  }
  try {
    const res = await fetch("/api/trailers");
    const data = await res.json();
    const dataFields = {
      "Trailer Number": "trailer_number",
      Carrier: "carrier",
      Location: "code",
      "Load Status": "load_status",
      Status: "status",
      "Checked in:": "checked_in_at",
    };
    for (let key in dataFields) {
      const th = document.createElement("th");
      th.textContent = key;
      el_h.appendChild(th);
    }

    for (let k = 0; k < data.length; k++) {
      const trailer = data[k];
      const tr = document.createElement("tr");

      for (let label in dataFields) {
        const field = dataFields[label];
        let value = trailer[field];

        if (field === "checked_in_at") {
          value = new Date(value).toLocaleString();
        }

        const td = document.createElement("td");
        td.textContent = value;
        tr.appendChild(td);
      }

      el_b.appendChild(tr);
    }
  } catch (err) {
    el_b.textContent = "No trailers found.";
  }
}

function route_trailer() {
  const form = document.getElementById("checkin");
  if (!form) {
    return;
  }
  const formData = new FormData(form);
  const data = Object.fromEntries(formData);
  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);
    try {
      const response = await fetch("/api/checkin", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      });
      if (response.ok) {
        const result = await response.json();
        window.location.href = "/";
      } else {
        console.error("Server error:", response.status);
      }
    } catch (error) {
      console.error("Network error:", error);
    }
  });
}

async function checkout_trailer() {
  const el = document.getElementById("checkout_table_body");
  const form = document.getElementById("checkout");
  const dataFields = {
    Trailer: "trailer_number",
    Carrier: "carrier",
    Location: "code",
    "Load Status": "load_status",
    Status: "status",
    "Checked in at": "checked_in_at",
  };

  try {
    if (!el || !form) {
      return;
    }

    const res = await fetch("/api/trailers");
    const data = await res.json();

    for (let k = 0; k < data.length; k++) {
      const trailer = data[k];
      const tr = document.createElement("tr");
      const rb_cell = document.createElement("td");
      const rb = document.createElement("input");
      rb.type = "radio";
      rb.name = "id";
      rb.required = true;
      rb.value = trailer.id;
      rb.id = `trailer_${trailer.id}`;
      rb_cell.appendChild(rb);
      tr.appendChild(rb_cell);

      const code_cell = document.createElement("td");
      const lab = document.createElement("label");
      lab.htmlFor = rb.id;
      lab.textContent = trailer.trailer_number;
      code_cell.appendChild(lab);
      tr.appendChild(code_cell);

      for (let label in dataFields) {
        const field = dataFields[label];
        let value = trailer[field];
        if (field === "trailer_number") {
          continue;
        }
        if (field === "checked_in_at") {
          value = new Date(value).toLocaleString();
        }

        const td = document.createElement("td");
        td.textContent = value;
        tr.appendChild(td);
      }

      el.appendChild(tr);
    }

    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      const formData = new FormData(form);
      const body = Object.fromEntries(formData);

      try {
        const response = await fetch("/api/checkout", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body),
        });

        if (response.ok) {
          window.location.href = "/";
        } else {
          const result = await response.json();
          console.error("Server error:", response.status, result.error);
        }
      } catch (err) {
        console.error("Network error:", err);
      }
    });
  } catch (err) {
    console.error(err);
  }
}

checkHealth();
yardList();
open_slots();
route_trailer();
checkout_trailer();
