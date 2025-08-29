<?php

// Test script to verify admin login functionality
require_once './chatter_backend/vendor/autoload.php';

// Load Laravel application
$app = require_once './chatter_backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);

// Test database connection and admin credentials
try {
    $pdo = new PDO('sqlite:' . __DIR__ . '/chatter_backend/database/database.sqlite');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Database connection successful!\n";
    
    // Check if admin table exists and has data
    $stmt = $pdo->query("SELECT user_name, user_password FROM admins LIMIT 1");
    $admin = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($admin) {
        echo "✅ Admin user found in database:\n";
        echo "   Username: " . $admin['user_name'] . "\n";
        echo "   Password: " . $admin['user_password'] . "\n";
        echo "\n";
        echo "🌐 Login URL: http://127.0.0.1:8003\n";
        echo "👤 Username: " . $admin['user_name'] . "\n";
        echo "🔒 Password: " . $admin['user_password'] . "\n";
    } else {
        echo "❌ No admin user found in database\n";
    }
    
} catch (Exception $e) {
    echo "❌ Database error: " . $e->getMessage() . "\n";
}

?>
