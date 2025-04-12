<?php

namespace App\Http\Controllers\Api;

use App\Models\Department;
use App\Models\Club;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class DepartmentController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index($club_id)
    {
        // Get club with owner information first
        $club = Club::with(['user', 'user.backgroundImages'])->findOrFail($club_id);

        // Get departments with their managers
        $departments = Department::where('club_id', $club_id)
            ->with(['user', 'user.backgroundImages'])
            ->get();

        // Create response structure
        $response = [
            'club' => [
                'id' => $club->id,
                'name' => $club->name,
                'owner' => [
                    'id' => $club->user->id,
                    'username' => $club->user->username,
                    'email' => $club->user->email,
                    'phone' => $club->user->phone,
                    'gender' => $club->user->gender,
                    'description' => $club->user->description,
                    'background_images' => $club->user->backgroundImages
                ]
            ],
            'departments' => $departments
        ];

        return response()->json($response);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $request->validate([
            'club_id' => 'required|exists:clubs,id',
            'user_id' => 'required|exists:users,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'manage_clubs' => 'boolean',
            'manage_events' => 'boolean',
            'manage_members' => 'boolean',
            'manage_blogs' => 'boolean',
            'manage_feedback' => 'boolean'
        ]);

        $department = Department::create($request->all());
        return response()->json($department, 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Department $department)
    {
        return response()->json($department);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Department $department)
    {
        $request->validate([
            'club_id' => 'sometimes|exists:clubs,id',
            'user_id' => 'sometimes|exists:users,id',
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'manage_clubs' => 'sometimes|boolean',
            'manage_events' => 'sometimes|boolean',
            'manage_members' => 'sometimes|boolean',
            'manage_blogs' => 'sometimes|boolean',
            'manage_feedback' => 'sometimes|boolean'
        ]);

        $department->update($request->all());
        return response()->json($department);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(Department $department)
    {
        $department->delete();

        return response()->json(null, 204);
    }

    /**
     * Check department permissions for a user in a club
     *
     * @param  int  $user_id
     * @param  int  $club_id
     * @return \Illuminate\Http\Response
     */
    public function checkDepartment($user_id, $club_id)
    {
        // Check if club exists
        $club = Club::findOrFail($club_id);

        // Get department information for the user in the club
        $department = Department::where('club_id', $club_id)
            ->where('user_id', $user_id)
            ->first();

        if (!$department) {
            return response()->json([
                'message' => 'User is not a department manager in this club',
                'has_department' => false,
                'owner_id' => $club->user_id
            ]);
        }

        return response()->json([
            'owner_id' => $club->user_id,
            'id' => $department->id,
            'name' => $department->name,
            'description' => $department->description,
            'manage_clubs' => $department->manage_clubs,
            'manage_events' => $department->manage_events,
            'manage_members' => $department->manage_members,
            'manage_blogs' => $department->manage_blogs,
            'manage_feedback' => $department->manage_feedback
        ]);
    }

    /**
     * Lấy tất cả các phòng ban của một câu lạc bộ
     *
     * @param  int  $club_id
     * @return \Illuminate\Http\Response
     */
    public function getDepartmentByClubId($club_id)
    {
        $department = Department::where('club_id', $club_id)->get();
        return response()->json($department);
    }
}
