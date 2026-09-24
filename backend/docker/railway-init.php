<?php

/*
 * One-time setup for container deployments, replacing the web installer.
 * Safe to run on every boot: each step only acts when its work is missing.
 *   - imports installation/backup/database.sql into an empty database
 *   - creates the first admin from ADMIN_EMAIL / ADMIN_PASSWORD
 *   - copies default images from installation/backup/public.zip into an empty storage volume
 *   - applies installation/branding/logo.png as the business logo, once per distinct file
 */

use App\CentralLogics\Helpers;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

function say(string $msg): void
{
    fwrite(STDOUT, "[railway-init] {$msg}\n");
}

for ($i = 1; ; $i++) {
    try {
        DB::connection()->getPdo();
        break;
    } catch (Throwable $e) {
        if ($i >= 30) {
            say('database not reachable: ' . $e->getMessage());
            exit(1);
        }
        sleep(2);
    }
}

if (!Schema::hasTable('business_settings')) {
    say('empty database, importing installation/backup/database.sql');
    DB::unprepared(file_get_contents(base_path('installation/backup/database.sql')));

    // Same defaults the web installer's final step writes
    DB::table('business_settings')->where('key', 'business_name')->update(['value' => env('BUSINESS_NAME', 'Paustik Poornahar')]);
    Helpers::insert_business_settings_key('system_language', '[{"id":1,"direction":"ltr","code":"en","status":1,"default":true}]');
    Helpers::insert_data_settings_key('admin_login_url', 'login_admin', 'admin');
    Helpers::insert_data_settings_key('admin_employee_login_url', 'login_admin_employee', 'admin_employee');
    Helpers::insert_data_settings_key('restaurant_login_url', 'login_restaurant', 'restaurant');
    Helpers::insert_data_settings_key('restaurant_employee_login_url', 'login_restaurant_employee', 'restaurant_employee');
    foreach (['take_away', 'repeat_order_option', 'home_delivery', 'country_picker_status', 'manual_login_status'] as $key) {
        Helpers::insert_business_settings_key($key, '1');
    }
    say('database imported');
}

if (DB::table('admins')->count() === 0) {
    $email = env('ADMIN_EMAIL');
    $password = env('ADMIN_PASSWORD');
    if ($email && $password) {
        DB::table('admins')->insert([
            'f_name' => 'Super',
            'l_name' => 'Admin',
            'email' => $email,
            'phone' => env('ADMIN_PHONE', ''),
            'role_id' => 1,
            'password' => bcrypt($password),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        say("admin created: {$email}");
    } else {
        say('no admin yet: set ADMIN_EMAIL and ADMIN_PASSWORD and redeploy');
    }
}

$storage = storage_path('app/public');
if (!is_dir($storage . '/business')) {
    $zip = new ZipArchive();
    if ($zip->open(base_path('installation/backup/public.zip')) === true) {
        for ($i = 0; $i < $zip->numFiles; $i++) {
            $name = $zip->getNameIndex($i);
            if (!str_starts_with($name, 'public/') || str_ends_with($name, '/') || str_contains($name, '.DS_Store')) {
                continue;
            }
            $target = $storage . '/' . substr($name, strlen('public/'));
            @mkdir(dirname($target), 0775, true);
            file_put_contents($target, $zip->getFromIndex($i));
        }
        $zip->close();
        say('default images copied to storage');
    }
}

// Marker file on the volume means a later logo/icon change in the admin panel is not overwritten on redeploy
foreach (['logo' => 'logo.png', 'icon' => 'icon.png'] as $settingKey => $file) {
    $brandFile = base_path('installation/branding/' . $file);
    if (!is_file($brandFile)) {
        continue;
    }
    $hash = md5_file($brandFile);
    $marker = $storage . '/business/.brand-' . $settingKey . '-' . $hash;
    if (!file_exists($marker)) {
        $name = date('Y-m-d') . '-' . substr($hash, 0, 13) . '.png';
        @mkdir($storage . '/business', 0775, true);
        copy($brandFile, $storage . '/business/' . $name);
        Helpers::businessUpdateOrInsert(['key' => $settingKey], ['value' => $name]);
        touch($marker);
        say("brand {$settingKey} applied: business/{$name}");
    }
}
