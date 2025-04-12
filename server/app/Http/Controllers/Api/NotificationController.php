<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class NotificationController extends Controller
{
    /**
     * Lấy danh sách thông báo của user đang đăng nhập
     */
    public function index()
    {
        $user = Auth::user();
        return response()->json([
            'unread' => $user->notifications()->whereNull('read_at')->get(),
            'read' => $user->notifications()->whereNotNull('read_at')->get()
        ]);
    }

    /**
     * Đánh dấu một thông báo là đã đọc
     */
    public function markAsRead($id)
    {
        $user = Auth::user();
        $notification = $user->notifications()->findOrFail($id);
        $notification->update([
            'read_at' => Carbon::now()
        ]);

        return response()->json(['message' => 'Notification marked as read']);
    }

    /**
     * Đánh dấu tất cả thông báo là đã đọc
     */
    public function markAllAsRead()
    {
        $user = Auth::user();
        $user->notifications()->whereNull('read_at')->update([
            'read_at' => Carbon::now()
        ]);

        return response()->json(['message' => 'All notifications marked as read']);
    }

    /**
     * Xóa một thông báo
     */
    public function destroy($id)
    {
        $user = Auth::user();
        $notification = $user->notifications()->findOrFail($id);
        $notification->delete();

        return response()->json(['message' => 'Notification deleted']);
    }

    /**
     * Xóa tất cả thông báo
     */
    public function destroyAll()
    {
        $user = Auth::user();
        $user->notifications()->delete();

        return response()->json(['message' => 'All notifications deleted']);
    }
} 