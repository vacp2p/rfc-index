(() => {
  function linkMenuTitle() {
    const menuTitle = document.querySelector(".menu-title");
    if (!menuTitle || menuTitle.dataset.linked === "true") {
      return;
    }

    const existingLink = menuTitle.closest("a");
    if (existingLink) {
      menuTitle.dataset.linked = "true";
      return;
    }

    const root = (typeof path_to_root !== "undefined" && path_to_root) ? path_to_root : "";
    const link = document.createElement("a");
    link.href = `${root}index.html`;
    link.className = "menu-title-link";
    link.setAttribute("aria-label", "Back to home");

    const parent = menuTitle.parentNode;
    parent.replaceChild(link, menuTitle);
    link.appendChild(menuTitle);
    menuTitle.dataset.linked = "true";
  }

  function onReady(fn) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", fn, { once: true });
    } else {
      fn();
    }
  }

  onReady(linkMenuTitle);

  onReady(() => {
    const printLink = document.querySelector("a[href$='print.html']");
    if (!printLink) return;
    printLink.addEventListener("click", (event) => {
      event.preventDefault();
      window.print();
    });
  });

  function addTopNav() {
    const menuBar = document.querySelector("#mdbook-menu-bar, #menu-bar");
    if (!menuBar || menuBar.querySelector(".site-nav")) return;

    const root = (typeof path_to_root !== "undefined" && path_to_root) ? path_to_root : "";
    const nav = document.createElement("nav");
    nav.className = "site-nav";
    nav.setAttribute("aria-label", "Primary");
    nav.innerHTML = `
      <a class="nav-link" href="${root}index.html">Home</a>
      <details class="nav-dropdown">
        <summary class="nav-link">Projects</summary>
        <div class="nav-menu">
          <a href="${root}vac/index.html">Vac</a>
          <a href="${root}waku/index.html">Waku</a>
          <a href="${root}status/index.html">Status</a>
          <a href="${root}nomos/index.html">Nomos</a>
          <a href="${root}codex/index.html">Codex</a>
        </div>
      </details>
      <button class="nav-link back-to-top-link" type="button">Back to top</button>
      <a class="nav-link" href="${root}about.html">About</a>
    `;

    const rightButtons = menuBar.querySelector(".right-buttons");
    if (rightButtons) {
      menuBar.insertBefore(nav, rightButtons);
    } else {
      menuBar.appendChild(nav);
    }

    document.addEventListener("click", (event) => {
      if (!nav.contains(event.target)) {
        nav.querySelectorAll("details[open]").forEach((detail) => detail.removeAttribute("open"));
      }
    });

    const backToTop = nav.querySelector(".back-to-top-link");
    if (backToTop) {
      backToTop.addEventListener("click", () => {
        window.scrollTo({ top: 0, behavior: "smooth" });
      });
    }
  }

  function addFooter() {
    if (document.querySelector(".site-footer")) return;
    const page = document.querySelector(".page");
    if (!page) return;

    const footer = document.createElement("footer");
    footer.className = "site-footer";
    footer.innerHTML = `
      <a href="https://vac.dev">Vac</a>
      <span class="footer-sep">·</span>
      <a href="https://www.ietf.org">IETF</a>
      <span class="footer-sep">·</span>
      <a href="https://github.com/vacp2p/rfc-index">GitHub</a>
    `;
    page.appendChild(footer);
  }

  function enhanceRfcHeader() {
    const main = document.querySelector("#mdbook-content main, #content main");
    if (!main || main.querySelector(".rfc-header")) return;

    const h1 = main.querySelector("h1");
    if (!h1) return;

    let cursor = h1.nextElementSibling;
    while (cursor && cursor.tagName === "DIV" && cursor.classList.contains("table-wrapper") === false) {
      if (cursor.textContent.trim() !== "") break;
      cursor = cursor.nextElementSibling;
    }

    let table = null;
    let wrapper = null;
    if (cursor && cursor.classList.contains("table-wrapper")) {
      wrapper = cursor;
      table = cursor.querySelector("table");
    } else if (cursor && cursor.tagName === "TABLE") {
      table = cursor;
    }

    if (!table) return;
    const headerCell = table.querySelector("th");
    if (!headerCell || headerCell.textContent.trim().toLowerCase() !== "field") return;

    const meta = {};
    table.querySelectorAll("tbody tr").forEach((row) => {
      const keyCell = row.querySelector("td, th");
      const valCell = row.querySelectorAll("td, th")[1];
      if (!keyCell || !valCell) return;
      const key = keyCell.textContent.trim().toLowerCase();
      const value = valCell.textContent.trim();
      if (key) meta[key] = value;
    });

    const header = document.createElement("div");
    header.className = "rfc-header";

    const badges = document.createElement("div");
    badges.className = "rfc-badges";

    if (meta.status) {
      const status = meta.status.toLowerCase().split("/")[0].replace(/\s+/g, "-");
      const badge = document.createElement("span");
      badge.className = `badge status-${status}`;
      badge.textContent = meta.status;
      badges.appendChild(badge);
    }

    if (meta.category && meta.category.toLowerCase() !== "unspecified") {
      const category = meta.category.toLowerCase();
      let cls = "category-other";
      if (category.includes("best current practice") || category.includes("bcp")) {
        cls = "category-bcp";
      } else if (category.includes("standards")) {
        cls = "category-standards";
      } else if (category.includes("informational")) {
        cls = "category-informational";
      } else if (category.includes("experimental")) {
        cls = "category-experimental";
      }
      const badge = document.createElement("span");
      badge.className = `badge ${cls}`;
      badge.textContent = meta.category;
      badges.appendChild(badge);
    }

    if (badges.children.length) {
      header.appendChild(badges);
    }

    table.classList.add("rfc-meta-table");
    if (wrapper) {
      wrapper.classList.add("rfc-meta-table-wrapper");
      main.insertBefore(header, wrapper);
      header.appendChild(wrapper);
    } else {
      main.insertBefore(header, table);
      header.appendChild(table);
    }
  }

  function getSectionInfo(item) {
    const direct = item.querySelector(":scope > ol.section");
    if (direct) {
      return { section: direct };
    }

    const sibling = item.nextElementSibling;
    if (sibling && sibling.tagName === "LI") {
      const siblingSection = sibling.querySelector(":scope > ol.section");
      if (siblingSection) {
        return { section: siblingSection };
      }
    }

    return null;
  }

  function initSidebarCollapsible(root) {
    if (!root) return;
    const items = root.querySelectorAll("li.chapter-item");
    items.forEach((item) => {
      const sectionInfo = getSectionInfo(item);
      const link = item.querySelector(":scope > a, :scope > .chapter-link-wrapper > a");
      if (!sectionInfo || !link) return;

      if (!link.querySelector(".section-toggle")) {
        const toggle = document.createElement("span");
        toggle.className = "section-toggle";
        toggle.setAttribute("role", "button");
        toggle.setAttribute("aria-label", "Toggle section");
        toggle.addEventListener("click", (event) => {
          event.preventDefault();
          event.stopPropagation();
          item.classList.toggle("expanded");
        });
        link.prepend(toggle);
      }

      if (item.dataset.collapsibleInit !== "true") {
        const hasActive = link.classList.contains("active");
        const hasActiveInSection = !!sectionInfo.section.querySelector(".active");
        if (hasActive || hasActiveInSection) {
          item.classList.add("expanded");
        } else {
          item.classList.remove("expanded");
        }
        item.dataset.collapsibleInit = "true";
      }
    });
  }

  function bindSidebarCollapsible() {
    const sidebar = document.querySelector("#mdbook-sidebar .sidebar-scrollbox")
      || document.querySelector("#sidebar .sidebar-scrollbox");
    if (sidebar) {
      initSidebarCollapsible(sidebar);
    }

    const iframe = document.querySelector(".sidebar-iframe-outer");
    if (iframe) {
      const onLoad = () => {
        try {
          initSidebarCollapsible(iframe.contentDocument);
        } catch (e) {
          // ignore access errors
        }
      };
      iframe.addEventListener("load", onLoad);
      onLoad();
    }
  }

  function observeSidebar() {
    const target = document.querySelector("#mdbook-sidebar") || document.querySelector("#sidebar");
    if (!target) return;
    const observer = new MutationObserver(() => bindSidebarCollapsible());
    observer.observe(target, { childList: true, subtree: true });
    setTimeout(() => observer.disconnect(), 1500);
  }

  onReady(() => {
    addTopNav();
    addFooter();
    enhanceRfcHeader();
    bindSidebarCollapsible();
    // toc.js may inject the sidebar after load
    setTimeout(bindSidebarCollapsible, 100);
    observeSidebar();
  });

  const searchInput = document.getElementById("rfc-search");
  const resultsCount = document.getElementById("results-count");
  const tableContainer = document.getElementById("rfc-table-container");

  if (!searchInput || !resultsCount || !tableContainer) {
    return;
  }

  const rootPrefix = (typeof path_to_root !== "undefined" && path_to_root) ? path_to_root : "";
  const projectScope = tableContainer.dataset.project || "";

  let rfcData = [];
  const statusOrder = { stable: 0, draft: 1, raw: 2, deprecated: 3, deleted: 4, unknown: 5 };
  const statusLabels = {
    stable: "Stable",
    draft: "Draft",
    raw: "Raw",
    deprecated: "Deprecated",
    deleted: "Deleted",
    unknown: "Unknown"
  };
  const projectLabels = {
    vac: "Vac",
    waku: "Waku",
    status: "Status",
    nomos: "Nomos",
    codex: "Codex"
  };
  const headers = [
    { key: "slug", label: "RFC", width: "10%" },
    { key: "title", label: "Title", width: "34%" },
    { key: "project", label: "Project", width: "12%" },
    { key: "status", label: "Status", width: "14%" },
    { key: "category", label: "Category", width: "18%" },
    { key: "updated", label: "Updated", width: "12%" }
  ];

  let statusFilter = "all";
  let projectFilter = "all";
  let dateFilter = "all";
  let sortKey = "slug";
  let sortDir = "asc";

  const table = document.createElement("table");
  table.className = "rfc-table";

  const thead = document.createElement("thead");
  const headRow = document.createElement("tr");
  const headerCells = {};

  headers.forEach((header) => {
    const th = document.createElement("th");
    th.textContent = header.label;
    th.dataset.sort = header.key;
    th.dataset.label = header.label;
    if (header.width) {
      th.style.width = header.width;
    }
    th.addEventListener("click", () => {
      if (sortKey === header.key) {
        sortDir = sortDir === "asc" ? "desc" : "asc";
      } else {
        sortKey = header.key;
        sortDir = "asc";
      }
      render();
    });
    headRow.appendChild(th);
    headerCells[header.key] = th;
  });
  thead.appendChild(headRow);
  table.appendChild(thead);

  const tbody = document.createElement("tbody");
  table.appendChild(tbody);
  tableContainer.appendChild(table);

  function normalizeStatus(status) {
    return (status || "unknown").toString().toLowerCase().split("/")[0];
  }

  function formatStatus(status) {
    const key = normalizeStatus(status);
    return statusLabels[key] || status;
  }

  function formatProject(project) {
    return projectLabels[project] || project;
  }

  function formatCategory(category) {
    if (!category) return "unspecified";
    return category;
  }

  function updateHeaderIndicators() {
    Object.keys(headerCells).forEach((key) => {
      const th = headerCells[key];
      const label = th.dataset.label || "";
      if (key === sortKey) {
        th.classList.add("sorted");
        th.textContent = `${label} ${sortDir === "asc" ? "^" : "v"}`;
      } else {
        th.classList.remove("sorted");
        th.textContent = label;
      }
    });
  }

  function updateResultsCount(count, total) {
    if (total === 0) {
      resultsCount.textContent = "No RFCs found.";
      return;
    }
    if (dateFilter === "latest") {
      resultsCount.textContent = `Showing the ${count} most recently updated RFCs.`;
      return;
    }
    if (dateFilter === "last90") {
      resultsCount.textContent = `Showing ${count} RFCs updated in the last 90 days.`;
      return;
    }
    resultsCount.textContent = `Showing ${count} of ${total} RFCs`;
  }

  function updateChipGroup(containerId, dataAttr, counts, total) {
    document.querySelectorAll(`#${containerId} .chip`).forEach((chip) => {
      const key = chip.dataset[dataAttr];
      const label = chip.dataset.label || chip.textContent;
      if (chip.dataset.count === "false") {
        chip.textContent = label;
        return;
      }
      const count = key === "all" ? total : (counts[key] || 0);
      chip.textContent = `${label} (${count})`;
    });
  }

  function updateChipCounts() {
    const statusCounts = {};
    const projectCounts = {};
    let last90Count = 0;
    let datedCount = 0;

    rfcData.forEach((item) => {
      const statusKey = normalizeStatus(item.status);
      statusCounts[statusKey] = (statusCounts[statusKey] || 0) + 1;
      projectCounts[item.project] = (projectCounts[item.project] || 0) + 1;
      if (parseDate(item.updated)) {
        datedCount += 1;
        if (isWithinDays(item.updated, 90)) {
          last90Count += 1;
        }
      }
    });

    updateChipGroup("status-chips", "status", statusCounts, rfcData.length);
    updateChipGroup("project-chips", "project", projectCounts, rfcData.length);
    updateChipGroup(
      "date-chips",
      "date",
      { latest: Math.min(20, datedCount), last90: last90Count },
      rfcData.length
    );
  }

  function parseDate(value) {
    if (!value) return null;
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return null;
    return date;
  }

  function isWithinDays(value, days) {
    const date = parseDate(value);
    if (!date) return false;
    const now = new Date();
    const diffMs = now - date;
    return diffMs >= 0 && diffMs <= days * 24 * 60 * 60 * 1000;
  }

  function passesDateFilter(item) {
    if (dateFilter === "all") return true;
    if (dateFilter === "last90") return isWithinDays(item.updated, 90);
    if (dateFilter === "latest") return true;
    return true;
  }

  function compareItems(a, b) {
    if (sortKey === "status") {
      const aKey = normalizeStatus(a.status);
      const bKey = normalizeStatus(b.status);
      return (statusOrder[aKey] ?? 99) - (statusOrder[bKey] ?? 99);
    }

    if (sortKey === "updated") {
      const aDate = parseDate(a.updated);
      const bDate = parseDate(b.updated);
      if (!aDate && !bDate) return 0;
      if (!aDate) return 1;
      if (!bDate) return -1;
      return aDate - bDate;
    }

    if (sortKey === "slug") {
      const aNum = parseInt(a.slug, 10);
      const bNum = parseInt(b.slug, 10);
      const aIsNum = !isNaN(aNum);
      const bIsNum = !isNaN(bNum);
      if (aIsNum && bIsNum) return aNum - bNum;
      if (aIsNum && !bIsNum) return -1;
      if (!aIsNum && bIsNum) return 1;
    }

    const aVal = (a[sortKey] || "").toString().toLowerCase();
    const bVal = (b[sortKey] || "").toString().toLowerCase();
    return aVal.localeCompare(bVal, undefined, { numeric: true, sensitivity: "base" });
  }

  function sortItems(items) {
    const sorted = [...items].sort(compareItems);
    if (sortDir === "desc") sorted.reverse();
    return sorted;
  }

  function render() {
    const query = (searchInput.value || "").toLowerCase();
    let filtered = rfcData.filter((item) => {
      const statusOk = statusFilter === "all" || normalizeStatus(item.status) === statusFilter;
      const projectOk = projectFilter === "all" || item.project === projectFilter;
      const dateOk = passesDateFilter(item);
      const text = `${item.slug} ${item.title} ${item.project} ${item.status} ${item.category}`.toLowerCase();
      const textOk = !query || text.includes(query);
      return statusOk && projectOk && dateOk && textOk;
    });

    let sorted = sortItems(filtered);
    if (dateFilter === "latest") {
      sorted = sorted
        .slice()
        .sort((a, b) => {
          const aDate = parseDate(a.updated);
          const bDate = parseDate(b.updated);
          if (!aDate && !bDate) return 0;
          if (!aDate) return 1;
          if (!bDate) return -1;
          return bDate - aDate;
        })
        .slice(0, 20);
    }
    updateResultsCount(sorted.length, rfcData.length);
    updateHeaderIndicators();
    tbody.innerHTML = "";

    if (!sorted.length) {
      const tr = document.createElement("tr");
      tr.innerHTML = "<td colspan=\"6\">No RFCs match your filters.</td>";
      tbody.appendChild(tr);
      return;
    }

    sorted.forEach((item) => {
      const tr = document.createElement("tr");
      const updated = item.updated || "—";
      tr.innerHTML = `
        <td><a href="${rootPrefix}${item.path}">${item.slug}</a></td>
        <td>${item.title}</td>
        <td>${formatProject(item.project)}</td>
        <td><span class="badge status-${normalizeStatus(item.status)}">${formatStatus(item.status)}</span></td>
        <td>${formatCategory(item.category)}</td>
        <td>${updated}</td>
      `;
      tbody.appendChild(tr);
    });
  }

  searchInput.addEventListener("input", render);

  const statusChips = document.getElementById("status-chips");
  if (statusChips) {
    statusChips.addEventListener("click", (e) => {
      if (!e.target.dataset.status) return;
      statusFilter = e.target.dataset.status;
      document.querySelectorAll("#status-chips .chip").forEach((chip) => {
        chip.classList.toggle("active", chip.dataset.status === statusFilter);
      });
      render();
    });
  }

  const projectChips = document.getElementById("project-chips");
  if (projectChips) {
    projectChips.addEventListener("click", (e) => {
      if (!e.target.dataset.project) return;
      projectFilter = e.target.dataset.project;
      document.querySelectorAll("#project-chips .chip").forEach((chip) => {
        chip.classList.toggle("active", chip.dataset.project === projectFilter);
      });
      render();
    });
  }

  const dateChips = document.getElementById("date-chips");
  if (dateChips) {
    dateChips.addEventListener("click", (e) => {
      if (!e.target.dataset.date) return;
      dateFilter = e.target.dataset.date;
      document.querySelectorAll("#date-chips .chip").forEach((chip) => {
        chip.classList.toggle("active", chip.dataset.date === dateFilter);
      });
      render();
    });
  }

  resultsCount.textContent = "Loading RFC index...";
  fetch(`${rootPrefix}rfc-index.json`)
    .then((resp) => {
      if (!resp.ok) throw new Error(resp.statusText);
      return resp.json();
    })
    .then((data) => {
      rfcData = projectScope ? data.filter((item) => item.project === projectScope) : data;
      updateChipCounts();
      render();
    })
    .catch((err) => {
      console.error(err);
      resultsCount.textContent = "Failed to load RFC index.";
    });
})();
