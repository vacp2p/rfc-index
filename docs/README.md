# Vac RFC Index

An IETF-style index of Vac-managed RFCs across Waku, Nomos, Codex, and Status. Use the filters below to jump straight to a specification.

<div class="landing-hero">
  <div class="filter-row">
    <input id="rfc-search" type="search" placeholder="Search by number, title, status, project…" aria-label="Search RFCs">
    <div class="chips" id="status-chips">
      <span class="chip active" data-status="all">All</span>
      <span class="chip" data-status="stable">Stable</span>
      <span class="chip" data-status="draft">Draft</span>
      <span class="chip" data-status="raw">Raw</span>
      <span class="chip" data-status="deprecated">Deprecated</span>
      <span class="chip" data-status="deleted">Deleted</span>
    </div>
  </div>
  <div class="filter-row">
    <div class="chips" id="project-chips">
      <span class="chip active" data-project="all">All projects</span>
      <span class="chip" data-project="vac">Vac</span>
      <span class="chip" data-project="waku">Waku</span>
      <span class="chip" data-project="status">Status</span>
      <span class="chip" data-project="nomos">Nomos</span>
      <span class="chip" data-project="codex">Codex</span>
    </div>
  </div>
  <div class="quick-links">
    <a href="./vac/1/coss.html">1/COSS (Process)</a>
    <a href="./vac/README.html">Vac index</a>
    <a href="./waku/README.html">Waku index</a>
    <a href="./status/README.html">Status index</a>
    <a href="./nomos/README.html">Nomos index</a>
    <a href="./codex/README.html">Codex index</a>
  </div>
</div>

<div id="rfc-table-container"></div>

<script>
let rfcData = [];
const container = document.getElementById('rfc-table-container');

const table = document.createElement('table');
table.className = 'rfc-table';
table.innerHTML = `
  <thead>
    <tr>
      <th style="width: 10%">RFC</th>
      <th style="width: 40%">Title</th>
      <th style="width: 15%">Project</th>
      <th style="width: 15%">Status</th>
      <th style="width: 20%">Category</th>
    </tr>
</thead>
  <tbody></tbody>
`;
container.appendChild(table);

let statusFilter = 'all';
let projectFilter = 'all';

function badge(status) {
  const cls = `badge status-${status.toLowerCase().split('/')[0]}`;
  return `<span class="${cls}">${status}</span>`;
}

function render() {
  const tbody = table.querySelector('tbody');
  const query = (document.getElementById('rfc-search').value || '').toLowerCase();
  tbody.innerHTML = '';

  const filtered = rfcData.filter(item => {
    const statusOk = statusFilter === 'all' || item.status.toLowerCase().startsWith(statusFilter);
    const projectOk = projectFilter === 'all' || item.project === projectFilter;
    const text = `${item.slug} ${item.title} ${item.project} ${item.status} ${item.category}`.toLowerCase();
    const textOk = !query || text.includes(query);
    return statusOk && projectOk && textOk;
  });

  filtered.forEach(item => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><a href="./${item.path}">${item.slug}</a></td>
      <td>${item.title}</td>
      <td>${item.project}</td>
      <td>${badge(item.status)}</td>
      <td>${item.category}</td>
    `;
    tbody.appendChild(tr);
  });
}

document.getElementById('rfc-search').addEventListener('input', render);

document.getElementById('status-chips').addEventListener('click', (e) => {
  if (!e.target.dataset.status) return;
  statusFilter = e.target.dataset.status;
  document.querySelectorAll('#status-chips .chip').forEach(ch => ch.classList.toggle('active', ch.dataset.status === statusFilter));
  render();
});

document.getElementById('project-chips').addEventListener('click', (e) => {
  if (!e.target.dataset.project) return;
  projectFilter = e.target.dataset.project;
  document.querySelectorAll('#project-chips .chip').forEach(ch => ch.classList.toggle('active', ch.dataset.project === projectFilter));
  render();
});

function setStatus(text) {
  let statusEl = document.getElementById('table-status');
  if (!statusEl) {
    statusEl = document.createElement('div');
    statusEl.id = 'table-status';
    statusEl.style.margin = '0.4rem 0';
    container.prepend(statusEl);
  }
  statusEl.textContent = text;
}

setStatus('Loading index…');
fetch('./rfc-index.json')
  .then(resp => {
    if (!resp.ok) throw new Error(resp.statusText);
    return resp.json();
  })
  .then(data => {
    rfcData = data.filter(item => item.slug !== 'XX');
    setStatus(`${rfcData.length} RFCs loaded`);
    render();
  })
  .catch(err => {
    console.error(err);
    setStatus('Failed to load RFC index. Please reload.');
  });
</script>
