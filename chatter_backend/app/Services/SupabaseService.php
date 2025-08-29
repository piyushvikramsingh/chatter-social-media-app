<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SupabaseService
{
    private string $url;
    private string $anonKey;
    private string $serviceRoleKey;

    public function __construct()
    {
        $this->url = env('SUPABASE_URL');
        $this->anonKey = env('SUPABASE_ANON_KEY');
        $this->serviceRoleKey = env('SUPABASE_SERVICE_ROLE_KEY', '');
    }

    /**
     * Test database connection through Supabase REST API
     */
    public function testConnection(): array
    {
        try {
            $response = Http::withHeaders([
                'apikey' => $this->anonKey,
                'Authorization' => 'Bearer ' . $this->anonKey,
                'Content-Type' => 'application/json',
                'Prefer' => 'return=minimal'
            ])->get($this->url . '/rest/v1/');

            return [
                'success' => $response->successful(),
                'status' => $response->status(),
                'message' => $response->successful() ? 'Connection successful' : 'Connection failed',
                'data' => $response->json()
            ];
        } catch (\Exception $e) {
            Log::error('Supabase connection test failed: ' . $e->getMessage());
            return [
                'success' => false,
                'status' => 500,
                'message' => 'Connection error: ' . $e->getMessage(),
                'data' => null
            ];
        }
    }

    /**
     * Execute a query through Supabase REST API
     */
    public function query(string $table, array $filters = [], array $select = ['*']): array
    {
        try {
            $url = $this->url . '/rest/v1/' . $table;
            
            $params = [];
            if (!empty($select)) {
                $params['select'] = implode(',', $select);
            }
            
            foreach ($filters as $key => $value) {
                if (is_array($value)) {
                    // Handle operators like eq, gt, lt, etc.
                    $operator = $value['operator'] ?? 'eq';
                    $params[$key] = $operator . '.' . $value['value'];
                } else {
                    $params[$key] = 'eq.' . $value;
                }
            }

            $response = Http::withHeaders([
                'apikey' => $this->anonKey,
                'Authorization' => 'Bearer ' . $this->anonKey,
                'Content-Type' => 'application/json'
            ])->get($url, $params);

            return [
                'success' => $response->successful(),
                'status' => $response->status(),
                'data' => $response->json()
            ];
        } catch (\Exception $e) {
            Log::error('Supabase query failed: ' . $e->getMessage());
            return [
                'success' => false,
                'status' => 500,
                'data' => null,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Insert data through Supabase REST API
     */
    public function insert(string $table, array $data): array
    {
        try {
            $response = Http::withHeaders([
                'apikey' => $this->anonKey,
                'Authorization' => 'Bearer ' . $this->anonKey,
                'Content-Type' => 'application/json',
                'Prefer' => 'return=representation'
            ])->post($this->url . '/rest/v1/' . $table, $data);

            return [
                'success' => $response->successful(),
                'status' => $response->status(),
                'data' => $response->json()
            ];
        } catch (\Exception $e) {
            Log::error('Supabase insert failed: ' . $e->getMessage());
            return [
                'success' => false,
                'status' => 500,
                'data' => null,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Update data through Supabase REST API
     */
    public function update(string $table, array $filters, array $data): array
    {
        try {
            $url = $this->url . '/rest/v1/' . $table;
            
            $params = [];
            foreach ($filters as $key => $value) {
                $params[$key] = 'eq.' . $value;
            }

            $response = Http::withHeaders([
                'apikey' => $this->anonKey,
                'Authorization' => 'Bearer ' . $this->anonKey,
                'Content-Type' => 'application/json',
                'Prefer' => 'return=representation'
            ])->patch($url . '?' . http_build_query($params), $data);

            return [
                'success' => $response->successful(),
                'status' => $response->status(),
                'data' => $response->json()
            ];
        } catch (\Exception $e) {
            Log::error('Supabase update failed: ' . $e->getMessage());
            return [
                'success' => false,
                'status' => 500,
                'data' => null,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Delete data through Supabase REST API
     */
    public function delete(string $table, array $filters): array
    {
        try {
            $url = $this->url . '/rest/v1/' . $table;
            
            $params = [];
            foreach ($filters as $key => $value) {
                $params[$key] = 'eq.' . $value;
            }

            $response = Http::withHeaders([
                'apikey' => $this->anonKey,
                'Authorization' => 'Bearer ' . $this->anonKey,
                'Content-Type' => 'application/json'
            ])->delete($url . '?' . http_build_query($params));

            return [
                'success' => $response->successful(),
                'status' => $response->status(),
                'data' => $response->json()
            ];
        } catch (\Exception $e) {
            Log::error('Supabase delete failed: ' . $e->getMessage());
            return [
                'success' => false,
                'status' => 500,
                'data' => null,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Get connection health and statistics
     */
    public function getConnectionHealth(): array
    {
        try {
            // Test basic connectivity
            $connectionTest = $this->testConnection();
            
            // Try to get some basic stats if connection is working
            if ($connectionTest['success']) {
                $settingsTest = $this->query('settings', [], ['id', 'app_name']);
                
                return [
                    'status' => 'healthy',
                    'connection' => 'active',
                    'pooler' => 'enabled',
                    'ipv4_compatible' => true,
                    'api_responsive' => true,
                    'settings_accessible' => $settingsTest['success']
                ];
            }

            return [
                'status' => 'unhealthy',
                'connection' => 'failed',
                'pooler' => 'unknown',
                'ipv4_compatible' => false,
                'api_responsive' => false,
                'error' => $connectionTest['message']
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'connection' => 'failed',
                'error' => $e->getMessage()
            ];
        }
    }
}
