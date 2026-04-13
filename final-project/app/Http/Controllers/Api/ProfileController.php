<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    /**
     * Get the authenticated user's profile.
     */
    public function index(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => $request->user()
        ]);
    }

    /**
     * Update store information (name and logo).
     */
    public function updateStore(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'store_name' => 'required|string|max:255',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $user->store_name = $request->store_name;

        if ($request->hasFile('logo')) {
            // Delete old logo if exists
            if ($user->logo_url) {
                $oldPath = str_replace(url('storage/'), '', $user->logo_url);
                Storage::disk('public')->delete($oldPath);
            }

            $path = $request->file('logo')->store('logos', 'public');
            $user->logo_url = url('storage/' . $path);
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Profil toko berhasil diperbarui.',
            'data' => $user
        ]);
    }

    /**
     * Update the user's password.
     */
    public function updatePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|current_password',
            'password' => ['required', 'confirmed', Password::defaults()],
        ]);

        $user = $request->user();
        $user->update([
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Kata sandi berhasil diperbarui.'
        ]);
    }
}
