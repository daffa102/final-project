<?php

use App\Providers\AppServiceProvider;

return [
    AppServiceProvider::class,
    Laravel\Sanctum\SanctumServiceProvider::class,
    Barryvdh\DomPDF\ServiceProvider::class,
];
