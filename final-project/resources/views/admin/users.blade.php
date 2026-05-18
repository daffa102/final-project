@extends('layouts.admin')
@section('page-title', 'User Management')

@section('content')

<div class="page-head d-flex align-items-center justify-content-between flex-wrap gap-3">
    <div>
        <h2>User Management</h2>
        <p>Kelola semua akun pengguna NeoPay yang terdaftar</p>
    </div>
    <button class="btn-primary-custom" onclick="openAddUserModal()">
        <i class="bi bi-person-plus-fill me-2"></i>Tambah User Baru
    </button>
</div>

{{-- Mini stat bar --}}
<div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
        <div class="mini-stat">
            <div class="mini-stat-icon" style="background:rgba(99,102,241,.15);color:#a5b4fc;">
                <i class="bi bi-people-fill"></i>
            </div>
            <div>
                <div class="mini-stat-val">{{ $totalUsers }}</div>
                <div class="mini-stat-label">Total Users</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="mini-stat">
            <div class="mini-stat-icon" style="background:rgba(20,184,166,.12);color:#2dd4bf;">
                <i class="bi bi-person-check-fill"></i>
            </div>
            <div>
                <div class="mini-stat-val">{{ $activeUsers }}</div>
                <div class="mini-stat-label">Active (7 days)</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4">
        <div class="mini-stat">
            <div class="mini-stat-icon" style="background:rgba(239,68,68,.10);color:#f87171;">
                <i class="bi bi-person-x-fill"></i>
            </div>
            <div>
                <div class="mini-stat-val">{{ $inactiveUsers }}</div>
                <div class="mini-stat-label">Inactive</div>
            </div>
        </div>
    </div>
</div>

{{-- Table Card --}}
<div class="card">
    <div class="card-head">
        <h4><i class="bi bi-person-lines-fill"></i>All Users</h4>
        {{-- Search --}}
        <form method="GET" action="{{ route('admin.users.index') }}" class="d-flex gap-2">
            <input type="text" name="search" value="{{ $search ?? '' }}"
                placeholder="Cari nama / email..."
                class="search-input"
                style="background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);
                       color:#f3f4f6;padding:7px 14px;border-radius:10px;font-size:.82rem;
                       outline:none;width:220px;">
            <button type="submit" style="padding:7px 14px;border-radius:10px;background:var(--accent);
                    border:none;color:#fff;font-size:.82rem;font-weight:600;cursor:pointer;">
                <i class="bi bi-search"></i>
            </button>
            @if($search)
            <a href="{{ route('admin.users.index') }}" style="padding:7px 12px;border-radius:10px;
                    background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.08);
                    color:#9ca3af;font-size:.82rem;text-decoration:none;display:flex;align-items:center;">
                <i class="bi bi-x"></i>
            </a>
            @endif
        </form>
    </div>

    <div class="card-body-0">
        @if(session('success'))
            <div class="alert alert-success mx-4 mt-4">
                <i class="bi bi-check-circle-fill me-2"></i>{{ session('success') }}
            </div>
        @endif
        @if(session('error'))
            <div class="alert alert-danger mx-4 mt-4">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>{{ session('error') }}
            </div>
        @endif

        @if($errors->any())
            <div class="alert alert-danger mx-4 mt-4">
                <ul class="mb-0">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if($search)
            <div style="padding:10px 24px;font-size:.8rem;color:#6b7280;">
                Menampilkan hasil untuk: <strong style="color:#a5b4fc;">{{ $search }}</strong>
                — {{ $users->total() }} user ditemukan
            </div>
        @endif

        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead>
                    <tr>
                        <th style="padding-left:24px;width:25%;">User</th>
                        <th>Email</th>
                        <th>WhatsApp</th>
                        <th>Registered</th>
                        <th>Last Login</th>
                        <th>Status</th>
                        <th style="text-align:center;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($users as $user)
                    @php $isActive = $user->last_login_at && $user->last_login_at->diffInDays(now()) < 7; @endphp
                    <tr>
                        <td style="padding-left:24px;">
                            <div class="d-flex align-items-center gap-3">
                                <div class="u-avatar">{{ strtoupper(substr($user->name, 0, 1)) }}</div>
                                <div>
                                    <div class="u-name">{{ $user->name }}</div>
                                    <div class="u-id">ID #{{ $user->id }}</div>
                                </div>
                            </div>
                        </td>
                        <td>{{ $user->email }}</td>
                        <td>
                            @if($user->phone)
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-whatsapp text-success" style="font-size:.85rem;"></i>
                                    <span style="font-size:.82rem;">{{ $user->phone }}</span>
                                </div>
                            @else
                                <span style="color:var(--text-3);font-size:.75rem;font-style:italic;">Belum diatur</span>
                            @endif
                        </td>
                        <td>
                            <div style="font-size:.82rem;">{{ $user->created_at->format('d M Y') }}</div>
                        </td>
                        <td>
                            @if($user->last_login_at)
                                <div style="font-size:.82rem;font-weight:500;color:var(--text-1);">{{ $user->last_login_at->diffForHumans() }}</div>
                                <div style="font-size:.7rem;color:var(--text-3);">{{ $user->last_login_at->format('d M Y, H:i') }}</div>
                            @else
                                <span style="color:var(--text-3);font-style:italic;font-size:.8rem;">Belum pernah login</span>
                            @endif
                        </td>
                        <td>
                            @if($isActive)
                                <span class="badge badge-active"><i class="bi bi-circle-fill" style="font-size:.45rem;"></i>Active</span>
                            @else
                                <span class="badge badge-inactive"><i class="bi bi-circle" style="font-size:.45rem;"></i>Inactive</span>
                            @endif
                        </td>
                        <td style="text-align:center;">
                            <div class="d-flex justify-content-center gap-2">
                                {{-- Reset Password Action --}}
                                <button type="button" class="btn-action-custom" title="Reset Password"
                                    onclick="openResetPasswordModal('{{ $user->id }}', '{{ addslashes($user->name) }}')">
                                    <i class="bi bi-key-fill"></i>
                                </button>

                                {{-- Delete Action --}}
                                <form id="del-form-{{ $user->id }}" action="{{ route('admin.users.destroy', $user) }}" method="POST" class="m-0">
                                    @csrf
                                    @method('DELETE')
                                    <button type="button" class="btn-del"
                                        onclick="openDelModal('del-form-{{ $user->id }}', '{{ addslashes($user->name) }}')">
                                        <i class="bi bi-trash3-fill"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" style="text-align:center;padding:48px;color:var(--text-3);">
                            <i class="bi bi-people" style="font-size:2rem;display:block;margin-bottom:10px;"></i>
                            {{ $search ? 'Tidak ada user yang cocok dengan pencarian.' : 'Belum ada user yang terdaftar.' }}
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
            <div class="p-4 d-flex justify-content-end">
                {{ $users->links('pagination::bootstrap-5') }}
            </div>
        @endif
    </div>
