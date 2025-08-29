#!/usr/bin/env php
<?php
/**
 * Chatter App - Production Readiness Test Suite
 * This script tests all critical API endpoints and functionality
 */

$baseUrl = 'http://127.0.0.1:8001/api/';
$adminUrl = 'http://127.0.0.1:8001/';

echo "🚀 CHATTER APP - PRODUCTION READINESS TEST SUITE\n";
echo "================================================\n\n";

$results = [];
$testCount = 0;
$passedCount = 0;

function makeRequest($url, $method = 'GET', $data = null, $headers = []) {
    $curl = curl_init();
    
    curl_setopt_array($curl, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => array_merge([
            'Accept: application/json',
            'Content-Type: application/json',
            'APIKEY: 123'
        ], $headers),
    ]);
    
    if ($data && ($method === 'POST' || $method === 'PUT')) {
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
    }
    
    $response = curl_exec($curl);
    $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $error = curl_error($curl);
    curl_close($curl);
    
    return [
        'response' => $response,
        'http_code' => $httpCode,
        'error' => $error
    ];
}

function runTest($testName, $url, $method = 'GET', $data = null, $expectedCode = 200) {
    global $testCount, $passedCount, $results;
    
    $testCount++;
    echo "Testing: {$testName}... ";
    
    $result = makeRequest($url, $method, $data);
    
    if ($result['error']) {
        echo "❌ CURL ERROR: {$result['error']}\n";
        $results[$testName] = ['status' => 'ERROR', 'message' => $result['error']];
        return false;
    }
    
    if ($result['http_code'] === $expectedCode) {
        echo "✅ PASSED (HTTP {$result['http_code']})\n";
        $passedCount++;
        $results[$testName] = ['status' => 'PASSED', 'http_code' => $result['http_code']];
        return true;
    } else {
        echo "❌ FAILED (HTTP {$result['http_code']}, Expected {$expectedCode})\n";
        $results[$testName] = ['status' => 'FAILED', 'http_code' => $result['http_code'], 'response' => substr($result['response'], 0, 200)];
        return false;
    }
}

echo "1. 🔍 BASIC CONNECTIVITY TESTS\n";
echo "================================\n";

// Test admin panel accessibility
runTest("Admin Panel Access", $adminUrl . "admin");

// Test API endpoints
runTest("API Health Check", $baseUrl . "settings");
runTest("Get App Settings", $baseUrl . "fetchSetting");

echo "\n2. 📱 CORE API ENDPOINTS\n";
echo "========================\n";

// User management endpoints
runTest("User Registration Endpoint", $baseUrl . "register", 'POST', [
    'identity' => 'test@example.com',
    'username' => 'testuser',
    'full_name' => 'Test User',
    'device_type' => 0,
    'login_type' => 0
], 422); // Expect validation error since we're missing required fields

runTest("User Login Endpoint", $baseUrl . "login", 'POST', [
    'identity' => 'admin@example.com',
    'password' => 'password'
], 422); // Expect validation error

// Content endpoints
runTest("Get Posts", $baseUrl . "fetchHomeData", 'POST', [
    'user_id' => 1,
    'page' => 1
]);

runTest("Get Reels", $baseUrl . "fetchReels", 'POST', [
    'user_id' => 1,
    'page' => 1
]);

runTest("Get Rooms", $baseUrl . "fetchRooms", 'POST', [
    'user_id' => 1,
    'page' => 1
]);

echo "\n3. 🎵 MEDIA & CONTENT TESTS\n";
echo "===========================\n";

// Media endpoints
runTest("Get Music List", $baseUrl . "fetchMusic");
runTest("Get Interests", $baseUrl . "fetchInterests");

echo "\n4. 🏗️ ADMIN FUNCTIONALITY TESTS\n";
echo "================================\n";

// Admin endpoints
runTest("Admin Dashboard", $adminUrl . "admin/dashboard");
runTest("Admin Settings", $adminUrl . "admin/setting");
runTest("Admin Users", $adminUrl . "admin/user");
runTest("Admin Notifications", $adminUrl . "admin/notification");

echo "\n5. 🔧 CONFIGURATION TESTS\n";
echo "=========================\n";

// Configuration tests
runTest("Database Info", $baseUrl . "getDatabaseInfo", 'POST');
runTest("Agora Token Generation", $baseUrl . "generateAgoraToken", 'POST', [
    'channelName' => 'test-channel'
]);

echo "\n6. 📊 ANALYTICS & REPORTING\n";
echo "===========================\n";

// Analytics endpoints
runTest("User Chart Data", $baseUrl . "fetchUsersForChart", 'POST');
runTest("Posts Chart Data", $baseUrl . "fetchPostsForChart", 'POST');
runTest("Reels Chart Data", $baseUrl . "fetchReelsForChart", 'POST');

echo "\n" . str_repeat("=", 50) . "\n";
echo "📈 TEST RESULTS SUMMARY\n";
echo str_repeat("=", 50) . "\n";

echo "Total Tests: {$testCount}\n";
echo "Passed: {$passedCount}\n";
echo "Failed: " . ($testCount - $passedCount) . "\n";
echo "Success Rate: " . round(($passedCount / $testCount) * 100, 2) . "%\n\n";

echo "📋 DETAILED RESULTS:\n";
echo "--------------------\n";

foreach ($results as $testName => $result) {
    $status = $result['status'];
    $icon = $status === 'PASSED' ? '✅' : '❌';
    echo "{$icon} {$testName}: {$status}\n";
    
    if ($status === 'FAILED' && isset($result['response'])) {
        echo "   Response: " . substr($result['response'], 0, 100) . "...\n";
    }
}

echo "\n🎯 PRODUCTION READINESS ASSESSMENT:\n";
echo "===================================\n";

$successRate = ($passedCount / $testCount) * 100;

if ($successRate >= 90) {
    echo "🟢 EXCELLENT: App is ready for production deployment!\n";
} elseif ($successRate >= 70) {
    echo "🟡 GOOD: App is mostly ready, minor issues need fixing.\n";
} elseif ($successRate >= 50) {
    echo "🟠 FAIR: Several issues need to be addressed before production.\n";
} else {
    echo "🔴 POOR: Significant issues need to be resolved before deployment.\n";
}

echo "\n📝 NEXT STEPS:\n";
echo "=============\n";
echo "1. Fix any failed tests\n";
echo "2. Set up AWS infrastructure\n";
echo "3. Deploy to staging environment\n";
echo "4. Perform load testing\n";
echo "5. Security audit\n";
echo "6. Go-live preparation\n";

echo "\n🔗 Useful URLs:\n";
echo "===============\n";
echo "Admin Panel: http://localhost:8001/admin\n";
echo "API Base: http://localhost:8001/api/\n";
echo "Database: SQLite (Local Development)\n";

echo "\n✨ Test completed at " . date('Y-m-d H:i:s') . "\n";
?>
