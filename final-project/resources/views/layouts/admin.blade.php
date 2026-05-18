<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | NeoPay™</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --bg-base:     #0d0d0d;
            --bg-sidebar:  #111111;
            --bg-card:     #181818;
            --bg-card-alt: #1e1e1e;
            --bg-topbar:   rgba(13,13,13,0.92);
            --border:      rgba(255,255,255,0.07);
            --border-soft: rgba(255,255,255,0.04);
            --accent:      #6366f1;
            --accent-2:    #8b5cf6;
            --teal:        #14b8a6;
            --text-1:      #f3f4f6;
            --text-2:      #9ca3af;
            --text-3:      #4b5563;
            --sidebar-w:   256px;
            --ease:        cubic-bezier(.4,0,.2,1);
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', system-ui, sans-serif;
            background: var(--bg-base);
            color: var(--text-1);
            min-height: 100vh;
            -webkit-font-smoothing: antialiased;
            overflow-x: hidden;
        }

        /* ────────────────────────────────────────
           LAYOUT
        ──────────────────────────────────────── */
        #app { display: flex; min-height: 100vh; }

        /* ────────────────────────────────────────
           SIDEBAR
        ──────────────────────────────────────── */
        #sidebar {
            width: var(--sidebar-w);
            background: var(--bg-sidebar);
            border-right: 1px solid var(--border);
            position: fixed; top: 0; left: 0;
            height: 100vh;
            display: flex; flex-direction: column;
            z-index: 200;
            transition: transform .3s var(--ease);
            overflow: hidden;
        }

        /* subtle top glow */
        #sidebar::before {
            content: '';
            position: absolute; top: 0; left: 0; right: 0; height: 180px;
            background: radial-gradient(ellipse 120% 140% at 30% 0%, rgba(99,102,241,.18) 0%, transparent 60%);
            pointer-events: none;
        }

        .sb-inner { padding: 24px 16px; display: flex; flex-direction: column; height: 100%; position: relative; }

        /* logo */
        .sb-logo {
            display: flex; align-items: center; gap: 10px;
            text-decoration: none; padding: 4px 8px; margin-bottom: 32px;
        }

        .sb-logo-mark {
            width: 34px; height: 34px; border-radius: 10px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 0 18px rgba(99,102,241,.45);
        }

        .sb-logo-mark i { font-size: 1rem; color: #fff; }

        .sb-logo-text { font-size: 1.15rem; font-weight: 800; color: var(--text-1); letter-spacing: -.03em; }
        .sb-logo-text em { font-style: normal; color: var(--accent); }

        /* nav section */
        .sb-section-label {
            font-size: .65rem; font-weight: 700; letter-spacing: .12em;
            text-transform: uppercase; color: var(--text-3);
            padding: 0 10px; margin-bottom: 6px;
        }

        .sb-nav { list-style: none; flex-grow: 1; display: flex; flex-direction: column; gap: 2px; }

        .sb-link {
            display: flex; align-items: center; gap: 11px;
            padding: 10px 12px; border-radius: 10px;
            color: var(--text-2); text-decoration: none;
            font-size: .875rem; font-weight: 500;
            transition: background .18s, color .18s;
            position: relative;
        }

        .sb-link i { font-size: .95rem; width: 18px; text-align: center; flex-shrink: 0; }

        .sb-link:hover { background: rgba(255,255,255,.05); color: var(--text-1); }

        .sb-item.active .sb-link {
            background: rgba(99,102,241,.14);
            color: #a5b4fc;
        }

        .sb-item.active .sb-link::before {
            content: '';
            position: absolute; left: 0; top: 50%; transform: translateY(-50%);
            width: 3px; height: 18px;
            background: var(--accent); border-radius: 0 3px 3px 0;
        }

        /* spacer divider */
        .sb-divider { border-top: 1px solid var(--border); margin: 12px 0; }

        /* user card */
        .sb-user {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 12px; border-radius: 10px;
            background: rgba(255,255,255,.04);
            margin-bottom: 6px;
        }

        .sb-avatar {
            width: 32px; height: 32px; border-radius: 8px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            display: flex; align-items: center; justify-content: center;
            font-size: .75rem; font-weight: 800; color: #fff; flex-shrink: 0;
        }

        .sb-user-name { font-size: .8rem; font-weight: 600; color: var(--text-1); }
        .sb-user-role { font-size: .7rem; color: var(--accent); font-weight: 500; }

        .sb-signout {
            display: flex; align-items: center; gap: 11px;
            padding: 10px 12px; border-radius: 10px;
            background: none; border: none; width: 100%; text-align: left;
            color: var(--text-2); font-size: .875rem; font-weight: 500;
            cursor: pointer; transition: background .18s, color .18s;
            font-family: inherit;
        }

        .sb-signout:hover { background: rgba(239,68,68,.12); color: #f87171; }

        /* ────────────────────────────────────────
           MAIN
        ──────────────────────────────────────── */
        #main {
            margin-left: var(--sidebar-w);
            min-height: 100vh;
            display: flex; flex-direction: column;
            transition: margin-left .3s var(--ease);
            flex-grow: 1;
        }

        #main.expanded { margin-left: 0; }

        /* top bar */
        .topbar {
            position: sticky; top: 0; z-index: 100;
            height: 60px;
            background: var(--bg-topbar);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 32px;
        }

        .topbar-left { display: flex; align-items: center; gap: 14px; }

        .burger {
            width: 36px; height: 36px; border-radius: 9px;
            background: rgba(255,255,255,.05);
            border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--text-2); font-size: 1.1rem;
            transition: background .15s, color .15s;
        }

        .burger:hover { background: rgba(255,255,255,.1); color: var(--text-1); }

        .topbar-breadcrumb { font-size: .82rem; color: var(--text-3); font-weight: 500; }
        .topbar-breadcrumb span { color: var(--text-2); }

        .topbar-right { display: flex; align-items: center; gap: 10px; }

        .topbar-pill {
            display: flex; align-items: center; gap: 7px;
            padding: 6px 14px; border-radius: 20px;
            background: rgba(99,102,241,.15);
            border: 1px solid rgba(99,102,241,.25);
            color: #a5b4fc; font-size: .75rem; font-weight: 600;
        }

        /* page wrapper */
        .page-wrap { padding: 32px; flex-grow: 1; }

        /* page heading */
        .page-head { margin-bottom: 28px; }
        .page-head h2 {
            font-size: 1.65rem; font-weight: 800;
            letter-spacing: -.04em; color: var(--text-1);
        }
        .page-head p { font-size: .85rem; color: var(--text-3); margin-top: 4px; }

        /* ────────────────────────────────────────
           STAT CARDS
        ──────────────────────────────────────── */
        .stat-card {
            border-radius: 16px;
            padding: 22px;
            display: flex; align-items: flex-start; justify-content: space-between;
            margin-bottom: 0;
            border: 1px solid transparent;
            position: relative; overflow: hidden;
        }

        .stat-card::after {
            content: '';
            position: absolute; right: -16px; bottom: -16px;
            width: 80px; height: 80px; border-radius: 50%;
            background: rgba(255,255,255,.06);
        }

        .sc-black  { background: linear-gradient(135deg,#1c1c1c,#262626); border-color: rgba(255,255,255,.08); }
        .sc-teal   { background: linear-gradient(135deg,#0d4d47,#0e6e7a); border-color: rgba(20,184,166,.25); }
        .sc-indigo { background: linear-gradient(135deg,#2d2680,#3b2f8f); border-color: rgba(99,102,241,.3); }

        .sc-label { font-size: .7rem; font-weight: 700; text-transform: uppercase; letter-spacing: .1em; color: rgba(255,255,255,.45); margin-bottom: 8px; }
        .sc-value { font-size: 2.2rem; font-weight: 800; color: #fff; line-height: 1; letter-spacing: -.05em; }
        .sc-foot  { font-size: .72rem; color: rgba(255,255,255,.35); margin-top: 10px; }

        .sc-icon {
            width: 40px; height: 40px; border-radius: 11px;
            background: rgba(255,255,255,.1);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; color: rgba(255,255,255,.7); flex-shrink: 0;
        }

        /* ────────────────────────────────────────
           CARDS
        ──────────────────────────────────────── */
        .card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
        }

        .card-head {
            padding: 18px 22px;
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
        }

        .card-head h4 {
            font-size: .95rem; font-weight: 700;
            color: var(--text-1); letter-spacing: -.01em;
            display: flex; align-items: center; gap: 8px;
        }

        .card-head h4 i { color: var(--accent); font-size: 1rem; }

        .card-head-meta { font-size: .72rem; color: var(--text-3); font-weight: 500; }

        .card-body { padding: 22px; }
        .card-body-0 { padding: 0; }

        /* ────────────────────────────────────────
           QUICK STATS
        ──────────────────────────────────────── */
        .qs-row {
            display: flex; align-items: center; justify-content: space-between;
            padding: 14px 0; border-bottom: 1px solid var(--border-soft);
        }
        .qs-row:last-child { border-bottom: none; }
        .qs-label { font-size: .82rem; color: var(--text-2); }
        .qs-val   { font-size: .9rem; font-weight: 700; }

        /* ────────────────────────────────────────
           TABLE
        ──────────────────────────────────────── */
        .table {
            color: var(--text-1);
            font-size: .85rem;
            --bs-table-bg: transparent;
            --bs-table-hover-bg: rgba(255,255,255,.03);
            --bs-table-striped-bg: transparent;
            margin: 0;
        }

        .table thead th {
            background: var(--bg-card-alt);
            color: var(--text-3);
            font-size: .68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .1em;
            padding: 12px 18px;
            border-bottom: 1px solid var(--border);
            border-top: none;
        }

        .table tbody td {
            padding: 14px 18px;
            vertical-align: middle;
            border-bottom: 1px solid var(--border-soft);
            color: var(--text-2);
        }

        .table tbody tr:last-child td { border-bottom: none; }
        .table tbody tr:hover td { background: rgba(255,255,255,.025); color: var(--text-1); }

        /* user avatar in table */
        .u-avatar {
            width: 34px; height: 34px; border-radius: 9px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            display: flex; align-items: center; justify-content: center;
            font-size: .75rem; font-weight: 800; color: #fff; flex-shrink: 0;
        }

        .u-name { font-weight: 600; color: var(--text-1); font-size: .85rem; }
        .u-id   { font-size: .7rem; color: var(--text-3); }

        /* badges */
        .badge {
            font-weight: 600; font-size: .68rem;
            padding: 4px 10px; border-radius: 20px;
            display: inline-flex; align-items: center; gap: 4px;
        }

        .badge-active   { background: rgba(20,184,166,.12); color: #2dd4bf; border: 1px solid rgba(20,184,166,.2); }
        .badge-inactive { background: rgba(239,68,68,.10); color: #f87171; border: 1px solid rgba(239,68,68,.18); }

        /* delete btn */
        .btn-del {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 13px; border-radius: 8px;
            font-size: .75rem; font-weight: 600;
            background: rgba(239,68,68,.09);
            color: #f87171;
            border: 1px solid rgba(239,68,68,.18);
            cursor: pointer;
            transition: background .15s, box-shadow .15s, color .15s;
        }

        .btn-del:hover {
            background: #ef4444; color: #fff;
            box-shadow: 0 4px 14px rgba(239,68,68,.35);
        }

        /* alerts */
        .alert { border-radius: 12px; font-size: .85rem; border: none; }
        .alert-success { background: rgba(20,184,166,.1); color: #2dd4bf; border: 1px solid rgba(20,184,166,.2); }
        .alert-danger  { background: rgba(239,68,68,.1);  color: #f87171; border: 1px solid rgba(239,68,68,.2); }

        /* pagination */
        .pagination {
            --bs-pagination-bg:               var(--bg-card-alt);
            --bs-pagination-border-color:     var(--border);
            --bs-pagination-color:            var(--text-2);
            --bs-pagination-hover-bg:         rgba(255,255,255,.07);
            --bs-pagination-hover-border-color: var(--border);
            --bs-pagination-hover-color:      var(--text-1);
            --bs-pagination-active-bg:        var(--accent);
            --bs-pagination-active-border-color: var(--accent);
            --bs-pagination-active-color:     #fff;
            --bs-pagination-disabled-bg:      var(--bg-card);
            --bs-pagination-disabled-color:   var(--text-3);
        }
        .page-link { border-radius: 8px !important; font-size: .8rem; }

        /* nav active indicator */
        #sidebar.sb-collapsed { transform: translateX(-100%); }
        .sb-link.is-active {
            background: rgba(99,102,241,.14) !important;
            color: #a5b4fc !important;
        }
        .sb-link.is-active::before {
            content: '';
            position: absolute; left: 0; top: 50%; transform: translateY(-50%);
            width: 3px; height: 18px;
            background: var(--accent); border-radius: 0 3px 3px 0;
        }

        /* ── Custom Delete Modal ── */
        .del-modal-backdrop {
            position: fixed; inset: 0;
            background: rgba(0,0,0,.65);
            backdrop-filter: blur(4px);
            z-index: 9000;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; pointer-events: none;
            transition: opacity .2s;
        }
        .del-modal-backdrop.open { opacity: 1; pointer-events: all; }
        .del-modal {
            background: #1a1a1a;
            border: 1px solid rgba(255,255,255,.08);
            border-radius: 20px;
            padding: 36px 32px;
            width: 100%; max-width: 400px;
            text-align: center;
            transform: scale(.92) translateY(12px);
            transition: transform .22s cubic-bezier(.4,0,.2,1);
            box-shadow: 0 32px 80px rgba(0,0,0,.6);
        }
        .del-modal-backdrop.open .del-modal { transform: scale(1) translateY(0); }
        .del-modal-icon {
            width: 68px; height: 68px; border-radius: 50%;
            background: rgba(239,68,68,.12);
            border: 1px solid rgba(239,68,68,.25);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
            font-size: 1.8rem; color: #f87171;
        }
        .del-modal h5 { color: #f3f4f6; font-size: 1.1rem; font-weight: 700; margin-bottom: 8px; }
        .del-modal p  { color: #6b7280; font-size: .875rem; margin-bottom: 28px; line-height: 1.5; }
        .del-modal-actions { display: flex; gap: 12px; }
        .btn-cancel {
            flex: 1; padding: 11px;
            border-radius: 10px;
            background: rgba(255,255,255,.06);
            border: 1px solid rgba(255,255,255,.08);
            color: #9ca3af; font-size: .875rem; font-weight: 600;
            cursor: pointer; transition: background .15s;
        }
        .btn-cancel:hover { background: rgba(255,255,255,.1); color: #f3f4f6; }
        .btn-confirm-del {
            flex: 1; padding: 11px;
            border-radius: 10px;
            background: linear-gradient(135deg,#dc2626,#b91c1c);
            border: none;
            color: #fff; font-size: .875rem; font-weight: 700;
            cursor: pointer; transition: box-shadow .15s, opacity .15s;
        }
        .btn-confirm-del:hover { box-shadow: 0 6px 20px rgba(239,68,68,.4); }

        @media (max-width: 991px) {
            #sidebar { transform: translateX(-100%); }
            #sidebar.sb-open { transform: translateX(0); }
            #main { margin-left: 0 !important; }
            .page-wrap { padding: 20px; }
            .topbar { padding: 0 20px; }
        }
        /* dash-nav-btn: card link buttons */
        .dash-nav-btn {
            display:flex; align-items:center; gap:10px;
            padding:11px 14px; border-radius:10px;
            background:rgba(255,255,255,.05);
            border:1px solid rgba(255,255,255,.07);
            color:var(--text-2); font-size:.82rem; font-weight:600;
            text-decoration:none;
            transition:background .18s, color .18s;
        }
        .dash-nav-btn:hover { background:rgba(99,102,241,.15); color:#a5b4fc; border-color:rgba(99,102,241,.3); }
        .dash-nav-btn .bi-arrow-right { margin-left:auto; }
    </style>
    @stack('page-styles')
</head>
<body>
<div id="app">

    {{-- ═══ SIDEBAR ═══ --}}
    <aside id="sidebar">
        <div class="sb-inner">

            {{-- Logo --}}
            <a href="{{ route('admin.dashboard') }}" class="sb-logo">
                <div class="sb-logo-mark"><i class="bi bi-layers-half"></i></div>
                <span class="sb-logo-text">Neo<em>Pay</em>™</span>
            </a>

            <div class="sb-section-label">Main Menu</div>

            <ul class="sb-nav">
                <li class="sb-item {{ request()->routeIs('admin.dashboard') ? 'sb-active' : '' }}">
                    <a href="{{ route('admin.dashboard') }}" class="sb-link {{ request()->routeIs('admin.dashboard') ? 'is-active' : '' }}">
                        <i class="bi bi-grid-1x2-fill"></i> Dashboard
                    </a>
                </li>
                <li class="sb-item {{ request()->routeIs('admin.users.*') ? 'sb-active' : '' }}">
                    <a href="{{ route('admin.users.index') }}" class="sb-link {{ request()->routeIs('admin.users.*') ? 'is-active' : '' }}">
                        <i class="bi bi-people-fill"></i> Users
                    </a>
                </li>
                <li class="sb-item {{ request()->routeIs('admin.analytics') ? 'sb-active' : '' }}">
                    <a href="{{ route('admin.analytics') }}" class="sb-link {{ request()->routeIs('admin.analytics') ? 'is-active' : '' }}">
                        <i class="bi bi-bar-chart-line-fill"></i> Analytics
                    </a>
                </li>
            </ul>

            {{-- Footer --}}
            <div class="sb-divider"></div>
            <div class="sb-user">
                <div class="sb-avatar">{{ strtoupper(substr(auth()->user()->name ?? 'A', 0, 1)) }}</div>
                <div>
                    <div class="sb-user-name">{{ auth()->user()->name ?? 'Admin' }}</div>
                    <div class="sb-user-role">Administrator</div>
                </div>
            </div>
            <form action="{{ route('logout') }}" method="POST">
                @csrf
                <button type="submit" class="sb-signout">
                    <i class="bi bi-box-arrow-left"></i> Sign Out
                </button>
            </form>
        </div>
    </aside>

    {{-- ═══ MAIN ═══ --}}
    <div id="main">

        {{-- Top Bar --}}
        <header class="topbar">
            <div class="topbar-left">
                <button class="burger" id="sbToggle"><i class="bi bi-list"></i></button>
                <span class="topbar-breadcrumb">
                    Admin / <span>@yield('page-title', 'Dashboard')</span>
                </span>
            </div>
            <div class="topbar-right">
                <div class="topbar-pill"><i class="bi bi-shield-fill-check"></i> Verified Admin</div>
            </div>
        </header>

        {{-- Content --}}
        <div class="page-wrap">
            @yield('content')
        </div>
    </div>

</div>

{{-- ═══ Custom Delete Confirmation Modal ═══ --}}
<div class="del-modal-backdrop" id="delModal">
    <div class="del-modal">
        <div class="del-modal-icon"><i class="bi bi-trash3-fill"></i></div>
        <h5>Delete User Account?</h5>
        <p id="delModalMsg">This action is permanent and cannot be undone.</p>
        <div class="del-modal-actions">
            <button class="btn-cancel" onclick="closeDelModal()">Cancel</button>
            <button class="btn-confirm-del" id="delConfirmBtn">
                <i class="bi bi-trash3-fill me-1"></i> Delete
            </button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ── Sidebar toggle ──
    const sb   = document.getElementById('sidebar');
    const main = document.getElementById('main');

    document.getElementById('sbToggle').addEventListener('click', () => {
        if (window.innerWidth <= 991) {
            sb.classList.toggle('sb-open');
        } else {
            sb.classList.toggle('sb-collapsed');
            main.classList.toggle('expanded');
        }
    });


    // ── Custom Delete Modal ──
    let pendingForm = null;

    window.openDelModal = function(formId, userName) {
        pendingForm = document.getElementById(formId);
        document.getElementById('delModalMsg').textContent =
            `Akun "${userName}" akan dihapus secara permanen dan tidak bisa dikembalikan.`;
        document.getElementById('delModal').classList.add('open');
    };

    window.closeDelModal = function() {
        document.getElementById('delModal').classList.remove('open');
        pendingForm = null;
    };

    document.getElementById('delConfirmBtn').addEventListener('click', () => {
        if (pendingForm) {
            pendingForm.submit();
        }
    });

    // Close on backdrop click
    document.getElementById('delModal').addEventListener('click', function(e) {
        if (e.target === this) closeDelModal();
    });
</script>
@stack('scripts')
</body>
</html>