</div>

{{-- ── Add User Modal ── --}}
<div class="del-modal-backdrop" id="addUserModal">
    <div class="del-modal" style="max-width: 450px; text-align: left;">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h5 class="mb-0" style="color: #f3f4f6; font-size: 1.25rem;">Tambah User Baru</h5>
            <button class="btn-close btn-close-white" onclick="closeAddUserModal()"></button>
        </div>
        
        <form action="{{ route('admin.users.store') }}" method="POST">
            @csrf
            <div class="mb-3">
                <label class="form-label" style="color: #9ca3af; font-size: .8rem; font-weight: 600;">NAMA LENGKAP</label>
                <input type="text" name="name" class="form-control-custom" placeholder="Masukkan nama user" required>
            </div>
            <div class="mb-3">
                <label class="form-label" style="color: #9ca3af; font-size: .8rem; font-weight: 600;">EMAIL</label>
                <input type="email" name="email" class="form-control-custom" placeholder="user@email.com" required>
            </div>
            <div class="mb-3">
                <label class="form-label" style="color: #9ca3af; font-size: .8rem; font-weight: 600;">NOMOR WHATSAPP</label>
                <input type="text" name="phone" class="form-control-custom" placeholder="08xxxxxx">
            </div>
            <div class="mb-4">
                <label class="form-label" style="color: #9ca3af; font-size: .8rem; font-weight: 600;">PASSWORD DEFAULT</label>
                <input type="password" name="password" id="add_user_password" class="form-control-custom" placeholder="Min. 8 karakter" required>
                <div class="mt-2 d-flex align-items-center gap-2">
                    <input type="checkbox" id="show_add_pass" onclick="togglePass('add_user_password')">
                    <label for="show_add_pass" style="color: #6b7280; font-size: .75rem; cursor: pointer;">Lihat Password</label>
                </div>
            </div>
            
            <div class="d-flex gap-3">
                <button type="button" class="btn-cancel" onclick="closeAddUserModal()">Batal</button>
                <button type="submit" class="btn-confirm-del" style="background: var(--accent);">
                    Buat Akun
                </button>
            </div>
        </form>
    </div>
