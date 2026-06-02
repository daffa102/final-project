@extends('layouts.admin')
@section('page-title', 'Analytics')

@section('content')

<div class="page-head">
    <h2>Analytics</h2>
    <p>Visualisasi data pertumbuhan dan aktivitas pengguna Kash.</p>
</div>

{{-- Summary Cards --}}
<div class="row g-3 mb-4">
    <div class="col-12 col-sm-4">
        <div class="stat-card sc-black">
            <div>
                <div class="sc-label">Total Accounts</div>
                <div class="sc-value">{{ $totalUsers }}</div>
                <div class="sc-foot">Semua pengguna terdaftar</div>
            </div>
            <div class="sc-icon"><i class="bi bi-people-fill"></i></div>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="stat-card sc-teal">
            <div>
                <div class="sc-label">Active Users</div>
                <div class="sc-value">{{ $activeUsers }}</div>
                <div class="sc-foot">Login 7 hari terakhir</div>
            </div>
            <div class="sc-icon"><i class="bi bi-person-check-fill"></i></div>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="stat-card sc-indigo">
            <div>
                <div class="sc-label">Active Rate</div>
                <div class="sc-value">{{ $totalUsers > 0 ? round(($activeUsers / $totalUsers) * 100) : 0 }}%</div>
                <div class="sc-foot">Persentase pengguna aktif</div>
            </div>
            <div class="sc-icon"><i class="bi bi-percent"></i></div>
        </div>
    </div>
</div>

<div class="row g-3 mb-4">
    {{-- Monthly Growth Chart --}}
    <div class="col-12 col-lg-7">
        <div class="card">
            <div class="card-head">
                <h4><i class="bi bi-graph-up-arrow"></i>Monthly Growth</h4>
                <span class="card-head-meta">Registrasi baru per bulan</span>
            </div>
            <div class="card-body">
                <canvas id="monthlyChart" height="120"
                    data-labels="{{ $chartData->pluck('month')->toJson() }}"
                    data-counts="{{ $chartData->pluck('count')->toJson() }}">
                </canvas>
            </div>
        </div>
    </div>

    {{-- Daily Registrations (last 30 days) --}}
    <div class="col-12 col-lg-5">
        <div class="card">
            <div class="card-head">
                <h4><i class="bi bi-calendar3"></i>Daily (30 Days)</h4>
                <span class="card-head-meta">Hari ini vs kemarin</span>
            </div>
            <div class="card-body">
                <canvas id="dailyChart" height="120"
                    data-labels="{{ $dailyData->pluck('day')->toJson() }}"
                    data-counts="{{ $dailyData->pluck('count')->toJson() }}">
                </canvas>
            </div>
        </div>
    </div>
</div>

