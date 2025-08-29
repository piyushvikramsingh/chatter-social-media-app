<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('musics', function (Blueprint $table) {
            $table->integer('id')->autoIncrement();
            $table->integer('category_id')->nullable();
            $table->string('title', 250)->nullable();
            $table->string('sound', 200)->nullable();
            $table->string('duration', 100)->nullable();
            $table->string('artist', 100)->nullable();
            $table->string('image', 999)->nullable();
            $table->boolean('is_deleted')->default(0)->comment('0=not 1=deleted');
            $table->timestamp('created_at')->default(DB::raw('CURRENT_TIMESTAMP'));
            $table->datetime('updated_at')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('musics');
    }
};
