<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

header('Content-Type: text/html; charset=utf-8');

echo "<h2>Kash. Server Login Debugger</h2>";

// Check Database Connection and User
try {
    $user = \App\Models\User::where('email', 'admin@kash.com')->first();
    if ($user) {
        echo "<p style='color: green; font-weight: bold;'>✔ User Admin Berhasil Ditemukan!</p>";
        echo "Nama: " . htmlspecialchars($user->name) . "<br>";
        echo "Email: " . htmlspecialchars($user->email) . "<br>";
        echo "Role: " . htmlspecialchars($user->role) . "<br>";
        echo "Is Active: " . ($user->is_active ? 'Yes' : 'No') . "<br>";
        
        $passwordMatches = \Illuminate\Support\Facades\Hash::check('password', $user->password);
        if ($passwordMatches) {
            echo "Password 'password': <span style='color: green; font-weight: bold;'>VALID</span><br>";
        } else {
            echo "Password 'password': <span style='color: red; font-weight: bold;'>TIDAK COCOK / SALAH</span><br>";
        }
    } else {
        echo "<p style='color: red; font-weight: bold;'>❌ User Admin NOT Found! (Akun admin@kash.com tidak ada di database)</p>";
    }
} catch (\Exception $e) {
    echo "<p style='color: red; font-weight: bold;'>❌ Error Database:</p>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
}