{{-- Status Breakdown --}}
<div class="row g-3">
    <div class="col-12 col-md-6">
        <div class="card">
            <div class="card-head">
                <h4><i class="bi bi-pie-chart-fill"></i>User Status</h4>
            </div>
            <div class="card-body d-flex align-items-center gap-4">
                <canvas id="statusChart" width="130" height="130" style="flex-shrink:0;"
                    data-active="{{ $activeUsers }}"
                    data-inactive="{{ $inactiveUsers }}"></canvas>
                <div style="flex:1;">
                    <div class="qs-row">
                        <div class="d-flex align-items-center gap-2 qs-label">
                            <span style="width:10px;height:10px;border-radius:50%;background:#2dd4bf;display:inline-block;"></span>
                            Active Users
                        </div>
                        <span class="qs-val" style="color:#2dd4bf;">{{ $activeUsers }}</span>
                    </div>
                    <div class="qs-row">
                        <div class="d-flex align-items-center gap-2 qs-label">
                            <span style="width:10px;height:10px;border-radius:50%;background:#6b7280;display:inline-block;"></span>
                            Inactive Users
                        </div>
                        <span class="qs-val" style="color:#9ca3af;">{{ $inactiveUsers }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-6">
        <div class="card">
            <div class="card-head">
                <h4><i class="bi bi-info-circle"></i>Summary</h4>
            </div>
            <div class="card-body">
                <div class="qs-row">
                    <span class="qs-label">Total Registered</span>
                    <span class="qs-val">{{ $totalUsers }} users</span>
                </div>
                <div class="qs-row">
                    <span class="qs-label">Active Rate</span>
                    <span class="qs-val" style="color:#2dd4bf;">{{ $totalUsers > 0 ? round(($activeUsers / $totalUsers) * 100) : 0 }}%</span>
                </div>
                <div class="qs-row">
                    <span class="qs-label">Monthly Peak</span>
                    <span class="qs-val" style="color:#BEF364;">
                        {{ $chartData->count() > 0 ? $chartData->sortByDesc('count')->first()->count : 0 }} users
                    </span>
                </div>
                <div class="qs-row">
                    <span class="qs-label">Last 30 Days</span>
                    <span class="qs-val">{{ $dailyData->sum('count') }} registrations</span>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    // ── Monthly Line Chart ──
    const mc = document.getElementById('monthlyChart');
    if (mc) {
        const ctx = mc.getContext('2d');
        const grad = ctx.createLinearGradient(0, 0, 0, 180);
        grad.addColorStop(0, 'rgba(190,243,100,0.22)');
        grad.addColorStop(1, 'rgba(190,243,100,0)');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: JSON.parse(mc.dataset.labels || '[]'),
                datasets: [{ label: 'New Users', data: JSON.parse(mc.dataset.counts || '[]'),
                    borderColor: '#BEF364', backgroundColor: grad, borderWidth: 2.5,
                    tension: 0.45, fill: true, pointBackgroundColor: '#1e1e1e',
                    pointBorderColor: '#BEF364', pointBorderWidth: 2, pointRadius: 4 }]
            },
            options: chartOpts('new users per month')
        });
    }

    // ── Daily Bar Chart ──
    const dc = document.getElementById('dailyChart');
    if (dc) {
        new Chart(dc.getContext('2d'), {
            type: 'bar',
            data: {
                labels: JSON.parse(dc.dataset.labels || '[]'),
                datasets: [{ label: 'Registrations', data: JSON.parse(dc.dataset.counts || '[]'),
                    backgroundColor: 'rgba(20,184,166,0.5)',
                    borderColor: '#14b8a6', borderWidth: 1.5, borderRadius: 6 }]
            },
            options: chartOpts('registrations')
        });
    }

    // ── Donut Status Chart ──
    const sc = document.getElementById('statusChart');
    if (sc) {
        const activeCount   = parseInt(sc.dataset.active   || '0');
        const inactiveCount = parseInt(sc.dataset.inactive || '0');
        new Chart(sc.getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Active', 'Inactive'],
                datasets: [{ data: [activeCount, inactiveCount],
                    backgroundColor: ['#2dd4bf', '#6b7280'],
                    borderColor: '#1e1e1e', borderWidth: 3, hoverOffset: 4 }]
            },
            options: {
                responsive: false, cutout: '72%',
                plugins: { legend: { display: false }, tooltip: {
                    backgroundColor: '#1e1e1e', borderColor: 'rgba(255,255,255,.08)',
                    borderWidth: 1, padding: 12, cornerRadius: 10,
                    bodyFont: { family: 'Inter', weight: '700' }, displayColors: true
                }}
            }
        });
    }

    function chartOpts(unit) {
        return {
            responsive: true,
            plugins: {
                legend: { display: false },
                tooltip: { backgroundColor: '#1e1e1e', borderColor: 'rgba(255,255,255,.08)',
                    borderWidth: 1, titleFont: { family: 'Inter', size: 12 },
                    bodyFont: { family: 'Inter', size: 13, weight: '700' },
                    padding: 12, cornerRadius: 10, displayColors: false,
                    callbacks: { label: c => c.parsed.y + ' ' + unit }
                }
            },
            scales: {
                y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.04)' },
                    border: { display: false },
                    ticks: { color: '#4b5563', font: { family: 'Inter', size: 11 }, padding: 8, precision: 0 }
                },
                x: { grid: { display: false }, border: { display: false },
                    ticks: { color: '#4b5563', font: { family: 'Inter', size: 10 }, padding: 8 }
                }
            }
        };
    }
});
</script>
@endpush
