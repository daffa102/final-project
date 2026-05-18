@extends('layouts.admin')
@section('page-title', 'Dashboard')

@section('content')

<div class="page-head">
    <h2>Account Monitoring</h2>
    <p>Overview real-time aktivitas dan pertumbuhan pengguna NeoPay</p>
</div>

{{-- Stat Cards --}}
<div class="row g-3 mb-4" id="section-overview">
    <div class="col-12 col-sm-4">
        <div class="stat-card sc-black">
            <div>
                <div class="sc-label">Total Accounts</div>
                <div class="sc-value">{{ $totalUsers }}</div>
                <div class="sc-foot">All registered users</div>
            </div>
            <div class="sc-icon"><i class="bi bi-people-fill"></i></div>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="stat-card sc-teal">
            <div>
                <div class="sc-label">Active Users</div>
                <div class="sc-value">{{ $activeUsers }}</div>
                <div class="sc-foot">Login dalam 7 hari terakhir</div>
            </div>
            <div class="sc-icon"><i class="bi bi-person-check-fill"></i></div>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="stat-card sc-indigo">
            <div>
                <div class="sc-label">Inactive</div>
                <div class="sc-value">{{ $inactiveUsers }}</div>
                <div class="sc-foot">Tidak aktif 7+ hari</div>
            </div>
            <div class="sc-icon"><i class="bi bi-person-x-fill"></i></div>
        </div>
    </div>
</div>

{{-- Chart --}}
<div class="row g-3 mb-4">
    <div class="col-12 col-lg-8">
        <div class="card">
            <div class="card-head">
                <h4><i class="bi bi-graph-up-arrow"></i>Application Growth</h4>
                <span class="card-head-meta">Registrasi baru per bulan</span>
            </div>
            <div class="card-body">
                <canvas id="registrationChart" height="95"
                    data-labels="{{ $chartData->pluck('month')->toJson() }}"
                    data-counts="{{ $chartData->pluck('count')->toJson() }}">
                </canvas>
            </div>
        </div>
    </div>
    <div class="col-12 col-lg-4">
        <div class="card h-100">
            <div class="card-head">
                <h4><i class="bi bi-activity"></i>Quick Stats</h4>
            </div>
            <div class="card-body">
                <div class="qs-row">
                    <span class="qs-label">Active Rate</span>
                    <span class="qs-val" style="color:#2dd4bf;">
                        {{ $totalUsers > 0 ? round(($activeUsers / $totalUsers) * 100) : 0 }}%
                    </span>
                </div>
                <div class="qs-row">
                    <span class="qs-label">Inactive Rate</span>
                    <span class="qs-val" style="color:#6b7280;">
                        {{ $totalUsers > 0 ? round(($inactiveUsers / $totalUsers) * 100) : 0 }}%
                    </span>
                </div>
                <div class="qs-row">
                    <span class="qs-label">Monthly Growth</span>
                    <span class="qs-val" style="color:#a5b4fc;">
                        +{{ $chartData->count() > 0 ? $chartData->last()->count : 0 }} users
                    </span>
                </div>
            </div>
            {{-- Quick nav to pages --}}
            <div style="padding:0 22px 20px;">
                <a href="{{ route('admin.users.index') }}" class="dash-nav-btn">
                    <i class="bi bi-people-fill"></i> Kelola Users <i class="bi bi-arrow-right ms-auto"></i>
                </a>
                <a href="{{ route('admin.analytics') }}" class="dash-nav-btn mt-2">
                    <i class="bi bi-bar-chart-line-fill"></i> Lihat Analytics <i class="bi bi-arrow-right ms-auto"></i>
                </a>
            </div>
        </div>
    </div>
</div>

@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    const canvas = document.getElementById('registrationChart');
    if (!canvas) return;
    const ctx    = canvas.getContext('2d');
    const labels = JSON.parse(canvas.dataset.labels || '[]');
    const counts = JSON.parse(canvas.dataset.counts || '[]');
    const grad   = ctx.createLinearGradient(0, 0, 0, 200);
    grad.addColorStop(0, 'rgba(99,102,241,0.22)');
    grad.addColorStop(1, 'rgba(99,102,241,0.00)');
    new Chart(ctx, {
        type: 'line',
        data: { labels, datasets: [{ label:'New Users', data: counts,
            borderColor:'#6366f1', backgroundColor: grad, borderWidth:2.5,
            tension:0.45, fill:true,
            pointBackgroundColor:'#1e1e1e', pointBorderColor:'#6366f1',
            pointBorderWidth:2.5, pointRadius:5, pointHoverRadius:7 }]
        },
        options: { responsive:true, plugins:{ legend:{ display:false },
            tooltip:{ backgroundColor:'#1e1e1e', borderColor:'rgba(255,255,255,0.08)',
                borderWidth:1, titleFont:{family:'Inter',size:12},
                bodyFont:{family:'Inter',size:14,weight:'700'}, padding:14,
                cornerRadius:10, displayColors:false,
                callbacks:{ label: c => c.parsed.y + ' new users' }}},
            scales:{ y:{ beginAtZero:true, grid:{color:'rgba(255,255,255,0.04)'},
                border:{display:false}, ticks:{color:'#4b5563',font:{family:'Inter',size:11},padding:10,precision:0}},
                x:{ grid:{display:false}, border:{display:false},
                ticks:{color:'#4b5563',font:{family:'Inter',size:11},padding:10}}}
        }
    });
});
</script>
@endpush
