<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Setting;

class SettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Check if settings already exist to avoid duplicates
        if (Setting::count() == 0) {
            Setting::create([
                'app_name' => 'Chatter',
                'setRoomUsersLimit' => 11,
                'minute_limit_in_creating_story' => null,
                'minute_limit_in_audio_post' => null,
                'minute_limit_in_choosing_video_for_story' => null,
                'minute_limit_in_choosing_video_for_post' => null,
                'max_images_can_be_uploaded_in_one_post' => null,
                'ad_banner_android' => null,
                'ad_interstitial_android' => null,
                'ad_banner_iOS' => null,
                'ad_interstitial_iOS' => null,
                'is_admob_on' => 1,
                'audio_space_hosts_limit' => 234,
                'audio_space_listeners_limit' => 100,
                'audio_space_duration_in_minutes' => 110,
                'duration_limit_in_reel' => 60,
                'is_sight_engine_enabled' => 0,
                'sight_engine_api_user' => null,
                'sight_engine_api_secret' => null,
                'sight_engine_image_workflow_id' => null,
                'sight_engine_video_workflow_id' => null,
                'storage_type' => 0,
                'fetch_post_type' => 0,
                'support_email' => null,
                'is_in_app_purchase_enabled' => 1,
            ]);
        }
    }
}
