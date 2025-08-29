<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('settings', function (Blueprint $table) {
            $table->string('app_name')->default('Chatter');
            $table->integer('setRoomUsersLimit')->default(11);
            $table->integer('minute_limit_in_creating_story')->nullable();
            $table->integer('minute_limit_in_audio_post')->nullable();
            $table->integer('minute_limit_in_choosing_video_for_story')->nullable();
            $table->integer('minute_limit_in_choosing_video_for_post')->nullable();
            $table->integer('max_images_can_be_uploaded_in_one_post')->nullable();
            $table->string('ad_banner_android')->nullable();
            $table->string('ad_interstitial_android')->nullable();
            $table->string('ad_banner_iOS')->nullable();
            $table->string('ad_interstitial_iOS')->nullable();
            $table->integer('is_admob_on')->default(1)->comment('0 = off / 1 = on');
            $table->bigInteger('audio_space_hosts_limit')->default(234);
            $table->bigInteger('audio_space_listeners_limit')->default(100);
            $table->bigInteger('audio_space_duration_in_minutes')->default(110);
            $table->integer('duration_limit_in_reel')->default(60);
            $table->integer('is_sight_engine_enabled')->default(0);
            $table->string('sight_engine_api_user', 55)->nullable();
            $table->string('sight_engine_api_secret')->nullable();
            $table->string('sight_engine_image_workflow_id')->nullable();
            $table->string('sight_engine_video_workflow_id')->nullable();
            $table->integer('storage_type')->default(0)->comment('0 = Local / 1 = AWS S3 / 2 = DigitaoOcean Space');
            $table->integer('fetch_post_type')->default(0)->comment('0 = Random / 1 = Latest');
            $table->string('support_email')->nullable();
            $table->tinyInteger('is_in_app_purchase_enabled')->default(1)->comment('0 = Disabled / 1 = Enabled');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('settings', function (Blueprint $table) {
            $table->dropColumn([
                'app_name', 'setRoomUsersLimit', 'minute_limit_in_creating_story', 
                'minute_limit_in_audio_post', 'minute_limit_in_choosing_video_for_story',
                'minute_limit_in_choosing_video_for_post', 'max_images_can_be_uploaded_in_one_post',
                'ad_banner_android', 'ad_interstitial_android', 'ad_banner_iOS', 'ad_interstitial_iOS',
                'is_admob_on', 'audio_space_hosts_limit', 'audio_space_listeners_limit',
                'audio_space_duration_in_minutes', 'duration_limit_in_reel', 'is_sight_engine_enabled',
                'sight_engine_api_user', 'sight_engine_api_secret', 'sight_engine_image_workflow_id',
                'sight_engine_video_workflow_id', 'storage_type', 'fetch_post_type', 'support_email',
                'is_in_app_purchase_enabled'
            ]);
        });
    }
};
