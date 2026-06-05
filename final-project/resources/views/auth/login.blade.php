<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Kash.</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=Poppins:wght@700;800;900&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --lime:    #BEF364;
            --lime-dk: #8FCC2A;
            --dark:    #0D1117;
            --card:    #161D2E;
            --card2:   #1E2938;
            --border:  rgba(255,255,255,0.07);
            --text1:   #F1F5F9;
            --text2:   #94A3B8;
            --text3:   #4B5563;
        }

        html, body { height: 100%; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--dark);
            color: var(--text1);
            -webkit-font-smoothing: antialiased;
            overflow: hidden;
        }

        /* ══════════════════════════════
           LAYOUT
        ══════════════════════════════ */
        .page {
            display: flex;
            height: 100vh;
            width: 100vw;
            overflow: hidden;
        }

        /* ══════════════════════════════
           LEFT PANEL
        ══════════════════════════════ */
        .left-panel {
            flex: 1.1;
            background: linear-gradient(135deg, #0D1117 0%, #111D2E 60%, #0D1B12 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px 56px;
            position: relative;
            overflow: hidden;
        }

        /* Background glow blobs */
        .left-panel::before {
            content: '';
            position: absolute;
            top: -120px; left: -80px;
            width: 480px; height: 480px;
            background: radial-gradient(circle, rgba(190,243,100,0.12) 0%, transparent 70%);
            pointer-events: none;
        }
        .left-panel::after {
            content: '';
            position: absolute;
            bottom: -100px; right: -60px;
            width: 360px; height: 360px;
            background: radial-gradient(circle, rgba(190,243,100,0.07) 0%, transparent 70%);
            pointer-events: none;
        }

        .lp-inner { position: relative; z-index: 1; max-width: 480px; }

        /* Logo */
        .lp-logo {
            font-family: 'Poppins', sans-serif;
            font-size: 2rem;
            font-weight: 900;
            color: var(--lime);
            letter-spacing: -0.03em;
            margin-bottom: 52px;
            display: inline-block;
        }

        /* Heading */
        .lp-heading {
            font-family: 'Poppins', sans-serif;
            font-size: 2.6rem;
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -0.04em;
            color: var(--text1);
            margin-bottom: 16px;
        }
        .lp-heading span { color: var(--lime); }

        .lp-sub {
            font-size: 1rem;
            color: var(--text2);
            line-height: 1.65;
            margin-bottom: 48px;
        }

        /* Feature list */
        .feature-list { display: flex; flex-direction: column; gap: 20px; margin-bottom: 52px; }

        .feature-item {
            display: flex;
            align-items: flex-start;
            gap: 16px;
        }

        .feature-icon {
            width: 42px; height: 42px;
            border-radius: 12px;
            background: rgba(190,243,100,0.1);
            border: 1px solid rgba(190,243,100,0.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .feature-text h4 {
            font-size: .9rem; font-weight: 700;
            color: var(--text1); margin-bottom: 3px;
        }
        .feature-text p { font-size: .8rem; color: var(--text2); line-height: 1.5; }

        /* Stats row */
        .stats-row {
            display: flex; gap: 32px;
            padding-top: 32px;
            border-top: 1px solid var(--border);
        }
        .stat-val {
            font-family: 'Poppins', sans-serif;
            font-size: 1.5rem; font-weight: 800;
            color: var(--lime); letter-spacing: -0.04em;
        }
        .stat-label { font-size: .75rem; color: var(--text2); margin-top: 2px; }

        /* Floating card decoration */
        .deco-card {
            position: absolute;
            bottom: 52px; right: 40px;
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.07);
            border-radius: 16px;
            padding: 16px 20px;
            backdrop-filter: blur(10px);
            display: flex; align-items: center; gap: 12px;
            animation: floatCard 4s ease-in-out infinite;
        }
        .deco-card-avatar {
            width: 36px; height: 36px; border-radius: 10px;
            background: linear-gradient(135deg, var(--lime), #8FCC2A);
            display: flex; align-items: center; justify-content: center;
            font-size: 1rem;
        }
        .deco-card-txt p { font-size: .78rem; font-weight: 600; color: var(--text1); }
        .deco-card-txt span { font-size: .7rem; color: var(--text2); }

        @keyframes floatCard {
            0%, 100% { transform: translateY(0); }
            50%       { transform: translateY(-8px); }
        }

        /* ══════════════════════════════
           RIGHT PANEL (LOGIN FORM)
        ══════════════════════════════ */
        .right-panel {
            width: 460px;
            flex-shrink: 0;
            background: var(--card);
            border-left: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 56px 48px;
            position: relative;
            overflow: hidden;
        }

        .right-panel::before {
            content: '';
            position: absolute;
            top: -60px; right: -60px;
            width: 260px; height: 260px;
            background: radial-gradient(circle, rgba(190,243,100,0.06) 0%, transparent 70%);
        }

        .form-box { width: 100%; position: relative; z-index: 1; }

        /* Back link */
        .back-link {
            display: inline-flex; align-items: center; gap: 6px;
            color: var(--text2); font-size: .82rem; font-weight: 500;
            text-decoration: none;
            transition: color .2s;
            margin-bottom: 40px;
        }
        .back-link:hover { color: var(--lime); }
        .back-link svg { transition: transform .2s; }
        .back-link:hover svg { transform: translateX(-3px); }

        .form-title {
            font-family: 'Poppins', sans-serif;
            font-size: 1.75rem; font-weight: 800;
            letter-spacing: -0.04em;
            color: var(--text1);
            margin-bottom: 6px;
        }
        .form-sub { font-size: .875rem; color: var(--text2); margin-bottom: 36px; }

        /* Admin badge */
        .admin-badge {
            display: inline-block;
            background: rgba(190,243,100,0.12);
            color: var(--lime);
            border: 1px solid rgba(190,243,100,0.22);
            font-size: .68rem; font-weight: 700;
            letter-spacing: .1em; text-transform: uppercase;
            padding: 4px 12px; border-radius: 999px;
            margin-bottom: 20px;
        }

        /* Error */
        .error-box {
            background: rgba(239,68,68,.08);
            border: 1px solid rgba(239,68,68,.2);
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: .83rem; color: #f87171;
            display: flex; align-items: center; gap: 8px;
        }

        /* Form fields */
        .field { margin-bottom: 18px; }
        .field label {
            display: block;
            font-size: .78rem; font-weight: 600;
            color: #CBD5E1; margin-bottom: 8px;
            letter-spacing: .02em;
        }
        .field input {
            width: 100%;
            padding: 13px 16px;
            background: #111727;
            border: 1px solid rgba(255,255,255,0.09);
            border-radius: 12px;
            color: var(--text1);
            font-size: .9rem;
            font-family: 'Inter', sans-serif;
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }
        .field input::placeholder { color: var(--text3); }
        .field input:focus {
            border-color: rgba(190,243,100,0.5);
            box-shadow: 0 0 0 3px rgba(190,243,100,0.1);
        }

        /* Options row */
        .options-row {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 28px;
        }
        .remember {
            display: flex; align-items: center; gap: 8px;
            font-size: .8rem; color: var(--text2); cursor: pointer;
        }
        .remember input[type=checkbox] { accent-color: var(--lime); }

        /* Submit button */
        .btn-submit {
            width: 100%;
            padding: 14px;
            background: var(--lime);
            color: #111727;
            border: none;
            border-radius: 14px;
            font-size: .95rem; font-weight: 800;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            letter-spacing: .02em;
            position: relative;
            overflow: hidden;
            transition: transform .2s, box-shadow .2s;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(190,243,100,0.35);
        }
        .btn-submit:active { transform: translateY(0); }
        .btn-submit .btn-text { position: relative; z-index: 1; }
        .btn-submit .btn-shimmer {
            position: absolute; inset: 0;
            background: linear-gradient(105deg, transparent 40%, rgba(255,255,255,0.25) 50%, transparent 60%);
            transform: translateX(-100%);
            transition: transform .5s;
        }
        .btn-submit:hover .btn-shimmer { transform: translateX(100%); }

        /* Loading spinner on button */
        .btn-submit .spinner {
            display: none;
            width: 18px; height: 18px;
            border: 2.5px solid rgba(17,23,39,0.3);
            border-top-color: #111727;
            border-radius: 50%;
            animation: spin .7s linear infinite;
            margin: 0 auto;
        }
        .btn-submit.loading .btn-text { display: none; }
        .btn-submit.loading .spinner { display: block; }

        @keyframes spin { to { transform: rotate(360deg); } }

        /* ══════════════════════════════
           SUCCESS OVERLAY
        ══════════════════════════════ */
        #successOverlay {
            position: fixed; inset: 0;
            background: rgba(13,17,23,0.92);
            backdrop-filter: blur(8px);
            z-index: 9999;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; pointer-events: none;
            transition: opacity .4s ease;
        }
        #successOverlay.show {
            opacity: 1; pointer-events: all;
        }

        .success-card {
            background: var(--card);
            border: 1px solid rgba(190,243,100,0.2);
            border-radius: 28px;
            padding: 52px 56px;
            text-align: center;
            box-shadow: 0 32px 80px rgba(0,0,0,0.5), 0 0 0 1px rgba(190,243,100,0.1);
            transform: scale(0.85) translateY(20px);
            transition: transform .45s cubic-bezier(.34,1.56,.64,1);
            max-width: 380px;
            width: 90%;
        }
        #successOverlay.show .success-card {
            transform: scale(1) translateY(0);
        }

        /* Professional Success Icon */
        .success-icon-wrap {
            width: 80px; height: 80px;
            margin: 0 auto 24px;
            border-radius: 50%;
            background: rgba(190,243,100,0.15);
            display: flex; align-items: center; justify-content: center;
            border: 2px solid rgba(190,243,100,0.3);
            animation: scaleIn 0.5s cubic-bezier(.34,1.56,.64,1) backwards;
        }
        .success-icon-wrap svg {
            color: var(--lime);
            width: 40px; height: 40px;
            animation: checkmark 0.5s ease-out 0.2s both;
        }

        @keyframes scaleIn {
            from { transform: scale(0.5); opacity: 0; }
            to   { transform: scale(1); opacity: 1; }
        }
        @keyframes checkmark {
            from { transform: scale(0.5); opacity: 0; }
            to   { transform: scale(1); opacity: 1; }
        }

        .success-title {
            font-family: 'Poppins', sans-serif;
            font-size: 1.5rem; font-weight: 800;
            color: var(--text1); letter-spacing: -.03em;
            margin-bottom: 8px;
        }
        .success-sub {
            font-size: .875rem; color: var(--text2);
            margin-bottom: 28px; line-height: 1.6;
        }
        .success-bar {
            height: 4px;
            background: rgba(255,255,255,0.08);
            border-radius: 99px;
            overflow: hidden;
        }
        .success-bar-fill {
            height: 100%;
            background: var(--lime);
            border-radius: 99px;
            width: 0%;
            transition: width 2.5s linear;
        }

        /* ══════════════════════════════
           RESPONSIVE
        ══════════════════════════════ */
        @media (max-width: 900px) {
            body { overflow-y: auto; }
            .page { flex-direction: column; height: auto; min-height: 100vh; }
            .left-panel { padding: 48px 32px 40px; flex: none; }
            .right-panel { width: 100%; padding: 48px 32px; border-left: none; border-top: 1px solid var(--border); }
            .deco-card { display: none; }
        }
    </style>
