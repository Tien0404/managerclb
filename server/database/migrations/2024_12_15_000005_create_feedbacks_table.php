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
        Schema::create('feedback', function (Blueprint $table) {
            $table->id();
        $table->foreignId('club_id')->constrained('clubs')->onDelete('cascade');
        $table->string('name');
        $table->string('email');
        $table->string('mobile');
        $table->text('comment')->nullable();
        $table->text('club_response')->nullable();
        $table->string('status')->nullable();
        $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('feedbacks');
    }
};
