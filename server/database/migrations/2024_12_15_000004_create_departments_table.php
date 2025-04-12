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
    Schema::create('departments', function (Blueprint $table) {
        $table->id();
        $table->foreignId('club_id')->constrained('clubs');
        $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
        $table->string('name');
        $table->string('description')->nullable();
        $table->boolean('manage_clubs')->default(false);
        $table->boolean('manage_events')->default(false);
        $table->boolean('manage_members')->default(false);
        $table->boolean('manage_blogs')->default(false);
        $table->boolean('manage_feedback')->default(false);
    });
}

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('departments');
    }
};
