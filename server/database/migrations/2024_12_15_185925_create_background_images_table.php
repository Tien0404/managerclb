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
    Schema::create('background_images', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
        $table->foreignId('club_id')->nullable()->constrained('clubs')->nullOnDelete();
        $table->foreignId('event_id')->nullable()->constrained('events')->nullOnDelete();
        $table->foreignId('blog_id')->nullable()->constrained('blogs')->nullOnDelete();
        $table->string('image_url')->nullable();
        $table->string('video_url')->nullable();
        $table->boolean('is_logo')->default(false);
    });
}

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('background_images');
    }
};
