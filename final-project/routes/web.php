<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Admin\AdminDashboardController;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');
    Route::get('/users', [AdminDashboardController::class, 'users'])->name('users.index');
    Route::post('/users', [AdminDashboardController::class, 'store'])->name('users.store');
    Route::put('/users/{user}/password', [AdminDashboardController::class, 'updatePassword'])->name('users.password.update');
    Route::delete('/users/{user}', [AdminDashboardController::class, 'destroy'])->name('users.destroy');
    Route::get('/analytics', [AdminDashboardController::class, 'analytics'])->name('analytics');
});

require __DIR__.'/auth.php';
