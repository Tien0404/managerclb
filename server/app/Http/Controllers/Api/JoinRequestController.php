<?php

namespace App\Http\Controllers\Api;

use App\Models\JoinRequest;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Club;
use App\Notify\JoinRequestNotification;

class JoinRequestController extends Controller
{
    /**
     * Lấy tất cả join requests theo club_id
     */
    public function getClubRequests($club_id)
    {
        return JoinRequest::with(['user', 'user.backgroundImages', 'user.departments'])
            ->where('club_id', $club_id)
            ->where('type', 'club')
            ->get();
    }

    /**
     * Lấy tất cả join requests theo event_id
     */
    public function getEventRequests($event_id)
    {
        return JoinRequest::with(['user', 'user.backgroundImages'])
            ->where('event_id', $event_id)
            ->where('type', 'event')
            ->get();
    }

    /**
     * Lấy tất cả join requests của một user
     */
    public function getUserRequests($user_id)
    {
        return JoinRequest::with(['club', 'club.backgroundImages' => function($query) {
                $query->where('is_logo', 1);
            }, 'event', 'event.backgroundImages'])
            ->where('user_id', $user_id)
            ->get();
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'user_id' => 'required|exists:users,id',
            'type' => 'required|in:club,event',
            'club_id' => 'required_if:type,club|nullable|exists:clubs,id',
            'event_id' => 'required_if:type,event|nullable|exists:events,id',
            'message' => 'nullable|string|max:500',
            'status' => 'required|in:request,invite,approved'
        ]);

        // Kiểm tra xem đã có yêu cầu đang pending chưa
        $existingRequest = JoinRequest::where('user_id', $validatedData['user_id'])
            ->when($validatedData['type'] === 'club', function ($query) use ($validatedData) {
                return $query->where('club_id', $validatedData['club_id'])
                    ->where('type', 'club');
            })
            ->when($validatedData['type'] === 'event', function ($query) use ($validatedData) {
                return $query->where('event_id', $validatedData['event_id'])
                    ->where('type', 'event');
            })
            ->where('status', ['request', 'invite'])
            ->first();

        if ($existingRequest) {
            return response()->json([
                'message' => 'Người dùng đã có yêu cầu tham gia ' .
                    ($validatedData['type'] === 'club' ? 'câu lạc bộ' : 'sự kiện') . ' này đang chờ duyệt',
                'request' => $existingRequest->load(['user', 'club', 'event'])
            ], 409);
        }

        // Kiểm tra nếu đăng ký sự kiện và sự kiện đã đủ số lượng người tham gia
        if ($validatedData['type'] === 'event') {
            $event = \App\Models\Event::findOrFail($validatedData['event_id']);
            
            // Kiểm tra nếu sự kiện đã đạt số lượng người tham gia tối đa
            if ($event->registered_participants >= $event->max_participants) {
                return response()->json([
                    'message' => 'Sự kiện này đã đạt số lượng người tham gia tối đa',
                ], 400);
            }
            
            // Kiểm tra nếu sự kiện đã kết thúc
            if (strtotime($event->end_date) < time()) {
                return response()->json([
                    'message' => 'Sự kiện này đã kết thúc, không thể đăng ký tham gia',
                ], 400);
            }
        }

        // Tạo yêu cầu mới
        $joinRequest = new JoinRequest();
        $joinRequest->user_id = $validatedData['user_id'];
        $joinRequest->type = $validatedData['type'];
        
        // Nếu là sự kiện, tự động set status là approved
        if ($validatedData['type'] === 'event') {
            $joinRequest->status = 'approved';
            $joinRequest->responded_at = now();
            
            // Tăng số lượng người đăng ký tham gia sự kiện
            $event = \App\Models\Event::findOrFail($validatedData['event_id']);
            $event->registered_participants += 1;
            $event->save();
        } else {
            $joinRequest->status = $validatedData['status'];
        }
        
        $joinRequest->message = $validatedData['message'] ?? null;

        if ($validatedData['type'] === 'club') {
            $joinRequest->club_id = $validatedData['club_id'];
            $joinRequest->event_id = null;
        } else {
            $joinRequest->event_id = $validatedData['event_id'];
            $joinRequest->club_id = null;
        }

        $joinRequest->save();

        return response()->json([
            'message' => 'Đã gửi yêu cầu tham gia thành công',
            'data' => $joinRequest->load(['user', 'club', 'event'])
        ], 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(JoinRequest $joinRequest)
    {
        return response()->json($joinRequest->load(['club', 'user']));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, JoinRequest $joinRequest)
    {
        $validatedData = $request->validate([
            'status' => 'required|in:approved,rejected,request',
            'response_message' => 'nullable|string'
        ]);

        // Lưu trạng thái cũ để kiểm tra
        $oldStatus = $joinRequest->status;

        // Tạo mảng dữ liệu cập nhật
        $updateData = [
            'status' => $validatedData['status']
        ];

        // Nếu trạng thái là approved, thêm thời gian phản hồi và message tương ứng
        if ($validatedData['status'] === 'approved') {
            $updateData['responded_at'] = now();
            
            // Lấy tên người dùng
            $userName = $joinRequest->user->name;
            
            if ($joinRequest->type === 'club') {
                $clubName = $joinRequest->club->name;
                $updateData['message'] = $userName ? 
                    "Tuyệt vời! {$userName} đã chính thức trở thành thành viên của {$clubName}" :
                    "Chúc mừng bạn đã chính thức trở thành thành viên của {$clubName}";
                
                // Tăng số lượng thành viên của câu lạc bộ
                $club = $joinRequest->club;
                $club->member_count += 1;
                $club->save();
            } else {
                $eventName = $joinRequest->event->name;
                $updateData['message'] = $userName ? 
                    "Tuyệt vời! {$userName} đã tham gia thành công sự kiện {$eventName}" :
                    "Chúc mừng bạn đã chính thức hoàn thành sự kiện {$eventName}";
                
                // Tăng số lượng người đăng ký tham gia sự kiện
                $event = $joinRequest->event;
                $event->registered_participants += 1;
                $event->save();
            }
        } 
        // Nếu trạng thái là rejected và trạng thái cũ là approved, giảm số lượng
        else if ($validatedData['status'] === 'rejected' && $oldStatus === 'approved') {
            $updateData['responded_at'] = now();
            
            if ($joinRequest->type === 'club') {
                // Giảm số lượng thành viên của câu lạc bộ
                $club = $joinRequest->club;
                if ($club->member_count > 0) {
                    $club->member_count -= 1;
                    $club->save();
                }
            } else {
                // Giảm số lượng người đăng ký tham gia sự kiện
                $event = $joinRequest->event;
                if ($event->registered_participants > 0) {
                    $event->registered_participants -= 1;
                    $event->save();
                }
            }
        }

        // Chỉ thêm response_message nếu nó được cung cấp
        if (isset($validatedData['response_message'])) {
            $updateData['response_message'] = $validatedData['response_message'];
        }

        $joinRequest->update($updateData);

        // Gửi thông báo cho người dùng
        event(new JoinRequestNotification($joinRequest));

        return response()->json([
            'message' => 'Đã cập nhật trạng thái yêu cầu',
            'data' => $joinRequest->load(['user', 'club', 'event'])
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(JoinRequest $joinRequest)
    {
        $joinRequest->delete();

        return response()->json(null, 204);
    }

    /**
     * Kiểm tra trạng thái tham gia club của user
     */
    public function checkClubStatus($user_id, $club_id)
    {
        // Kiểm tra xem user có phải là chủ câu lạc bộ không
        $club = Club::findOrFail($club_id);

        if ($club->user_id == $user_id) {
            return response()->json([
                'status' => 'approved',
                'message' => 'Đã là thành viên'
            ]);
        }

        $request = JoinRequest::where('user_id', $user_id)
            ->where('club_id', $club_id)
            ->where('type', 'club')
            ->latest()
            ->first();

        if (!$request) {
            return response()->json([
                'status' => 'not_joined',
                'message' => 'Chưa tham gia câu lạc bộ'
            ]);
        }

        return response()->json([
            'status' => $request->status,
            'message' => match ($request->status) {
                'request' => 'Đang chờ duyệt',
                'approved' => 'Đã là thành viên',
                'rejected' => 'Yêu cầu bị từ chối',
                default => 'Trạng thái không xác định'
            },
            'request' => $request
        ]);
    }

    /**
     * Kiểm tra trạng thái tham gia event của user
     */
    public function checkEventStatus($user_id, $event_id)
    {
        $request = JoinRequest::where('user_id', $user_id)
            ->where('event_id', $event_id)
            ->where('type', 'event')
            ->latest()
            ->first();

        if (!$request) {
            return response()->json([
                'status' => 'not_joined',
                'message' => 'Chưa đăng ký sự kiện'
            ]);
        }

        return response()->json([
            'status' => $request->status,
            'message' => match ($request->status) {
                'request' => 'Đang chờ duyệt',
                'approved' => 'Đã đăng ký thành công',
                'rejected' => 'Yêu cầu bị từ chối',
                default => 'Trạng thái không xác định'
            },
            'request' => $request
        ]);
    }

    public function inviteUser(Request $request)
    {
        $validatedData = $request->validate([
            'email' => 'required|email|exists:users,email',
            'club_id' => 'required|exists:clubs,id',
            'message' => 'nullable|string|max:500',
        ]);

        // Tìm người dùng theo email và lấy user_id
        $user = User::where('email', $validatedData['email'])->first();
        $userId = $user->id; // Lấy user_id từ người dùng

        // Kiểm tra xem người dùng đã là thành viên của câu lạc bộ chưa
        $isClubMember = JoinRequest::where('user_id', $userId)
            ->where('club_id', $validatedData['club_id'])
            ->where('type', 'club')
            ->where('status', 'approved')
            ->exists();

        if ($isClubMember) {
            return response()->json([
                'message' => 'Người dùng đã là thành viên của câu lạc bộ này.',
            ], 400);
        }

        // Kiểm tra xem đã có yêu cầu nào chưa
        $existingRequest = JoinRequest::where('user_id', $userId)
            ->where('club_id', $validatedData['club_id'])
            ->where('status', 'invite')
            ->first();

        if ($existingRequest) {
            // Cập nhật thời gian mời và message nếu có
            $existingRequest->responded_at = now();
            if (isset($validatedData['message'])) {
                $existingRequest->message = $validatedData['message'];
            }
            $existingRequest->save();

            return response()->json([
                'message' => 'Đã cập nhật lời mời tham gia câu lạc bộ.',
                'request' => $existingRequest
            ], 200);
        }

        // Tạo yêu cầu mới
        $joinRequest = new JoinRequest();
        $joinRequest->user_id = $userId; // Lưu user_id vào join_requests
        $joinRequest->club_id = $validatedData['club_id'];
        $joinRequest->type = 'club';
        $joinRequest->status = 'invite';
        $joinRequest->message = $validatedData['message'] ?? null;
        $joinRequest->responded_at = now(); // Thêm thời gian mời
        $joinRequest->save();

        return response()->json([
            'message' => 'Đã gửi lời mời thành công.',
            'data' => $joinRequest
        ], 201);
    }

    /**
     * Lấy danh sách các câu lạc bộ mà người dùng đã tham gia
     */
    public function getUserClubs($user_id)
    {
        $joinRequests = JoinRequest::with(['club', 'club.backgroundImages'])
    ->where('user_id', $user_id)
    ->where('type', 'club')
    ->where('status', 'approved')
    ->get();

        $clubs = $joinRequests->map(function ($request) {
            return $request->club;
        })->filter()->values();

        return $clubs;
    }

    /**
     * Lấy danh sách các sự kiện mà người dùng đã đăng ký tham gia
     */
    public function getUserEvents($user_id)
    {
        $joinRequests = JoinRequest::with(['event', 'event.backgroundImages', 'event.club', 'event.category'])
            ->where('user_id', $user_id)
            ->where('type', 'event')
            ->where('status', 'approved')
            ->get();

        $events = $joinRequests->map(function ($request) {
            return $request->event;
        })->filter()->values();

        return $events;
    }
}
