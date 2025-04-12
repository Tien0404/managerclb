<?php

namespace App\Http\Controllers\Api;

use App\Notify\EventCreated;        
use App\Models\Event;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return Event::with(['club', 'category',  'backgroundImages'])->orderBy('id', 'desc')->get();
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        try {
            // 1. Validate dữ liệu
            $validatedData = $request->validate([
                'club_id' => 'required|exists:clubs,id',
                'category_id' => 'required|exists:categories,id',
                'name' => 'required|string|max:255',
                'start_date' => 'required|date',
                'end_date' => 'required|date|after_or_equal:start_date',
                'location' => 'required|string|max:255',
                'max_participants' => 'required|integer|min:1',
                'content' => 'required|string',
                'status' => 'sometimes|string|in:active,inactive,cancelled,completed',
                'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048'
            ]);

            // 2. Tạo event
            $eventData = $request->except(['logo']);
            if (!isset($eventData['status'])) {
                $eventData['status'] = 'active';
            }
            $event = Event::create($eventData);

            // 3. Xử lý upload ảnh đại diện
            if ($request->hasFile('logo')) {
                $backgroundImage = new \App\Models\BackgroundImage();
                $backgroundImage->event_id = $event->id;
                $backgroundImage->is_logo = 1;
                $backgroundImage->uploadImage($request->file('logo'));
            }

            // 4. Dispatch event
            event(new EventCreated($event));

            return response()->json([
                'message' => 'Tạo sự kiện thành công',
                'data' => $event->load(['club', 'category', 'backgroundImages'])
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Lỗi khi tạo sự kiện',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Event $event)
    {
        return response()->json($event->load([
            'club',
            'category',
            'backgroundImages',
            'club.backgroundImages' => function ($query) {
                $query->where('is_logo', 1);
            }
        ]));
    }

    /**
     * Display all events of a specific club.
     *
     * @param  int  $club_id
     * @return \Illuminate\Http\Response
     */
    public function showClbEvent($club_id)
    {
        // Lấy tất cả các sự kiện của club dựa vào club_id
        $events = Event::where('club_id', $club_id)->get();

        // Kiểm tra nếu không có sự kiện nào
        if ($events->isEmpty()) {
            return response()->json([
                'message' => 'No events found for this club.',
            ], 404);
        }

        // Trả về danh sách sự kiện
        return response()->json($events->load(['club', 'backgroundImages']));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Event $event)
    {
        try {
            // 1. Validate dữ liệu
            $validatedData = validator($request->except(['logo', 'images', 'deleted_image_ids']), [
                'club_id' => 'sometimes|exists:clubs,id',
                'category_id' => 'sometimes|exists:categories,id',
                'name' => 'sometimes|string|max:255',
                'start_date' => 'sometimes|date',
                'end_date' => 'sometimes|date|after_or_equal:start_date',
                'location' => 'sometimes|string|max:255',
                'max_participants' => 'sometimes|integer|min:1',
                'content' => 'sometimes|string',
                'status' => 'sometimes|string|in:active,inactive,cancelled,completed'
            ])->validate();

            // Validate files nếu có
            if ($request->hasFile('logo')) {
                validator($request->all(), ['logo' => 'image|mimes:jpeg,png,jpg,gif|max:2048'])->validate();
            }
            if ($request->hasFile('images')) {
                validator($request->all(), ['images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'])->validate();
            }

            // 2. Cập nhật thông tin cơ bản
            $event->update($validatedData);

            // 3. Xử lý upload ảnh đại diện mới
            if ($request->hasFile('logo')) {
                // Xóa ảnh đại diện cũ
                $existingLogo = $event->backgroundImages()->where('is_logo', 1)->first();
                if ($existingLogo) {
                    $existingLogo->deleteImage();
                    $existingLogo->delete();
                }

                // Upload ảnh đại diện mới
                $backgroundImage = new \App\Models\BackgroundImage();
                $backgroundImage->event_id = $event->id;
                $backgroundImage->is_logo = 1;
                $backgroundImage->uploadImage($request->file('logo'));
            }

            // 4. Xử lý upload nhiều ảnh mới
            if ($request->hasFile('images')) {
                foreach ($request->file('images') as $image) {
                    $backgroundImage = new \App\Models\BackgroundImage();
                    $backgroundImage->event_id = $event->id;
                    $backgroundImage->is_logo = 0;
                    $backgroundImage->uploadImage($image);
                }
            }

            // 5. Xử lý xóa ảnh
            if ($request->has('deleted_image_ids')) {
                $deletedImageIds = explode(',', $request->deleted_image_ids);
                $imagesToDelete = $event->backgroundImages()
                    ->whereIn('id', $deletedImageIds)
                    ->where('is_logo', 0)
                    ->get();

                foreach ($imagesToDelete as $image) {
                    $image->deleteImage();
                    $image->delete();
                }
            }

            return response()->json([
                'message' => 'Cập nhật sự kiện thành công',
                'data' => $event->load(['club', 'category', 'backgroundImages'])
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Lỗi khi cập nhật sự kiện',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(Event $event)
    {
        $event->delete();
        return response()->json(null, 204);
    }

    /**
     * Search for events based on one or more attributes.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function search(Request $request)
    {
        $query = Event::query();

        // Tìm kiếm theo tên sự kiện (tìm kiếm mờ)
        if ($request->has('name')) {
            $query->where('name', 'like', '%' . $request->name . '%');
        }

        // Tìm kiếm theo ID của câu lạc bộ
        if ($request->has('club_id')) {
            $query->where('club_id', $request->club_id);
        }

        // Tìm kiếm theo ID của danh mục
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Tìm kiếm theo thời gian bắt đầu (từ ngày)
        if ($request->has('start_date_from')) {
            $query->where('start_date', '>=', $request->start_date_from);
        }

        // Tìm kiếm theo thời gian bắt đầu (đến ngày)
        if ($request->has('start_date_to')) {
            $query->where('start_date', '<=', $request->start_date_to);
        }

        // Tìm kiếm theo thời gian kết thúc (từ ngày)
        if ($request->has('end_date_from')) {
            $query->where('end_date', '>=', $request->end_date_from);
        }

        // Tìm kiếm theo thời gian kết thúc (đến ngày)
        if ($request->has('end_date_to')) {
            $query->where('end_date', '<=', $request->end_date_to);
        }

        // Tìm kiếm theo vị trí (tìm kiếm mờ)
        if ($request->has('location')) {
            $query->where('location', 'like', '%' . $request->location . '%');
        }

        // Tìm kiếm theo trạng thái
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Tìm kiếm theo số người tham gia tối đa
        if ($request->has('max_participants')) {
            $query->where('max_participants', '=', $request->max_participants);
        }

        // Tìm kiếm sự kiện có số người tham gia tối đa lớn hơn
        if ($request->has('min_participants')) {
            $query->where('max_participants', '>=', $request->min_participants);
        }

        // Tìm kiếm theo nội dung (tìm kiếm mờ)
        if ($request->has('content')) {
            $query->where('content', 'like', '%' . $request->content . '%');
        }

        // Sắp xếp kết quả
        if ($request->has('sort_by')) {
            $sortDirection = $request->has('sort_direction') ? $request->sort_direction : 'asc';
            $query->orderBy($request->sort_by, $sortDirection);
        } else {
            // Mặc định sắp xếp theo ngày bắt đầu
            $query->orderBy('start_date', 'asc');
        }

        // Trả về kết quả với phân trang nếu cần
        $perPage = $request->has('per_page') ? $request->per_page : 10;

        if ($request->has('paginate') && $request->paginate === 'false') {
            $events = $query->get();
            return response()->json($events->load(['club', 'category', 'backgroundImages']));
        } else {
            $events = $query->paginate($perPage);
            return response()->json($events->load(['club', 'category', 'backgroundImages']));
        }
    }
}