</div>

{{-- ── Reset Password Modal ── --}}
<div class="del-modal-backdrop" id="resetPasswordModal">
    <div class="del-modal" style="max-width: 450px; text-align: left;">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h5 class="mb-0" style="color: #f3f4f6; font-size: 1.1rem;">Reset Password: <span id="reset_user_name" style="color: var(--accent);"></span></h5>
            <button class="btn-close btn-close-white" onclick="closeResetPasswordModal()"></button>
        </div>
        
        <form id="resetPasswordForm" method="POST">
            @csrf
            @method('PUT')
            <div class="mb-4">
                <label class="form-label" style="color: #9ca3af; font-size: .8rem; font-weight: 600;">PASSWORD BARU</label>
                <input type="password" name="password" id="new_password_input" class="form-control-custom" placeholder="Min. 8 karakter" required>
                <div class="mt-2 d-flex align-items-center gap-2">
                    <input type="checkbox" id="show_reset_pass" onclick="togglePass('new_password_input')">
                    <label for="show_reset_pass" style="color: #6b7280; font-size: .75rem; cursor: pointer;">Lihat Password Baru</label>
                </div>
            </div>
            
            <div class="d-flex gap-3">
                <button type="button" class="btn-cancel" onclick="closeResetPasswordModal()">Batal</button>
                <button type="submit" class="btn-confirm-del" style="background: var(--accent);">
                    Simpan Password
                </button>
            </div>
        </form>
    </div>
</div>

@push('page-styles')
<style>
.mini-stat {
    display:flex; align-items:center; gap:14px;
    background:var(--bg-card); border:1px solid var(--border);
    border-radius:14px; padding:16px 20px;
}
.mini-stat-icon {
    width:42px; height:42px; border-radius:10px;
    display:flex; align-items:center; justify-content:center;
    font-size:1.1rem; flex-shrink:0;
}
.mini-stat-val   { font-size:1.5rem; font-weight:800; color:var(--text-1); letter-spacing:-.03em; }
.mini-stat-label { font-size:.72rem; color:var(--text-3); font-weight:500; margin-top:1px; }
.search-input::placeholder { color:#4b5563; }

.btn-primary-custom {
    background: linear-gradient(135deg, var(--accent), var(--accent-2));
    border: none; color: #fff; padding: 10px 20px; border-radius: 12px;
    font-size: .875rem; font-weight: 700; cursor: pointer;
    box-shadow: 0 4px 15px rgba(99,102,241,0.3);
    transition: all .2s;
}
.btn-primary-custom:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(99,102,241,0.4); }

.btn-action-custom {
    background: rgba(99,102,241,0.1);
    border: 1px solid rgba(99,102,241,0.2);
    color: var(--accent);
    width: 32px; height: 32px; border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; transition: all .2s;
}
.btn-action-custom:hover { background: var(--accent); color: #fff; }

.form-control-custom {
    background: rgba(255,255,255,.05);
    border: 1px solid rgba(255,255,255,.1);
    border-radius: 10px; padding: 10px 14px;
    color: #f3f4f6; width: 100%; font-size: .9rem;
    outline: none; transition: border-color .2s;
}
.form-control-custom:focus { border-color: var(--accent); background: rgba(255,255,255,.08); }
</style>
@endpush

@push('scripts')
<script>
    function openAddUserModal() {
        document.getElementById('addUserModal').classList.add('open');
    }
    function closeAddUserModal() {
        document.getElementById('addUserModal').classList.remove('open');
    }

    function openResetPasswordModal(userId, userName) {
        const modal = document.getElementById('resetPasswordModal');
        const form = document.getElementById('resetPasswordForm');
        const nameSpan = document.getElementById('reset_user_name');
        
        nameSpan.innerText = userName;
        form.action = `/admin/users/${userId}/password`;
        modal.classList.add('open');
    }
    function closeResetPasswordModal() {
        document.getElementById('resetPasswordModal').classList.remove('open');
    }

    function togglePass(id) {
        const x = document.getElementById(id);
        if (x.type === "password") {
            x.type = "text";
        } else {
            x.type = "password";
        }
    }
</script>
@endpush

@endsection
