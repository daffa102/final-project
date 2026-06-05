<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

header('Content-Type: text/html; charset=utf-8');

echo "<h2>Kash. Server Debug (Session & Config)</h2>";

// 1. Check .env config
echo "<h3>1. Konfigurasi Penting (.env)</h3>";
echo "APP_URL: " . config('app.url') . "<br>";
echo "APP_ENV: " . config('app.env') . "<br>";
echo "SESSION_DRIVER: " . config('session.driver') . "<br>";
echo "SESSION_DOMAIN: " . (config('session.domain') ?: '(null/kosong)') . "<br>";
echo "SESSION_PATH: " . config('session.path') . "<br>";
echo "SESSION_SECURE_COOKIE: " . (config('session.secure') ? 'true' : 'false/null') . "<br>";
echo "SESSION_SAME_SITE: " . config('session.same_site') . "<br>";

// 2. Check sessions table (if using database driver)
echo "<h3>2. Cek Tabel Sessions</h3>";
if (config('session.driver') === 'database') {
    try {
        $hasTable = \Illuminate\Support\Facades\Schema::hasTable('sessions');
        echo "Tabel 'sessions' ada: " . ($hasTable ? '<span style="color:green">Ya</span>' : '<span style="color:red">Tidak</span>') . "<br>";
        if ($hasTable) {
            $count = \Illuminate\Support\Facades\DB::table('sessions')->count();
            echo "Jumlah session tersimpan: " . $count . "<br>";
        }
    } catch (\Exception $e) {
        echo '<span style="color:red">Error: ' . htmlspecialchars($e->getMessage()) . '</span><br>';
    }
} else {
    echo "Driver bukan 'database', skip cek tabel.<br>";
}

// 3. Check storage/framework/sessions writability
echo "<h3>3. Cek Folder Storage</h3>";
$storagePath = storage_path('framework/sessions');
echo "Path: " . $storagePath . "<br>";
echo "Folder ada: " . (is_dir($storagePath) ? '<span style="color:green">Ya</span>' : '<span style="color:red">Tidak</span>') . "<br>";
echo "Writable: " . (is_writable($storagePath) ? '<span style="color:green">Ya</span>' : '<span style="color:red">Tidak</span>') . "<br>";

$logPath = storage_path('logs');
echo "Log folder writable: " . (is_writable($logPath) ? '<span style="color:green">Ya</span>' : '<span style="color:red">Tidak</span>') . "<br>";

// 4. Test native PHP session
echo "<h3>4. Test Session PHP</h3>";
session_start();
$_SESSION['test'] = 'session_works_' . time();
echo "Session ID: " . session_id() . "<br>";
echo "Session test value set: " . $_SESSION['test'] . "<br>";
echo '<span style="color:green">PHP Session berjalan normal.</span><br>';

// 5. User data
echo "<h3>5. Data User Admin</h3>";
try {
    $user = \App\Models\User::where('email', 'admin@kash.com')->first();
    if ($user) {
        echo '<span style="color:green;font-weight:bold">✔ User Admin Ditemukan!</span><br>';
        echo "Nama: " . htmlspecialchars($user->name) . "<br>";
        echo "Email: " . htmlspecialchars($user->email) . "<br>";
        echo "Role: " . htmlspecialchars($user->role) . "<br>";
        echo "Password 'password': " . (\Illuminate\Support\Facades\Hash::check('password', $user->password) ? '<span style="color:green;font-weight:bold">VALID</span>' : '<span style="color:red;font-weight:bold">TIDAK COCOK</span>') . "<br>";
    } else {
        echo '<span style="color:red;font-weight:bold">❌ User admin@kash.com TIDAK ditemukan!</span><br>';
    }
} catch (\Exception $e) {
    echo '<span style="color:red">Error: ' . htmlspecialchars($e->getMessage()) . '</span><br>';
}

// 6. Potential issues summary
echo "<h3>6. Potensi Masalah</h3>";
$issues = [];

if (config('app.url') !== 'http://kash.dappa.my.id' && config('app.url') !== 'https://kash.dappa.my.id') {
    $issues[] = '⚠️ APP_URL (' . config('app.url') . ') TIDAK cocok dengan domain kash.dappa.my.id. Ubah APP_URL di .env menjadi http://kash.dappa.my.id';
}

if (config('session.secure') === true) {
    $issues[] = '⚠️ SESSION_SECURE_COOKIE=true tapi website Anda menggunakan HTTP (bukan HTTPS). Cookie session TIDAK akan terkirim! Set SESSION_SECURE_COOKIE=false di .env';
}

if (config('session.driver') === 'database') {
    $hasTable = \Illuminate\Support\Facades\Schema::hasTable('sessions');
    if (!$hasTable) {
        $issues[] = '❌ SESSION_DRIVER=database tapi tabel "sessions" TIDAK ADA. Jalankan: php artisan migrate --force';
    }
}

if (empty($issues)) {
    echo '<span style="color:green;font-weight:bold">Tidak ada masalah konfigurasi yang terdeteksi.</span>';
} else {
    foreach ($issues as $issue) {
        echo '<p style="color:red;font-weight:bold">' . $issue . '</p>';
    }
}
