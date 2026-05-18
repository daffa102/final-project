<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $totalUsers  = User::where('role', 'user')->count();
        $activeUsers = User::where('role', 'user')
            ->where('last_login_at', '>=', Carbon::now()->subDays(7))
            ->count();
        $inactiveUsers = $totalUsers - $activeUsers;

        $chartData = User::where('role', 'user')
            ->select(DB::raw('COUNT(*) as count'), DB::raw("DATE_FORMAT(created_at, '%M') as month"))
            ->groupBy('month')
            ->orderByRaw('MIN(created_at) ASC')
            ->get();

        return view('admin.dashboard', compact('totalUsers', 'activeUsers', 'inactiveUsers', 'chartData'));
    }

    public function users(Request $request)
    {
        $search = $request->query('search');

        $users = User::where('role', 'user')
            ->when($search, fn($q) => $q->where('name', 'like', "%$search%")
                ->orWhere('email', 'like', "%$search%"))
            ->orderBy('last_login_at', 'desc')
            ->paginate(15)
            ->withQueryString();

        $totalUsers    = User::where('role', 'user')->count();
        $activeUsers   = User::where('role', 'user')->where('last_login_at', '>=', Carbon::now()->subDays(7))->count();
        $inactiveUsers = $totalUsers - $activeUsers;

        return view('admin.users', compact('users', 'totalUsers', 'activeUsers', 'inactiveUsers', 'search'));
    }

    public function analytics()
    {
        $chartData = User::where('role', 'user')
            ->select(DB::raw('COUNT(*) as count'), DB::raw("DATE_FORMAT(created_at, '%M %Y') as month"))
            ->groupBy('month')
            ->orderByRaw('MIN(created_at) ASC')
            ->get();

        $totalUsers    = User::where('role', 'user')->count();
        $activeUsers   = User::where('role', 'user')->where('last_login_at', '>=', Carbon::now()->subDays(7))->count();
        $inactiveUsers = $totalUsers - $activeUsers;

        // Users registered per day (last 30 days)
        $dailyData = User::where('role', 'user')
            ->where('created_at', '>=', Carbon::now()->subDays(30))
            ->select(DB::raw('COUNT(*) as count'), DB::raw("DATE_FORMAT(created_at, '%d %b') as day"))
            ->groupBy('day')
            ->orderByRaw('MIN(created_at) ASC')
            ->get();

        return view('admin.analytics', compact('chartData', 'dailyData', 'totalUsers', 'activeUsers', 'inactiveUsers'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:20',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
            'phone' => $request->phone,
            'role' => 'user',
        ]);

        return back()->with('success', "Akun untuk \"{$user->name}\" berhasil dibuat.");
    }

    public function updatePassword(Request $request, User $user)
    {
        $request->validate([
            'password' => 'required|string|min:8',
        ]);

        $user->password = bcrypt($request->password);
        $user->save();

        return back()->with('success', "Password untuk \"{$user->name}\" berhasil diperbarui.");
    }

    public function destroy(User $user)
    {
        if ($user->role === 'admin') {
            return back()->with('error', 'Cannot delete admin accounts.');
        }
        $user->delete();
        return back()->with('success', "Akun \"{$user->name}\" berhasil dihapus.");
    }
}
