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
    Schema::create('clubs', function (Blueprint $table) {
        $table->id();
        $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
        $table->foreignId('category_id')->constrained('categories')->onDelete('cascade');;
        $table->string('name');
        $table->text('description')->nullable();
        $table->integer('member_count')->default(0);
        $table->string('contact_email')->nullable();
        $table->string('contact_phone')->nullable();
        $table->string('contact_address')->nullable();
        $table->string('province')->nullable();
        $table->string('facebook_link')->nullable();
        $table->string('zalo_link')->nullable();
        $table->string('status')->default('pending');
    });
}

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('clubs');
    }
};
