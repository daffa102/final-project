<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'Dashboard' }} | NeoPay™ Business</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <style>
        :root {
            --primary: #6366f1;
            --primary-light: #818cf8;
            --primary-dark: #4f46e5;
            --secondary: #14b8a6;
            --accent: #f43f5e;
            --bg-main: #0a0a0c;
            --bg-card: #151518;
            --bg-sidebar: #0f0f12;
            --border: rgba(255, 255, 255, 0.08);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--bg-main);
            color: var(--text-main);
            margin: 0;
            overflow-x: hidden;
        }

        .layout-wrapper {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: 280px;
            background: var(--bg-sidebar);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            z-index: 50;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .sidebar-header {
            padding: 32px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-box {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 16px rgba(99, 102, 241, 0.3);
        }

        .logo-text {
            font-size: 1.25rem;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .nav-list {
            padding: 0 16px;
            list-style: none;
            flex: 1;
        }

        .nav-item {
            margin-bottom: 4px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: var(--text-muted);
            text-decoration: none;
            border-radius: 12px;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.2s ease;
        }

        .nav-link:hover {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-main);
        }

        .nav-link.active {
            background: rgba(99, 102, 241, 0.15);
            color: var(--primary-light);
        }

        .nav-link i {
            font-size: 1.1rem;
        }

        .sidebar-footer {
            padding: 24px;
            border-top: 1px solid var(--border);
        }

        .user-pill {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 16px;
        }

        .avatar {
            width: 36px;
            height: 36px;
            background: var(--primary);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 32px;
            transition: all 0.3s ease;
        }

        .header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
        }

        .page-title h1 {
            font-size: 1.75rem;
            font-weight: 800;
            margin: 0;
            letter-spacing: -0.5px;
        }

        .page-title p {
            color: var(--text-muted);
            margin: 4px 0 0;
            font-size: 0.9rem;
        }

        /* Glass Cards */
        .glass-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 24px;
            position: relative;
            overflow: hidden;
        }

        .glass-card::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 150px;
            height: 150px;
            background: radial-gradient(circle at top right, rgba(99, 102, 241, 0.05), transparent 70%);
            pointer-events: none;
        }

        @media (max-width: 1024px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .sidebar.open {
                transform: translateX(0);
            }
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
        }
    </style>
    @stack('styles')
</head>
<body x-data="{ sidebarOpen: false }">
    <div class="layout-wrapper">
        <!-- Sidebar -->
        <aside class="sidebar" :class="{ 'open': sidebarOpen }">
            <div class="sidebar-header">
                <div class="logo-box">
                    <i class="bi bi-rocket-takeoff-fill"></i>
                </div>
                <div class="logo-text">NeoPay<em>™</em></div>
            </div>

            <nav class="nav-list">
                <div class="nav-item">
                    <a href="#" class="nav-link active">
                        <i class="bi bi-grid-alt"></i> Dashboard
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="bi bi-box-seam"></i> Produk
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="bi bi-tags"></i> Kategori
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="bi bi-cash-stack"></i> Transaksi
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="bi bi-wallet2"></i> Keuangan
                    </a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="bi bi-file-earmark-bar-graph"></i> Laporan
                    </a>
                </div>
            </nav>

            <div class="sidebar-footer">
                <div class="user-pill">
                    <div class="avatar">{{ substr(auth()->user()->name ?? 'U', 0, 1) }}</div>
                    <div style="flex: 1">
                        <div style="font-size: 0.85rem; font-weight: 700">{{ auth()->user()->name }}</div>
                        <div style="font-size: 0.7rem; color: var(--text-muted)">{{ auth()->user()->store_name ?? 'My Store' }}</div>
                    </div>
                </div>
                <form action="{{ route('logout') }}" method="POST" style="margin-top: 12px">
                    @csrf
                    <button type="submit" class="nav-link" style="width: 100%; border: none; background: none; cursor: pointer">
                        <i class="bi bi-box-arrow-left"></i> Keluar
                    </button>
                </form>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <header class="header-row">
                <div class="page-title">
                    @yield('header')
                </div>
                <div class="header-actions">
                    <button @click="sidebarOpen = !sidebarOpen" class="nav-link" style="background: var(--bg-card); display: none">
                        <i class="bi bi-list"></i>
                    </button>
                </div>
            </header>

            {{ $slot ?? '' }}
            @yield('content')
        </main>
    </div>

    @livewireScripts
    @stack('scripts')
</body>
</html>
