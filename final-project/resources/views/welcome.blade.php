<!DOCTYPE html>
<html lang="id" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kash. - Kelola Keuangan UMKM Jadi Lebih Simpel</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@700;800&display=swap" rel="stylesheet">
    <style>
        body {
            background-color: #080C14;
            color: #FEFFF1;
            font-family: 'Inter', sans-serif;
            overflow-x: hidden;
        }
        h1, h2, h3, h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', sans-serif;
        }
    </style>
</head>
<body class="antialiased bg-[#080C14] text-slate-300">

    <!-- Header / Navbar -->
    <nav class="w-full py-6 px-6 sm:px-12 flex items-center justify-between max-w-7xl mx-auto">
        <!-- Logo -->
        <a href="/" class="flex items-center text-white font-extrabold text-2xl tracking-tight">
            Kash<span class="text-[#BEF264]">.</span>
        </a>

        <!-- Middle Navigation Links -->
        <div class="hidden md:flex items-center gap-10">
            <a href="#" class="text-[#BEF264] font-semibold border-b-2 border-[#BEF264] pb-1 text-sm tracking-wide transition duration-200">Fitur</a>
            <a href="#pricing" class="text-slate-400 hover:text-white font-medium text-sm tracking-wide transition duration-200">Harga</a>
            <a href="#" class="text-slate-400 hover:text-white font-medium text-sm tracking-wide transition duration-200">Blog</a>
            <a href="#" class="text-slate-400 hover:text-white font-medium text-sm tracking-wide transition duration-200">Kontak</a>
        </div>

        <!-- Right Side Button -->
        <div class="flex items-center gap-4">
            @auth
                <a href="{{ auth()->user()->role === 'admin' ? route('admin.dashboard') : '#' }}" class="text-slate-400 hover:text-white font-medium transition text-sm">Dashboard</a>
            @else
                <a href="{{ route('login') }}" class="text-slate-400 hover:text-white font-medium transition text-sm">Masuk</a>
            @endauth
            <a href="/downloads/kash.apk" download class="bg-[#BEF264] text-[#080C14] font-bold px-6 py-2.5 rounded-full hover:bg-[#a3e635] transition duration-300 text-sm">
                Download Gratis
            </a>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="flex flex-col items-center justify-center pt-20 pb-24 px-6 max-w-5xl mx-auto text-center">
        <!-- Top Pill Badge -->
        <div class="inline-flex items-center justify-center bg-[#BEF264]/10 border border-[#BEF264]/20 rounded-full px-4 py-1.5 mb-8">
            <span class="text-[#BEF264] text-[11px] font-bold tracking-widest uppercase">GRATIS UNTUK UMKM</span>
        </div>

        <!-- Main Title Heading -->
        <h1 class="text-4xl sm:text-6xl md:text-7xl font-extrabold tracking-tight leading-[1.15] mb-8 text-white max-w-4xl">
            Kelola Keuangan<br>
            UMKM Jadi Lebih<br>
            <span class="text-[#BEF264]">Simpel</span>
        </h1>

        <!-- Subheading Paragraph -->
        <p class="text-slate-400 text-base sm:text-lg max-w-xl leading-relaxed mb-12">
            Catat stok, transaksi, dan laporan keuangan dalam satu aplikasi. Pantau bisnismu kapan saja, di mana saja dengan dashboard real-time yang didesain khusus untuk pengusaha lokal.
        </p>

        <!-- Call-to-action buttons -->
        <div class="flex flex-col sm:flex-row gap-4 items-center justify-center mb-16">
            <!-- Button PC -->
            <a href="/downloads/kash-windows.zip" download class="flex items-center gap-2.5 bg-[#BEF264] text-[#080C14] font-bold px-8 py-4 rounded-full hover:bg-[#a3e635] transition duration-300 shadow-[0_8px_30px_rgba(190,242,100,0.15)]">
                <!-- Monitor SVG Icon -->
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                    <rect width="18" height="12" x="3" y="4" rx="2"></rect>
                    <path d="M12 16v4M8 20h8"></path>
                </svg>
                <span>Download di PC</span>
            </a>
            <!-- Button HP -->
            <a href="/downloads/kash.apk" download class="flex items-center gap-2.5 border border-[#BEF264] text-[#BEF264] font-bold px-8 py-4 rounded-full hover:bg-[#BEF264]/10 transition duration-300">
                <!-- Smartphone SVG Icon -->
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.2">
                    <rect width="12" height="18" x="6" y="3" rx="2.5"></rect>
                    <path d="M12 17h.01"></path>
                </svg>
                <span>Download di HP</span>
            </a>
        </div>

        <!-- Social Proof / Trust Badge -->
        <div class="flex items-center justify-center gap-3">
            <div class="flex -space-x-3 overflow-hidden">
                <!-- Profile Avatar 1 -->
                <img class="inline-block h-9 w-9 rounded-full ring-2 ring-[#080C14] object-cover" 
                     src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80" 
                     alt="Merchant 1">
                <!-- Profile Avatar 2 -->
                <img class="inline-block h-9 w-9 rounded-full ring-2 ring-[#080C14] object-cover" 
                     src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80" 
                     alt="Merchant 2">
                <!-- Profile Avatar 3 -->
                <img class="inline-block h-9 w-9 rounded-full ring-2 ring-[#080C14] object-cover" 
                     src="https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80" 
                     alt="Merchant 3">
            </div>
            <p class="text-slate-400 text-xs sm:text-sm tracking-wide">
                Dipercaya oleh <span class="text-[#BEF264] font-bold">10,000+</span> UMKM di Indonesia
            </p>
        </div>
    </section>

    <!-- Features Section -->
    <section class="max-w-7xl mx-auto px-6 sm:px-12 w-full mb-32">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Card 1: Manajemen Stok -->
            <div class="bg-[#121824] p-10 rounded-3xl border border-white/[0.03] flex flex-col items-start transition duration-300 hover:translate-y-[-6px] hover:border-[#BEF264]/20 hover:shadow-[0_12px_40px_rgba(0,0,0,0.4)]">
                <!-- Package Icon -->
                <div class="bg-[#BEF264]/10 p-3.5 rounded-2xl mb-8 border border-[#BEF264]/20">
                    <svg class="w-8 h-8 text-[#BEF264]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z" stroke-linecap="round" stroke-linejoin="round"></path>
                        <path d="m3.3 7 8.7 5 8.7-5M12 22V12" stroke-linecap="round" stroke-linejoin="round"></path>
                    </svg>
                </div>
                <h3 class="text-white text-xl font-bold mb-4">Manajemen Stok</h3>
                <p class="text-slate-400 text-sm leading-relaxed">
                    Kelola inventaris barang secara akurat dengan notifikasi stok menipis otomatis.
                </p>
            </div>

            <!-- Card 2: Invoice Digital -->
            <div class="bg-[#121824] p-10 rounded-3xl border border-white/[0.03] flex flex-col items-start transition duration-300 hover:translate-y-[-6px] hover:border-[#BEF264]/20 hover:shadow-[0_12px_40px_rgba(0,0,0,0.4)]">
                <!-- Receipt Icon -->
                <div class="bg-[#BEF264]/10 p-3.5 rounded-2xl mb-8 border border-[#BEF264]/20">
                    <svg class="w-8 h-8 text-[#BEF264]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1-2.5-2.5Z" stroke-linecap="round" stroke-linejoin="round"></path>
                        <path d="M6 6h10M6 10h10M6 14h8" stroke-linecap="round" stroke-linejoin="round"></path>
                    </svg>
                </div>
                <h3 class="text-white text-xl font-bold mb-4">Invoice Digital</h3>
                <p class="text-slate-400 text-sm leading-relaxed">
                    Kirim tagihan ke pelanggan via WhatsApp hanya dalam satu kali klik saja.
                </p>
            </div>

            <!-- Card 3: Laporan Real-time -->
            <div class="bg-[#121824] p-10 rounded-3xl border border-white/[0.03] flex flex-col items-start transition duration-300 hover:translate-y-[-6px] hover:border-[#BEF264]/20 hover:shadow-[0_12px_40px_rgba(0,0,0,0.4)]">
                <!-- Trend/Chart Icon -->
                <div class="bg-[#BEF264]/10 p-3.5 rounded-2xl mb-8 border border-[#BEF264]/20">
                    <svg class="w-8 h-8 text-[#BEF264]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M3 3v18h18" stroke-linecap="round" stroke-linejoin="round"></path>
                        <path d="m19 9-5 5-4-4-3 3" stroke-linecap="round" stroke-linejoin="round"></path>
                        <circle cx="19" cy="9" r="1.5" fill="currentColor"></circle>
                        <circle cx="14" cy="14" r="1.5" fill="currentColor"></circle>
                        <circle cx="10" cy="10" r="1.5" fill="currentColor"></circle>
                        <circle cx="7" cy="13" r="1.5" fill="currentColor"></circle>
                    </svg>
                </div>
                <h3 class="text-white text-xl font-bold mb-4">Laporan Real-time</h3>
                <p class="text-slate-400 text-sm leading-relaxed">
                    Lihat laba rugi dan performa harian melalui grafik yang mudah dimengerti.
                </p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="w-full bg-[#05080F] border-t border-white/[0.03] pt-20 pb-12 px-6 sm:px-12">
        <div class="max-w-7xl mx-auto">
            <!-- Footer Content Grid -->
            <div class="grid grid-cols-1 md:grid-cols-12 gap-12 md:gap-8 mb-16">
                <!-- Logo & Slogan Column -->
                <div class="md:col-span-6 flex flex-col items-start">
                    <a href="/" class="text-white font-extrabold text-2xl tracking-tight mb-4">
                        Kash<span class="text-[#BEF264]">.</span>
                    </a>
                    <p class="text-slate-400 text-sm leading-relaxed max-w-sm mb-6">
                        Solusi cerdas pencatatan keuangan digital untuk UMKM maju dan modern.
                    </p>
                    <!-- Social/Action Icons -->
                    <div class="flex items-center gap-4 text-slate-500">
                        <a href="#" class="hover:text-[#BEF264] transition">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="2" y1="12" x2="22" y2="12"></line>
                                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
                            </svg>
                        </a>
                        <a href="#" class="hover:text-[#BEF264] transition">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                <polyline points="22,6 12,13 2,6"></polyline>
                            </svg>
                        </a>
                        <a href="#" class="hover:text-[#BEF264] transition">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                <line x1="16" y1="2" x2="16" y2="6"></line>
                                <line x1="8" y1="2" x2="8" y2="6"></line>
                                <line x1="3" y1="10" x2="21" y2="10"></line>
                            </svg>
                        </a>
                    </div>
                </div>

                <!-- Link Columns -->
                <!-- Column 1: Produk -->
                <div class="md:col-span-2 flex flex-col gap-4">
                    <h4 class="text-white font-bold text-sm tracking-wider">Produk</h4>
                    <div class="flex flex-col gap-2.5 text-sm">
                        <a href="#" class="text-slate-400 hover:text-white transition">Fitur</a>
                        <a href="#pricing" class="text-slate-400 hover:text-white transition">Harga</a>
                        <a href="#" class="text-slate-400 hover:text-white transition">Integrasi</a>
                    </div>
                </div>

                <!-- Column 2: Perusahaan -->
                <div class="md:col-span-2 flex flex-col gap-4">
                    <h4 class="text-white font-bold text-sm tracking-wider">Perusahaan</h4>
                    <div class="flex flex-col gap-2.5 text-sm">
                        <a href="#" class="text-slate-400 hover:text-white transition">Blog</a>
                        <a href="#" class="text-slate-400 hover:text-white transition">Karir</a>
                        <a href="#" class="text-slate-400 hover:text-white transition">Kontak</a>
                    </div>
                </div>

                <!-- Column 3: Legal -->
                <div class="md:col-span-2 flex flex-col gap-4">
                    <h4 class="text-white font-bold text-sm tracking-wider">Legal</h4>
                    <div class="flex flex-col gap-2.5 text-sm">
                        <a href="#" class="text-slate-400 hover:text-white transition">Privasi</a>
                        <a href="#" class="text-slate-400 hover:text-white transition">Syarat</a>
                    </div>
                </div>
            </div>

            <!-- Bottom Divider & Copyright -->
            <div class="border-t border-white/[0.05] pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
                <p>© 2026 Kash. Solusi Keuangan UMKM Indonesia.</p>
            </div>
        </div>
    </footer>
</body>
</html>
