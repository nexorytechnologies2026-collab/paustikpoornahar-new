<?php

use App\Http\Controllers\InstallController;
use Illuminate\Support\Facades\Route;


Route::get('/', [InstallController::class, 'step0'])->name('step0');

Route::get('/step1', [InstallController::class, 'step1'])->name('step1');
Route::get('/step3/{error?}', [InstallController::class, 'step3'])->name('step3')->middleware('installation-check');
Route::get('/step4', [InstallController::class, 'step4'])->name('step4')->middleware('installation-check');
Route::get('/step5', [InstallController::class, 'step5'])->name('step5')->middleware('installation-check');

Route::post('/database_installation', [InstallController::class, 'database_installation'])->name('install.db')->middleware('installation-check');
Route::get('import_sql', [InstallController::class, 'import_sql'])->name('import_sql')->middleware('installation-check');
Route::get('force-import-sql', [InstallController::class, 'force_import_sql'])->name('force-import-sql')->middleware('installation-check');
Route::post('system_settings', [InstallController::class, 'system_settings'])->name('system_settings');

Route::fallback(function () {
    return redirect('/');
});
