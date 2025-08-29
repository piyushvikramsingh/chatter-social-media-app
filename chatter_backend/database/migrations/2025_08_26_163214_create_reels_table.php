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
        Schema::create('reels', function (Blueprint $table) {
            $table->integer('id')->autoIncrement();
            $table->integer('user_id');
            $table->string('interest_ids')->nullable();
            $table->integer('music_id')->nullable();
            $table->text('description')->nullable();
            $table->string('content')->nullable();
            $table->string('thumbnail')->nullable();
            $table->string('hashtags')->nullable();
            $table->integer('comments_count')->default(0);
            $table->integer('likes_count')->default(0);
            $table->integer('views_count')->default(0);
            $table->timestamps();
            
            $table->index('user_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('reels');
    }
};
