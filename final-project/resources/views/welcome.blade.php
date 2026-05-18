<!DOCTYPE html>
<html lang="id" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KASH - Kasir Masa Depan untuk UMKM</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800;900&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { 
            background-color: #091421; 
            color: #FEFFF1; 
            font-family: 'Manrope', sans-serif; 
            overflow-x: hidden; 
        }
        h1, h2, h3, h4, h5, h6, .font-space { font-family: 'Space Grotesk', sans-serif; }
        
        .bg-grid {
            background-size: 40px 40px;
            background-image: linear-gradient(to right, rgba(255, 255, 255, 0.05) 1px, transparent 1px),
                              linear-gradient(to bottom, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
            mask-image: linear-gradient(to bottom, transparent, black, transparent);
            -webkit-mask-image: linear-gradient(to bottom, transparent 10%, black 50%, transparent 90%);
        }

        .blob-1 { position: absolute; width: 600px; height: 600px; background: radial-gradient(circle, rgba(190, 242, 100, 0.15) 0%, transparent 70%); top: -100px; left: 20%; filter: blur(40px); z-index: -1; pointer-events: none; }
        .blob-2 { position: absolute; width: 500px; height: 500px; background: radial-gradient(circle, rgba(52, 107, 241, 0.15) 0%, transparent 70%); top: 300px; right: 10%; filter: blur(40px); z-index: -1; pointer-events: none; }
        
        .glass { background: rgba(33, 43, 57, 0.6); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.1); }
        .glass-card { background: rgba(31, 41, 55, 0.4); backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; transition: all 0.3s ease; }
        .glass-card:hover { border-color: rgba(190, 242, 100, 0.5); transform: translateY(-5px); box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    </style>
</head>
<body class="antialiased relative selection:bg-[#BEF264] selection:text-black">

    <!-- Background Decoration -->
    <div class="fixed inset-0 pointer-events-none z-[-1]">
        <div class="absolute inset-0 bg-grid"></div>
        <div class="blob-1"></div>
        <div class="blob-2"></div>
    </div>

    <!-- Navbar -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-[#030712]/80 backdrop-blur-md border-b border-white/10">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <a href="/" class="text-[#A3E635] font-black text-2xl font-space tracking-tight">KASH</a>
            
            <div class="hidden md:flex items-center gap-8">
                <a href="#" class="text-gray-400 hover:text-white transition">Home</a>
                <a href="#pricing" class="text-[#A3E635] font-bold border-b-2 border-[#A3E635] pb-1">Pricing</a>
                <a href="#download" class="text-gray-400 hover:text-white transition">Download</a>
            </div>

            <div class="flex items-center gap-4">
                <div class="hidden sm:flex items-center gap-2 bg-[#A3E635]/10 border border-[#A3E635]/20 px-3 py-1.5 rounded-full">
                    <div class="w-2 h-2 rounded-full bg-[#A3E635] animate-pulse"></div>
                    <span class="text-[#A3E635] text-[10px] font-bold tracking-widest uppercase">SISTEM AKTIF</span>
                </div>
                @auth
                    <a href="{{ auth()->user()->role === 'admin' ? route('admin.dashboard') : '#' }}" class="text-gray-300 hover:text-white font-medium transition px-4 py-2">Dashboard</a>
                @else
                    <a href="{{ route('login') }}" class="text-gray-300 hover:text-white font-medium transition px-4 py-2">Masuk</a>
                @endauth
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="pt-40 pb-20 px-6 max-w-7xl mx-auto flex flex-col items-center text-center">
        <div class="inline-flex items-center gap-2 bg-[#2B3544] shadow-xl border border-white/10 rounded-full px-4 py-1 mb-8">
            <div class="w-2 h-2 rounded-full bg-[#BEF264] shadow-[0_0_8px_#BEF264]"></div>
            <span class="text-[#C3C9B2] text-sm font-space font-medium tracking-widest uppercase">V2.0 MELUNCUR</span>
        </div>
        
        <h1 class="text-5xl md:text-7xl font-bold font-space leading-tight mb-6 max-w-4xl">
            Kasir Masa Depan untuk <span class="text-[#BEF264]">UMKM</span>
        </h1>
        
        <p class="text-lg md:text-xl text-[#C3C9B2] max-w-2xl mb-10 leading-relaxed">
            Tingkatkan efisiensi bisnis Anda dengan sistem point-of-sale antigravitasi yang dirancang untuk kecepatan dan presisi absolut.
        </p>

        <div class="flex flex-col sm:flex-row items-center gap-4">
            <a href="#download" class="bg-[#BEF264] hover:bg-[#A3E635] text-[#4B6E00] font-bold font-space px-8 py-4 rounded-lg transition transform hover:-translate-y-1 shadow-lg">
                Download Gratis
            </a>
            <a href="#pricing" class="glass text-white font-semibold font-space px-8 py-4 rounded-lg transition hover:bg-white/10">
                Lihat Paket
            </a>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="border-t border-b border-white/10 bg-[#212B39]">
        <div class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-3 divide-y md:divide-y-0 md:divide-x divide-white/10">
            <div class="p-10 flex flex-col items-center text-center hover:bg-white/5 transition">
                <h3 class="text-4xl md:text-5xl font-bold font-space mb-2">15k+</h3>
                <p class="text-[#C3C9B2] text-sm font-space font-medium tracking-widest uppercase">Merchant Aktif</p>
            </div>
            <div class="p-10 flex flex-col items-center text-center hover:bg-white/5 transition relative overflow-hidden">
                <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-[#BEF264]/40 to-transparent"></div>
                <h3 class="text-4xl md:text-5xl font-bold font-space mb-2 text-[#BEF264]">Rp 1.2T</h3>
                <p class="text-[#C3C9B2] text-sm font-space font-medium tracking-widest uppercase">Transaksi</p>
            </div>
            <div class="p-10 flex flex-col items-center text-center hover:bg-white/5 transition">
                <h3 class="text-4xl md:text-5xl font-bold font-space mb-2">24/7</h3>
                <p class="text-[#C3C9B2] text-sm font-space font-medium tracking-widest uppercase">Support Penuh</p>
            </div>
        </div>
    </section>

    <!-- Core Infra -->
    <section class="py-24 px-6 max-w-5xl mx-auto flex flex-col items-center">
        <h2 class="text-3xl md:text-4xl font-semibold font-space mb-12 text-center">Infrastruktur Inti</h2>
        
        <div class="flex flex-wrap justify-center gap-6">
            <div class="bg-[#2B3544] border border-white/5 rounded-xl px-8 py-4 flex items-center gap-4 hover:border-[#BEF264]/50 transition">
                <div class="w-4 h-4 bg-[#BEF264] rotate-45"></div>
                <span class="font-space font-medium text-lg">Laporan Real-time</span>
            </div>
            <div class="bg-[#2B3544] border border-white/5 rounded-xl px-8 py-4 flex items-center gap-4 hover:border-[#BEF264]/50 transition">
                <div class="w-4 h-4 bg-[#BEF264] rounded-sm"></div>
                <span class="font-space font-medium text-lg">Manajemen Stok</span>
            </div>
            <div class="bg-[#2B3544] border border-white/5 rounded-xl px-8 py-4 flex items-center gap-4 hover:border-[#BEF264]/50 transition">
                <div class="w-4 h-4 bg-[#BEF264] rounded-full"></div>
                <span class="font-space font-medium text-lg">Integrasi QRIS</span>
            </div>
            <div class="bg-[#2B3544] border border-white/5 rounded-xl px-8 py-4 flex items-center gap-4 hover:border-[#BEF264]/50 transition">
                <div class="w-5 h-4 bg-[#BEF264] clip-polygon"></div>
                <span class="font-space font-medium text-lg">Offline Mode</span>
            </div>
        </div>
    </section>

    <!-- Download Section -->
    <section id="download" class="py-24 px-6 relative border-t border-white/5">
        <div class="absolute inset-0 bg-gradient-to-b from-[#BEF264]/5 to-transparent pointer-events-none"></div>
        <div class="max-w-7xl mx-auto relative z-10">
            <div class="text-center mb-16">
                <h2 class="text-4xl md:text-5xl font-bold font-space mb-4">Unduh Kash. Sekarang</h2>
                <p class="text-lg text-[#C3C9B2]">Pilih perangkat Anda dan mulai revolusi bisnis hari ini.</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Android -->
                <div class="glass-card p-8 flex flex-col items-center text-center">
                    <div class="w-16 h-16 bg-[#303A48] border border-[#434938] rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-[#D9E3F6]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 1.5H8.25A2.25 2.25 0 006 3.75v16.5a2.25 2.25 0 002.25 2.25h7.5A2.25 2.25 0 0018 20.25V3.75a2.25 2.25 0 00-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3"></path></svg>
                    </div>
                    <h3 class="text-xl font-space font-semibold mb-2">Mobile (Android)</h3>
                    <p class="text-[#8D937E] mb-8 flex-grow">Android 10.0 atau lebih baru</p>
                    <a href="#" class="w-full py-3 border border-white/20 rounded-lg text-sm font-space font-medium tracking-widest uppercase hover:bg-white/10 transition">Google Play</a>
                </div>
                <!-- iOS -->
                <div class="glass-card p-8 flex flex-col items-center text-center">
                    <div class="w-16 h-16 bg-[#303A48] border border-[#434938] rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-[#D9E3F6]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 1.5H8.25A2.25 2.25 0 006 3.75v16.5a2.25 2.25 0 002.25 2.25h7.5A2.25 2.25 0 0018 20.25V3.75a2.25 2.25 0 00-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3"></path></svg>
                    </div>
                    <h3 class="text-xl font-space font-semibold mb-2">Mobile (iOS)</h3>
                    <p class="text-[#8D937E] mb-8 flex-grow">iOS 14.0 atau lebih baru</p>
                    <a href="#" class="w-full py-3 border border-white/20 rounded-lg text-sm font-space font-medium tracking-widest uppercase hover:bg-white/10 transition">App Store</a>
                </div>
                <!-- Windows -->
                <div class="glass-card p-8 flex flex-col items-center text-center">
                    <div class="w-16 h-16 bg-[#303A48] border border-[#434938] rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-[#D9E3F6]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25"></path></svg>
                    </div>
                    <h3 class="text-xl font-space font-semibold mb-2">Desktop (Windows)</h3>
                    <p class="text-[#8D937E] mb-8 flex-grow">Windows 10 / 11 (64-bit)</p>
                    <a href="#" class="w-full py-3 bg-[#BEF264] text-[#4B6E00] rounded-lg text-sm font-space font-bold tracking-widest uppercase hover:bg-[#A3E635] transition">Unduh .exe</a>
                </div>
                <!-- macOS -->
                <div class="glass-card p-8 flex flex-col items-center text-center">
                    <div class="w-16 h-16 bg-[#303A48] border border-[#434938] rounded-xl flex items-center justify-center mb-6">
                        <svg class="w-8 h-8 text-[#D9E3F6]" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25"></path></svg>
                    </div>
                    <h3 class="text-xl font-space font-semibold mb-2">Desktop (macOS)</h3>
                    <p class="text-[#8D937E] mb-8 flex-grow">macOS 12.0+ (Apple Silicon / Intel)</p>
                    <a href="#" class="w-full py-3 bg-[#BEF264] text-[#4B6E00] rounded-lg text-sm font-space font-bold tracking-widest uppercase hover:bg-[#A3E635] transition">Unduh .dmg</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Steps CTA -->
    <section class="py-24 px-6 border-t border-white/5">
        <div class="max-w-5xl mx-auto">
            <h2 class="text-3xl md:text-4xl font-space font-semibold text-center mb-16">Mulai dalam Hitungan Detik</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-12 relative">
                <div class="hidden md:block absolute top-6 left-[16%] right-[16%] h-[1px] bg-gradient-to-r from-transparent via-white/20 to-transparent"></div>
                
                <div class="flex flex-col items-center text-center relative z-10">
                    <div class="w-12 h-12 bg-[#2B3544] border border-white/10 rounded-xl shadow-[0_0_15px_rgba(190,242,100,0.1)] flex items-center justify-center mb-6">
                        <div class="w-4 h-4 bg-[#BEF264] rotate-45"></div>
                    </div>
                    <h4 class="text-sm font-space font-medium tracking-widest uppercase mb-4">1. Unduh</h4>
                    <p class="text-[#8D937E] text-sm leading-relaxed">Pilih installer sesuai dengan sistem operasi perangkat Anda.</p>
                </div>
                
                <div class="flex flex-col items-center text-center relative z-10">
                    <div class="w-12 h-12 bg-[#2B3544] border border-white/10 rounded-xl shadow-[0_0_15px_rgba(190,242,100,0.1)] flex items-center justify-center mb-6">
                        <div class="w-5 h-5 bg-[#BEF264] rounded-sm"></div>
                    </div>
                    <h4 class="text-sm font-space font-medium tracking-widest uppercase mb-4">2. Instal</h4>
                    <p class="text-[#8D937E] text-sm leading-relaxed">Jalankan file installer dan ikuti petunjuk di layar hingga selesai.</p>
                </div>
                
                <div class="flex flex-col items-center text-center relative z-10">
                    <div class="w-12 h-12 bg-[#2B3544] border border-white/10 rounded-xl shadow-[0_0_15px_rgba(190,242,100,0.1)] flex items-center justify-center mb-6">
                        <div class="w-5 h-5 bg-[#BEF264] rounded-full"></div>
                    </div>
                    <h4 class="text-sm font-space font-medium tracking-widest uppercase mb-4">3. Mulai Transaksi</h4>
                    <p class="text-[#8D937E] text-sm leading-relaxed">Masuk dengan akun Anda dan rasakan pengalaman POS futuristik.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Pricing Section -->
    <section id="pricing" class="py-24 px-6 relative border-t border-white/5 overflow-hidden">
        <div class="absolute w-[500px] h-[500px] bg-[#BEF264]/10 rounded-full blur-[80px] -bottom-40 right-10 pointer-events-none"></div>
        <div class="absolute w-[600px] h-[600px] bg-[#346BF1]/10 rounded-full blur-[80px] -top-20 -left-20 pointer-events-none"></div>
        
        <div class="max-w-7xl mx-auto relative z-10">
            <div class="text-center mb-16">
                <h2 class="text-4xl md:text-5xl font-bold font-space mb-4">Pilih Paket yang Sesuai untuk Bisnis Anda</h2>
                <p class="text-lg text-[#C3C9B2]">Investasi cerdas untuk efisiensi tanpa batas.</p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Lite -->
                <div class="glass-card p-10 flex flex-col">
                    <h3 class="text-3xl font-space font-semibold mb-2">Lite</h3>
                    <div class="flex items-baseline gap-2 mb-4">
                        <span class="text-4xl font-space font-bold">Rp 0</span>
                        <span class="text-[#C3C9B2]">/bulan</span>
                    </div>
                    <p class="text-[#C3C9B2] mb-8 flex-grow">Mulai bisnis Anda dengan esensial tanpa hambatan.</p>
                    <a href="#" class="w-full py-3 border border-white/20 rounded-lg text-center font-bold hover:bg-white/10 transition mb-8">Mulai Gratis</a>
                    <div class="border-t border-white/10 pt-6 space-y-4">
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Fitur Dasar</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Laporan Harian</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">1 Outlet</span>
                        </div>
                    </div>
                </div>

                <!-- Pro -->
                <div class="glass-card p-10 flex flex-col relative border-[#BEF264]/30 shadow-[0_0_30px_rgba(190,242,100,0.1)] transform md:scale-105 z-10 bg-[#1f2937]/80">
                    <div class="absolute -top-3 left-1/2 -translate-x-1/2 bg-[#BEF264] text-black px-4 py-1 rounded-full text-[11px] font-space font-bold tracking-widest uppercase shadow-[0_0_15px_rgba(190,242,100,0.5)]">Recommended</div>
                    <h3 class="text-3xl font-space font-semibold mb-2">Pro</h3>
                    <div class="flex items-baseline gap-2 mb-4">
                        <span class="text-4xl font-space font-bold">Rp 149rb</span>
                        <span class="text-[#C3C9B2]">/bulan</span>
                    </div>
                    <p class="text-[#C3C9B2] mb-8 flex-grow">Akselerasi operasional dengan otomasi penuh.</p>
                    <a href="#" class="w-full py-3 bg-[#BEF264] text-black rounded-lg text-center font-bold hover:bg-[#A3E635] transition mb-8">Pilih Pro</a>
                    <div class="border-t border-white/10 pt-6 space-y-4">
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Fitur Lengkap</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Inventaris Otomatis</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">5 Outlet</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Support 24/7</span>
                        </div>
                    </div>
                </div>

                <!-- Enterprise -->
                <div class="glass-card p-10 flex flex-col">
                    <h3 class="text-3xl font-space font-semibold mb-2">Enterprise</h3>
                    <div class="flex items-baseline gap-2 mb-4">
                        <span class="text-4xl font-space font-bold">Custom</span>
                    </div>
                    <p class="text-[#C3C9B2] mb-8 flex-grow">Infrastruktur kustom untuk skala bisnis masif.</p>
                    <a href="#" class="w-full py-3 border border-white/20 rounded-lg text-center font-bold hover:bg-white/10 transition mb-8">Hubungi Sales</a>
                    <div class="border-t border-white/10 pt-6 space-y-4">
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Multi-cabang Tak Terbatas</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">API Access</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="w-2 h-2 bg-[#BEF264] rounded-full"></div>
                            <span class="text-[#D9E3F6]">Dedicated Account Manager</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- FAQ Simple -->
            <div class="mt-24 max-w-3xl mx-auto">
                <h3 class="text-3xl font-space font-semibold mb-8 text-center">Pertanyaan Umum</h3>
                <div class="space-y-4">
                    <div class="glass-card p-6 flex justify-between items-center cursor-pointer hover:bg-white/5">
                        <h4 class="font-semibold text-lg text-[#FEFFF1]">Apakah saya bisa upgrade paket kapan saja?</h4>
                        <div class="w-3 h-2 bg-[#C3C9B2] clip-arrow-down"></div>
                    </div>
                    <div class="glass-card p-6 flex justify-between items-center cursor-pointer hover:bg-white/5">
                        <h4 class="font-semibold text-lg text-[#FEFFF1]">Bagaimana sistem penagihan dilakukan?</h4>
                        <div class="w-3 h-2 bg-[#C3C9B2] clip-arrow-down"></div>
                    </div>
                    <div class="glass-card p-6 flex justify-between items-center cursor-pointer hover:bg-white/5">
                        <h4 class="font-semibold text-lg text-[#FEFFF1]">Apakah ada biaya tersembunyi saat setup?</h4>
                        <div class="w-3 h-2 bg-[#C3C9B2] clip-arrow-down"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-[#030712] border-t border-white/5 pt-12 pb-12">
        <div class="max-w-7xl mx-auto px-6">
            <div class="flex flex-col md:flex-row justify-between items-center gap-6">
                <div class="text-2xl font-bold font-space tracking-wider text-[rgba(255,255,255,0.9)]">Kash.</div>
                
                <div class="flex flex-wrap justify-center gap-6 md:gap-10 text-sm text-[#64748B]">
                    <a href="#" class="hover:text-white transition">Kebijakan Privasi</a>
                    <a href="#" class="hover:text-white transition">Syarat & Ketentuan</a>
                    <a href="#" class="hover:text-white transition">Dukungan</a>
                    <a href="#" class="hover:text-white transition">API</a>
                </div>
                
                <div class="text-[#64748B] text-sm">
                    © 2024 Kash POS. Indonesia's Next-Gen SME Infrastructure.
                </div>
            </div>
        </div>
    </footer>

    <style>
        .clip-polygon { clip-path: polygon(50% 0%, 100% 38%, 82% 100%, 18% 100%, 0% 38%); }
        .clip-arrow-down { clip-path: polygon(0 0, 50% 100%, 100% 0); }
    </style>
</body>
</html>
