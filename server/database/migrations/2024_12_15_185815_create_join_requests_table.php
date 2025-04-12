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
        Schema::create('join_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('club_id')->nullable()->constrained('clubs')->onDelete('cascade');
            $table->foreignId('event_id')->nullable()->constrained('events')->onDelete('cascade');
            $table->enum('type', ['club', 'event'])->comment('Loại yêu cầu: tham gia câu lạc bộ hoặc sự kiện');
            $table->enum('status', ['request','invite', 'approved', 'rejected']);
            $table->text('message')->nullable()->comment('Lời nhắn từ người gửi yêu cầu');
            $table->text('response_message')->nullable()->comment('Phản hồi từ người duyệt');
            $table->timestamp('responded_at')->nullable()->comment('Thời điểm phản hồi');
            $table->timestamps();
        });

        // Thêm ràng buộc sau khi tạo bảng
        DB::statement('ALTER TABLE join_requests ADD CONSTRAINT check_request_type 
            CHECK ((club_id IS NOT NULL AND event_id IS NULL AND type = "club") OR 
                   (event_id IS NOT NULL AND club_id IS NULL AND type = "event"))');
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('join_requests');
    }
};
