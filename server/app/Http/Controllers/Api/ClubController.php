<?php

namespace App\Http\Controllers\Api;

use App\Models\Club;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class ClubController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $clubs = Club::with('backgroundImages')->orderBy('id', 'desc')->get();
        return response()->json($clubs);
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
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:255',
            'contact_email' => 'nullable|email',
        ]);
        $club = Club::create(array_merge($validatedData, ['status' => 'pending']));

       

        return response()->json($club, 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Club $club)
    {
        // Load the club with its relationships
        $club->load([
            'user',
            'category',
            'events.backgroundImages'
        ]);
        
        // Get the logo image (if exists)
        $logoImage = $club->backgroundImages()->where('is_logo', 1)->first();
        
        // Get up to 5 non-logo images
        $otherImages = $club->backgroundImages()->where('is_logo', 0)->take(5)->get();
        
        // Create a new collection with logo and other images
        $backgroundImages = collect();
        
        if ($logoImage) {
            $backgroundImages->push($logoImage);
        }
        
        $backgroundImages = $backgroundImages->concat($otherImages);
        
        // Set the backgroundImages relation manually
        $club->setRelation('backgroundImages', $backgroundImages);
        
        return response()->json($club);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function getClbUser($userId)
    {
        // Tìm user dựa trên userId
        $user = User::findOrFail($userId);

        // Lấy danh sách các club của user kèm theo background images có is_logo = 1
        $clubs = $user->clubs()->with(['backgroundImages' => function ($query) {
            $query->where('is_logo', 1);
        }])->get();

        // Trả về thông tin của các club dưới dạng JSON
        return response()->json($clubs);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  Club  $club
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Club $club)
    {
        try {
            // 1. Validate tất cả dữ liệu đầu vào
            $this->validateUpdateRequest($request);

            // 2. Cập nhật thông tin cơ bản của club
            $club->update($request->except(['logo', 'images', 'deleted_image_ids', 'update_image_id', 'delete_image_id']));

            // 3. Xử lý ảnh đại diện (logo)
            if ($request->hasFile('logo')) {
                $this->handleLogoUpload($club, $request->file('logo'));
            }

            // 4. Xử lý upload nhiều ảnh
            if ($request->hasFile('images')) {
                $this->handleImagesUpload($club, $request->file('images'));
            }

            // 5. Xử lý xóa ảnh
            if ($request->has('deleted_image_ids')) {
                $this->handleImageDeletions($club, $request->deleted_image_ids);
            }
            
            // 6. Xử lý cập nhật một ảnh cụ thể
            if ($request->has('update_image_id') && $request->hasFile('update_image')) {
                $this->handleSingleImageUpdate($club, $request->update_image_id, $request->file('update_image'));
            }
            
            // 7. Xử lý xóa một ảnh cụ thể
            if ($request->has('delete_image_id')) {
                $this->handleSingleImageDeletion($club, $request->delete_image_id);
            }

            // 8. Load relationships và trả về response
            // Get the logo image (if exists)
            $logoImage = $club->backgroundImages()->where('is_logo', 1)->first();
            
            // Get up to 5 non-logo images
            $otherImages = $club->backgroundImages()->where('is_logo', 0)->take(5)->get();
            
            // Create a new collection with logo and other images
            $backgroundImages = collect();
            
            if ($logoImage) {
                $backgroundImages->push($logoImage);
            }
            
            $backgroundImages = $backgroundImages->concat($otherImages);
            
            return response()->json([
                'message' => 'Cập nhật câu lạc bộ thành công',
                'data' => $club->load(['user', 'category'])->setRelation('backgroundImages', $backgroundImages)
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Lỗi khi cập nhật câu lạc bộ',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Validate dữ liệu cập nhật
     */
    private function validateUpdateRequest(Request $request)
    {
        // Validate thông tin cơ bản
        $rules = [
            'user_id' => 'sometimes|exists:users,id',
            'category_id' => 'sometimes|exists:categories,id',
            'name' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'contact_email' => 'sometimes|email',
            'contact_phone' => 'sometimes|string',
            'contact_address' => 'sometimes|string',
            'province' => 'sometimes|string',
            'facebook_link' => 'sometimes|string',
            'zalo_link' => 'sometimes|string',
            'status' => 'sometimes|string|in:active,inactive',
            'update_image_id' => 'sometimes|exists:background_images,id',
            'delete_image_id' => 'sometimes|exists:background_images,id'
        ];

        // Thêm rules cho files nếu có
        if ($request->hasFile('logo')) {
            $rules['logo'] = 'image|mimes:jpeg,png,jpg,gif|max:2048';
        }

        if ($request->hasFile('images')) {
            $rules['images.*'] = 'image|mimes:jpeg,png,jpg,gif|max:2048';
        }
        
        if ($request->hasFile('update_image')) {
            $rules['update_image'] = 'image|mimes:jpeg,png,jpg,gif|max:2048';
        }

        return validator($request->all(), $rules)->validate();
    }

    /**
     * Xử lý upload logo
     */
    private function handleLogoUpload(Club $club, $logoFile)
    {
        // Xóa logo cũ nếu có
        $existingLogo = $club->backgroundImages()->where('is_logo', 1)->first();
        if ($existingLogo) {
            $existingLogo->deleteImage();
            $existingLogo->delete();
        }

        // Upload logo mới
        $backgroundImage = new \App\Models\BackgroundImage();
        $backgroundImage->club_id = $club->id;
        $backgroundImage->is_logo = 1;
        $backgroundImage->uploadImage($logoFile);
    }

    /**
     * Xử lý upload nhiều ảnh
     */
    private function handleImagesUpload(Club $club, array $images)
    {
        foreach ($images as $image) {
            $backgroundImage = new \App\Models\BackgroundImage();
            $backgroundImage->club_id = $club->id;
            $backgroundImage->is_logo = 0;
            $backgroundImage->uploadImage($image);
        }
    }

    /**
     * Xử lý xóa ảnh
     */
    private function handleImageDeletions(Club $club, string $deletedImageIds)
    {
        $imageIds = explode(',', $deletedImageIds);
        $imagesToDelete = $club->backgroundImages()
            ->whereIn('id', $imageIds)
            ->where('is_logo', 0)
            ->get();

        foreach ($imagesToDelete as $image) {
            $image->deleteImage();
            $image->delete();
        }
    }

    /**
     * Xử lý cập nhật một ảnh cụ thể
     */
    private function handleSingleImageUpdate(Club $club, $imageId, $imageFile)
    {
        // Tìm ảnh cần cập nhật
        $image = $club->backgroundImages()->where('id', $imageId)->first();
        
        if (!$image) {
            throw new \Exception('Không tìm thấy ảnh cần cập nhật');
        }
        
        // Kiểm tra xem ảnh có phải là logo không
        if ($image->is_logo) {
            throw new \Exception('Không thể cập nhật ảnh logo bằng phương thức này');
        }
        
        // Xóa ảnh cũ
        $image->deleteImage();
        
        // Upload ảnh mới
        $image->uploadImage($imageFile);
    }
    
    /**
     * Xử lý xóa một ảnh cụ thể
     */
    private function handleSingleImageDeletion(Club $club, $imageId)
    {
        // Tìm ảnh cần xóa
        $image = $club->backgroundImages()->where('id', $imageId)->first();
        
        if (!$image) {
            throw new \Exception('Không tìm thấy ảnh cần xóa');
        }
        
        // Kiểm tra xem ảnh có phải là logo không
        if ($image->is_logo) {
            throw new \Exception('Không thể xóa ảnh logo bằng phương thức này');
        }
        
        // Xóa ảnh
        $image->deleteImage();
        $image->delete();
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(Club $club)
    {
        $club->delete();
        return response()->noContent();
    }

    /**
     * Cập nhật hoặc xóa một ảnh bất kỳ của club (không phải logo)
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $clubId
     * @param  int  $imageId
     * @return \Illuminate\Http\Response
     */
    public function updateImage(Request $request, $clubId, $imageId)
    {
        try {
            // Tìm club
            $club = Club::findOrFail($clubId);
            
            // Tìm ảnh cần cập nhật
            $image = $club->backgroundImages()->where('id', $imageId)->firstOrFail();
            
            // Kiểm tra xem ảnh có phải là logo không
            if ($image->is_logo) {
                return response()->json([
                    'message' => 'Không thể cập nhật ảnh logo bằng phương thức này',
                ], 400);
            }
            
            // Nếu request có chứa action=delete, xóa ảnh
            if ($request->has('action') && $request->action === 'delete') {
                $image->deleteImage();
                $image->delete();
                
                return response()->json([
                    'message' => 'Xóa ảnh thành công',
                ]);
            }
            
            // Nếu request có chứa file ảnh mới, cập nhật ảnh
            if ($request->hasFile('image')) {
                // Validate ảnh mới
                $request->validate([
                    'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
                ]);
                
                // Xóa ảnh cũ
                $image->deleteImage();
                
                // Upload ảnh mới
                $image->uploadImage($request->file('image'));
                
                return response()->json([
                    'message' => 'Cập nhật ảnh thành công',
                    'data' => $image,
                ]);
            }
            
            return response()->json([
                'message' => 'Không có thao tác nào được thực hiện',
            ], 400);
            
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Không tìm thấy club hoặc ảnh',
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Lỗi khi cập nhật ảnh',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
    public function search(Request $request)
    {
        $query = Club::query();

        // Tìm kiếm theo tên câu lạc bộ (tìm kiếm mờ)
        if ($request->has('name')) {
            $query->where('name', 'like', '%' . $request->name . '%');
        }

        // Tìm kiếm theo ID của người tạo
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Tìm kiếm theo ID của danh mục
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Tìm kiếm theo mô tả (tìm kiếm mờ)
        if ($request->has('description')) {
            $query->where('description', 'like', '%' . $request->description . '%');
        }

        // Tìm kiếm theo số lượng thành viên
        if ($request->has('min_members')) {
            $query->where('member_count', '>=', $request->min_members);
        }
        
        if ($request->has('max_members')) {
            $query->where('member_count', '<=', $request->max_members);
        }

        // Tìm kiếm theo email liên hệ (tìm kiếm mờ)
        if ($request->has('contact_email')) {
            $query->where('contact_email', 'like', '%' . $request->contact_email . '%');
        }

        // Tìm kiếm theo số điện thoại liên hệ (tìm kiếm mờ)
        if ($request->has('contact_phone')) {
            $query->where('contact_phone', 'like', '%' . $request->contact_phone . '%');
        }

        // Tìm kiếm theo địa chỉ liên hệ (tìm kiếm mờ)
        if ($request->has('contact_address')) {
            $query->where('contact_address', 'like', '%' . $request->contact_address . '%');
        }

        // Tìm kiếm theo tỉnh/thành phố (tìm kiếm mờ)
        if ($request->has('province')) {
            $query->where('province', 'like', '%' . $request->province . '%');
        }

        // Tìm kiếm theo trạng thái
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Tìm kiếm theo nhiều trạng thái
        if ($request->has('statuses')) {
            $statuses = explode(',', $request->statuses);
            $query->whereIn('status', $statuses);
        }

        // Sắp xếp kết quả
        if ($request->has('sort_by')) {
            $sortDirection = $request->has('sort_direction') ? $request->sort_direction : 'asc';
            $query->orderBy($request->sort_by, $sortDirection);
        } else {
            // Mặc định sắp xếp theo ID
            $query->orderBy('id', 'desc');
        }

        // Tải các quan hệ
        $query->with(['user', 'category', 'backgroundImages']);

        // Trả về kết quả với phân trang nếu cần
        $perPage = $request->has('per_page') ? $request->per_page : 10;

        if ($request->has('paginate') && $request->paginate === 'false') {
            $clubs = $query->get();
            return response()->json($clubs);
        } else {
            $clubs = $query->paginate($perPage);
            return response()->json($clubs);
        }
    }

}
