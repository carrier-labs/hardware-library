// Hardware library catalogue. Two routes on the hash: #/ (every component) and #/<part>.
// catalog.json and models/ come from tools/build_site.py.
(function () {
  const app = document.getElementById("app");
  const css = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
  const esc = s => String(s).replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
  const COLORS = { plastic: 0x6f8794, component: 0xff8200, board: 0x1f6b52, metal: 0xb8bec4 };
  const hex = c => "#" + c.toString(16).padStart(6, "0");
  const STATUS = ["measured", "fit-tested", "proven"];

  const loader = new THREE.STLLoader(), geoms = {};
  const getGeom = f => geoms[f] || (geoms[f] = fetch(f)
    .then(r => { if (!r.ok) throw new Error(f + ": " + r.status); return r.arrayBuffer(); })
    .then(b => { const g = loader.parse(b); g.computeVertexNormals(); return g; }));

  function material(p, clip) {
    const comp = p.role !== "plastic";
    return new THREE.MeshStandardMaterial({ color: COLORS[p.role] || COLORS.plastic,
      roughness: comp ? 0.45 : 0.68, metalness: p.role === "metal" ? 0.6 : comp ? 0.1 : 0.02,
      side: THREE.DoubleSide, clippingPlanes: clip ? [clip] : [] });
  }
  function lights(scene) {
    scene.add(new THREE.HemisphereLight(0xffffff, 0x445566, 0.75));
    const sun = new THREE.DirectionalLight(0xffffff, 0.85); sun.position.set(1.4, -1, 2.2); scene.add(sun);
    const fill = new THREE.DirectionalLight(0xffffff, 0.3); fill.position.set(-1.5, 1, 0.6); scene.add(fill);
  }
  function aim(camera, box, dir) {
    const c = box.getCenter(new THREE.Vector3()), s = box.getSize(new THREE.Vector3());
    const r = Math.max(s.x, s.y, s.z);
    camera.position.copy(c).add(dir.clone().normalize().multiplyScalar(r * 2.6));
    camera.near = r / 200; camera.far = r * 30; camera.updateProjectionMatrix();
    return c;
  }
  const ISO = new THREE.Vector3(1.5, -1.1, 1.0);

  let catalog = null, viewer = null, thumbs = {};
  const load = () => catalog || (catalog = fetch("catalog.json").then(r => r.json()));

  // ---- Thumbnails: one shared offscreen renderer, each part's first view, cached as images
  let thumbR = null;
  async function thumb(part) {
    if (thumbs[part.id]) return thumbs[part.id];
    if (!thumbR) { thumbR = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true }); thumbR.setSize(480, 360, false); }
    const v = part.views[0], scene = new THREE.Scene(), cam = new THREE.PerspectiveCamera(32, 4 / 3, 0.1, 2000);
    cam.up.set(0, 0, 1); lights(scene); scene.background = new THREE.Color(css("--stage"));
    const gs = await Promise.all(v.parts.map(p => getGeom(p.file)));
    v.parts.forEach((p, i) => scene.add(new THREE.Mesh(gs[i], material(p))));
    const box = new THREE.Box3().setFromObject(scene);
    cam.lookAt(aim(cam, box, ISO));
    thumbR.render(scene, cam);
    return (thumbs[part.id] = thumbR.domElement.toDataURL("image/png"));
  }

  // ---- Catalogue
  let filter = { q: "", status: "" };
  async function index() {
    const parts = await load();
    document.title = "Hardware Library";
    app.innerHTML = `
      <header class="head">
        <div class="eyebrow">Carrier Labs · hardware-library</div>
        <h1>Hardware Library</h1>
        <p class="lede">The parts we build into products, each with the plastic that holds it, the hole it needs in a wall,
        and a small fit piece to print first. Open one to turn it round, cut it open and see how it goes together.</p>
      </header>
      <div class="bar">
        <input id="q" type="search" placeholder="Search components" aria-label="Search components" value="${esc(filter.q)}">
        <button class="chip" data-s="" type="button">All</button>
        ${STATUS.map(s => `<button class="chip" data-s="${s}" type="button">${s.replace("-", " ")}</button>`).join("")}
      </div>
      <div class="grid" id="grid"></div>`;
    const grid = document.getElementById("grid");
    function draw() {
      document.querySelectorAll(".chip").forEach(b => b.setAttribute("aria-pressed", String(b.dataset.s === filter.status)));
      const q = filter.q.toLowerCase();
      const shown = parts.filter(p => (!filter.status || p.status === filter.status) &&
        (!q || [p.title, p.kind, p.summary, p.id, p.firstUsed].join(" ").toLowerCase().includes(q)));
      grid.innerHTML = shown.length ? shown.map(p => `
        <a class="card tile" href="#/${p.id}">
          <div class="thumb" data-id="${p.id}">${thumbs[p.id] ? `<img alt="" src="${thumbs[p.id]}">` : "<span>rendering…</span>"}</div>
          <div class="body">
            <div class="eyebrow">${esc(p.kind || "Component")}</div>
            <div class="name">${esc(p.title)}</div>
            <div class="meta"><span>${esc(p.firstUsed || "")}</span><span class="pill ${p.status}">${esc(p.status)}</span></div>
          </div>
        </a>`).join("") : `<p class="empty">Nothing matches.</p>`;
      shown.forEach(p => thumb(p).then(src => {
        const el = grid.querySelector(`.thumb[data-id="${p.id}"]`);
        if (el && !el.querySelector("img")) el.innerHTML = `<img alt="" src="${src}">`;
      }).catch(() => {}));
    }
    document.getElementById("q").addEventListener("input", e => { filter.q = e.target.value; draw(); });
    document.querySelectorAll(".chip").forEach(b => b.addEventListener("click", () => { filter.status = b.dataset.s; draw(); }));
    draw();
  }

  // ---- One component
  async function page(id) {
    const part = (await load()).find(p => p.id === id);
    if (!part) { app.innerHTML = `<a class="back" href="#/">← All components</a><p class="empty">No component called ${esc(id)}.</p>`; return; }
    document.title = part.title + " · Hardware Library";
    const dotRow = n => "●".repeat(n);
    const fit = part.fit;
    app.innerHTML = `
      <a class="back" href="#/">← All components</a>
      <header class="head">
        <div class="eyebrow">${esc(part.kind || "Component")} · components/${esc(part.id)}${part.firstUsed ? " · first used in " + esc(part.firstUsed) : ""}</div>
        <h1>${esc(part.title)}</h1>
        <p class="lede">${esc(part.summary)}</p>
        <div><span class="pill ${part.status}">${esc(part.status)}</span>${part.updated ? ` <span class="foot">updated ${esc(part.updated)}</span>` : ""}</div>
      </header>
      ${part.views.length > 1 ? `<div class="tabs" role="group" aria-label="View">${part.views.map(v =>
        `<button class="tab" data-view="${v.id}" type="button">${esc(v.label)}</button>`).join("")}</div>` : ""}
      <div class="main">
        <div class="col">
          <div class="stage" id="stage">
            <div class="loading" id="loading">Loading…</div>
            <div class="views"><button data-cam="iso" type="button">3D</button><button data-cam="front" type="button">Front</button>
              <button data-cam="side" type="button">Side</button><button data-cam="top" type="button">Top</button></div>
            <div class="hint">drag: turn · scroll / pinch: zoom · right-drag: pan</div>
          </div>
          <div class="controls">
            <label id="moveWrap" hidden><span id="moveLabel"></span> <input id="move" type="range" min="0" max="100" value="0"></label>
            <label>Cut open <input id="section" type="range" min="0" max="100" value="100"></label>
            <label><input id="showComp" type="checkbox" checked> Show the component</label>
          </div>
          <div class="legend" id="legend"></div>
          <p class="caption" id="caption"></p>
        </div>
        <aside class="card">
          ${(part.specs || []).map(s => `
            <div class="block">
              <h2>${esc(s.title)}</h2>
              <dl>${s.rows.map(([k, v]) => `<dt>${esc(k)}</dt><dd>${esc(v)}</dd>`).join("")}</dl>
              ${s.note ? `<div class="foot">${esc(s.note)}</div>` : ""}
              ${s.badge ? `<div><span class="pill ${s.badge[0]}">${esc(s.badge[1])}</span> <span class="foot">${esc(s.badgeNote || "")}</span></div>` : ""}
            </div>`).join("")}
          ${(part.parts || []).length ? `
            <div class="block">
              <h2>Where to buy</h2>
              ${part.parts.map(b => `
                <div class="buy">
                  <div class="name">${esc(b.name)}${b.mpn ? ` <code>${esc(b.mpn)}</code>` : ""}</div>
                  ${b.sources.length ? `<ul>${b.sources.map(s => `<li>${s.url ? `<a href="${esc(s.url)}" target="_blank" rel="noopener">` : ""}${esc(s.supplier || "unrecorded")}${s.sku ? ` <code>${esc(s.sku)}</code>` : ""}${s.url ? "</a>" : ""}${s.price ? ` · ${esc(s.price)} ${esc(s.currency || "")}` : ""}${s.notes ? ` <span class="foot">${esc(s.notes)}</span>` : ""}</li>`).join("")}</ul>` : `<div class="foot">No source recorded yet</div>`}
                  ${b.notes ? `<div class="foot">${esc(b.notes)}</div>` : ""}
                </div>`).join("")}
              <div class="foot">From <code>parts/parts.csv</code> and <code>sources.csv</code>. Prices are as of the date in the sheet.</div>
            </div>` : ""}
          ${fit ? `
            <div class="block">
              <h2>Fit piece</h2>
              <table><thead><tr>${fit.columns.map(c => `<th>${esc(c)}</th>`).join("")}</tr></thead>
                <tbody>${fit.rows.map(r => `<tr><td class="dots">${dotRow(r[0])}</td>${r.slice(1).map(c => `<td class="n">${esc(c)}</td>`).join("")}</tr>`).join("")}</tbody></table>
              ${fit.checks ? `<ul>${fit.checks.map(c => `<li>${esc(c)}</li>`).join("")}</ul>` : ""}
              ${fit.print ? `<div class="foot">${esc(fit.print)}</div>` : ""}
              ${part.downloads.length ? `<div class="dl">${part.downloads.map(d => `<a class="btn" href="${d}" download>Download ${d.split(".").pop().toUpperCase()}</a>`).join("")}</div>` : ""}
            </div>` : ""}
        </aside>
      </div>`;
    viewer = makeViewer(part);
  }

  function makeViewer(part) {
    const stage = document.getElementById("stage"), loadingEl = document.getElementById("loading");
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.localClippingEnabled = true;
    stage.prepend(renderer.domElement);
    const scene = new THREE.Scene(), camera = new THREE.PerspectiveCamera(32, 4 / 3, 0.1, 2000);
    camera.up.set(0, 0, 1);
    const controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    lights(scene);
    const clip = new THREE.Plane(new THREE.Vector3(0, -1, 0), 0);
    let grid = null, group = null, view = null, alive = true;
    const box = new THREE.Box3();
    const $ = id => document.getElementById(id);

    function theme() {
      scene.background = new THREE.Color(css("--stage"));
      if (grid) scene.remove(grid);
      grid = new THREE.GridHelper(400, 80, new THREE.Color(css("--grid")), new THREE.Color(css("--grid")));
      grid.rotation.x = Math.PI / 2; scene.add(grid);
      placeGrid();
    }
    function placeGrid() { if (!group) return; const c = box.getCenter(new THREE.Vector3()); grid.position.set(c.x, c.y, box.min.z - 0.05); }
    function look(dir) { controls.target.copy(aim(camera, box, dir)); placeGrid(); }

    async function show(id) {
      view = part.views.find(v => v.id === id) || part.views[0];
      document.querySelectorAll(".tab").forEach(b => b.setAttribute("aria-pressed", String(b.dataset.view === view.id)));
      $("legend").innerHTML = view.parts.map(p => `<span><i style="background:${hex(COLORS[p.role] || COLORS.plastic)}"></i>${esc(p.label || p.name)}</span>`).join("");
      $("caption").textContent = view.caption || "";
      $("moveWrap").hidden = !view.move;
      if (view.move) { $("moveLabel").textContent = view.move.label; $("move").value = 0; }
      $("showComp").parentElement.hidden = !view.parts.some(p => p.role !== "plastic");
      loadingEl.hidden = false; loadingEl.textContent = "Loading…";
      let gs;
      try { gs = await Promise.all(view.parts.map(p => getGeom(p.file))); }
      catch (e) { loadingEl.textContent = "Couldn't load the models. Reload to try again."; return; }
      if (!alive) return;
      if (group) scene.remove(group);
      group = new THREE.Group();
      view.parts.forEach((p, i) => { const m = new THREE.Mesh(gs[i], material(p, clip)); m.userData = p; group.add(m); });
      scene.add(group);
      box.setFromObject(group);
      if (view.move)
        group.children.filter(m => m.userData.moves).forEach(m => [view.move.from, view.move.to].forEach(d => {
          const b = new THREE.Box3().setFromObject(m); b.translate(new THREE.Vector3().setComponent("xyz".indexOf(view.move.axis), d)); box.union(b);
        }));
      apply(); look(ISO); loadingEl.hidden = true;
    }
    function apply() {
      if (!group) return;
      const t = +$("move").value / 100, sec = +$("section").value / 100, showC = $("showComp").checked;
      clip.constant = box.min.y + (box.max.y - box.min.y) * sec + 0.01;
      group.children.forEach(m => {
        const p = m.userData;
        if (p.role !== "plastic") m.visible = showC;
        if (p.moves && view.move) { m.position.set(0, 0, 0); m.position[view.move.axis] = view.move.from + (view.move.to - view.move.from) * t; }
      });
    }
    const CAMS = { iso: ISO, front: new THREE.Vector3(-1, 0, 0.0001), side: new THREE.Vector3(0, -1, 0.0001), top: new THREE.Vector3(0.0001, 0, 1) };
    document.querySelectorAll("[data-cam]").forEach(b => b.addEventListener("click", () => look(CAMS[b.dataset.cam])));
    document.querySelectorAll(".tab").forEach(b => b.addEventListener("click", () => show(b.dataset.view)));
    ["move", "section", "showComp"].forEach(id => $(id).addEventListener("input", apply));
    function resize() { const w = stage.clientWidth, h = stage.clientHeight; renderer.setSize(w, h, false); camera.aspect = w / h; camera.updateProjectionMatrix(); }
    const ro = new ResizeObserver(resize); ro.observe(stage);
    theme(); resize(); show(part.views[0].id);
    (function loop() { if (!alive) return; controls.update(); renderer.render(scene, camera); requestAnimationFrame(loop); })();
    return { theme, dispose() { alive = false; ro.disconnect(); controls.dispose(); renderer.dispose(); renderer.forceContextLoss(); } };
  }

  function route() {
    if (viewer) { viewer.dispose(); viewer = null; }
    const id = decodeURIComponent(location.hash.replace(/^#\/?/, ""));
    window.scrollTo(0, 0);
    (id ? page(id) : index()).catch(e => { app.innerHTML = `<p class="empty">Couldn't load the catalogue: ${esc(e.message)}</p>`; });
  }
  const retheme = () => { thumbs = {}; if (viewer) viewer.theme(); else route(); };
  const mq = window.matchMedia("(prefers-color-scheme: dark)");
  if (mq.addEventListener) mq.addEventListener("change", retheme);
  window.addEventListener("hashchange", route);
  route();
})();
