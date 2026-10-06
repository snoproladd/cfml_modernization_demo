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

// TODO (you): load /api/trailers and render the yard list.