</head>
<body>

<!-- ══ SUCCESS OVERLAY ══ -->
<div id="successOverlay">
    <div class="success-card">
        <div class="success-icon-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
        </div>
        <h2 class="success-title">Login Berhasil</h2>
        <p class="success-sub">Mengarahkan Anda ke Admin Portal...</p>
        <div class="success-bar"><div class="success-bar-fill" id="progressBar"></div></div>
    </div>
</div>

<!-- ══ MAIN PAGE ══ -->
<div class="page">

    <!-- LEFT PANEL -->
    <div class="left-panel">
        <div class="lp-inner">
            <span class="lp-logo">Kash.</span>

            <h1 class="lp-heading">
                Kelola Bisnis UMKM<br><span>Lebih Cerdas</span> &amp; Efisien
            </h1>
            <p class="lp-sub">
                Platform all-in-one untuk kasir digital, manajemen stok, laporan keuangan, dan analitik penjualan — semua dalam genggaman.
            </p>

            <div class="feature-list">
                <div class="feature-item">
                    <div class="feature-icon">🧾</div>
                    <div class="feature-text">
                        <h4>Kasir Digital Real-time</h4>
                        <p>Proses transaksi cepat dengan QRIS, tunai, dan transfer. Stok otomatis terupdate.</p>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">📊</div>
                    <div class="feature-text">
                        <h4>Laporan &amp; Analitik</h4>
                        <p>Pantau pendapatan, profit, dan tren penjualan harian, mingguan, hingga bulanan.</p>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">📦</div>
                    <div class="feature-text">
                        <h4>Manajemen Stok Cerdas</h4>
                        <p>Notifikasi stok menipis otomatis, kelola kategori dan produk dengan mudah.</p>
                    </div>
                </div>
            </div>

            <div class="stats-row">
                <div class="stat-item">
                    <div class="stat-val">10K+</div>
                    <div class="stat-label">UMKM Aktif</div>
                </div>
                <div class="stat-item">
                    <div class="stat-val">99.9%</div>
                    <div class="stat-label">Uptime</div>
                </div>
                <div class="stat-item">
                    <div class="stat-val">4.9★</div>
                    <div class="stat-label">Rating</div>
                </div>
            </div>
        </div>

        <!-- Floating decoration card -->
        <div class="deco-card">
            <div class="deco-card-avatar">📈</div>
            <div class="deco-card-txt">
                <p>Pendapatan hari ini</p>
                <span style="color: #BEF364; font-weight: 700;">Rp 4.280.000</span>
            </div>
        </div>
    </div>

    <!-- RIGHT PANEL (LOGIN FORM) -->
    <div class="right-panel">
        <div class="form-box">
            <a href="/" class="back-link">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
                Kembali ke Beranda
            </a>

            <div class="admin-badge">Admin Portal</div>

            <h1 class="form-title">Selamat Datang 👋</h1>
            <p class="form-sub">Masukkan detail akun Anda untuk mengakses dashboard.</p>

            @if ($errors->any())
                <div class="error-box">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    {{ $errors->first() }}
                </div>
            @endif

            <form method="POST" action="{{ route('login') }}" id="loginForm">
                @csrf

                <div class="field">
                    <label for="email">Alamat Email</label>
                    <input type="email" id="email" name="email"
                           value="{{ old('email') }}"
                           placeholder="nama@email.com"
                           required autofocus>
                </div>

                <div class="field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password"
                           placeholder="••••••••"
                           required>
                </div>

                <div class="options-row">
                    <label class="remember">
                        <input type="checkbox" name="remember"> Ingat saya
                    </label>
                </div>

                <button type="submit" class="btn-submit" id="submitBtn">
                    <div class="btn-shimmer"></div>
                    <span class="btn-text">Masuk ke Dashboard</span>
                    <div class="spinner"></div>
                </button>
            </form>
        </div>
    </div>

</div>

<script>
    const form      = document.getElementById('loginForm');
    const submitBtn = document.getElementById('submitBtn');
    const overlay   = document.getElementById('successOverlay');
    const progressBar = document.getElementById('progressBar');

    function showSuccess() {
        overlay.classList.add('show');
        // Start progress bar
        setTimeout(() => {
            progressBar.style.width = '100%';
        }, 100);
    }

    form.addEventListener('submit', function(e) {
        // Show loading on button
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;

        e.preventDefault();

        const formData = new FormData(form);

        fetch(form.action, {
            method: 'POST',
            body: formData,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(response => {
            // Jika berhasil login, Laravel akan mengalihkan (redirect) ke dashboard
            // Kita cek apakah url akhirnya mengarah ke '/admin/dashboard' atau '/' (bukan '/login')
            if (response.redirected && !response.url.includes('/login')) {
                showSuccess();
                setTimeout(() => {
                    window.location.href = response.url;
                }, 1500);
            } else {
                // Jika gagal (kembali ke halaman login), kirim form secara normal
                // agar error validation dari Laravel muncul di layar.
                form.submit();
            }
        })
        .catch(() => {
            // Network error fallback
            form.submit();
        });
    });
</script>

</body>
</html>
