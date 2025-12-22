# Vac RFC Index

An IETF-style index of Vac-managed RFCs across Waku, Nomos, Codex, and Status. Use the filters below to jump straight to a specification.

<div class="landing-hero">
  <div class="filter-row">
    <input id="rfc-search" type="search" placeholder="Search by number, title, status, project..." aria-label="Search RFCs">
    <div class="chips" id="status-chips">
      <span class="chip active" data-status="all" data-label="All">All</span>
      <span class="chip" data-status="stable" data-label="Stable">Stable</span>
      <span class="chip" data-status="draft" data-label="Draft">Draft</span>
      <span class="chip" data-status="raw" data-label="Raw">Raw</span>
      <span class="chip" data-status="deprecated" data-label="Deprecated">Deprecated</span>
      <span class="chip" data-status="deleted" data-label="Deleted">Deleted</span>
    </div>
  </div>
  <div class="filter-row">
    <div class="chips" id="project-chips">
      <span class="chip active" data-project="all" data-label="All projects">All projects</span>
      <span class="chip" data-project="vac" data-label="Vac">Vac</span>
      <span class="chip" data-project="waku" data-label="Waku">Waku</span>
      <span class="chip" data-project="status" data-label="Status">Status</span>
      <span class="chip" data-project="nomos" data-label="Nomos">Nomos</span>
      <span class="chip" data-project="codex" data-label="Codex">Codex</span>
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

<div class="results-row">
  <div id="results-count" class="results-count">Loading RFC index...</div>
  <div class="results-hint">Click a column to sort</div>
</div>

<div id="rfc-table-container" class="table-wrap"></div>

<noscript>
  <p class="noscript-note">JavaScript is required to load the RFC index table.</p>
</noscript>
