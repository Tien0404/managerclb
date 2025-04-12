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
    Schema::create('events', function (Blueprint $table) {
        $table->id();
        $table->foreignId('club_id')->constrained('clubs')->onDelete('cascade');
        $table->foreignId('category_id')->constrained('categories')->onDelete('cascade');
        $table->string('name');
        $table->dateTime('start_date');
        $table->dateTime('end_date');
        $table->string('location')->nullable();
        $table->integer('max_participants')->nullable();
        $table->integer('registered_participants')->default(0);
        $table->text('content')->nullable();
        $table->string('status')->nullable();
    });
}

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('events');
    }
};
