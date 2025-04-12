<?php

namespace App\Http\Controllers\Api;
use App\Models\Feedback;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class FeedbackController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return Feedback::with('club')->orderBy('id', 'desc')->get();
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
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'mobile' => 'nullable|string|max:20',
            'comment' => 'required|string',
        ]);
        $feedbackData= $request->all();
        if (!isset($feedbackData['status'])) {
            $feedbackData['status'] = 'pending';
        }
        $feedback = Feedback::create($feedbackData);
        return response()->json($feedback, 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Feedback $feedback)
    {
        return $feedback->load('club');
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Feedback $feedback)
    {
        $request->validate([
            'club_id' => 'sometimes|exists:clubs,id',
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|max:255',
            'mobile' => 'nullable|string|max:20',
            'comment' => 'sometimes|string',
            'club_response' => 'nullable|string|max:1000', // Thêm validation cho phản hồi club
            'status' => 'sometimes|string|in:pending,resolved',
        ]);
    
        if ($request->has('club_response')) {
            $feedback->status = 'resolved'; // Tự động cập nhật status thành resolved khi có phản hồi
        }
    
        $feedback->update($request->all());
        return response()->json($feedback);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(Feedback $feedback)
    {
        $feedback->delete();
        return response()->json(null, 204);
    }

    /**
     * Get all feedbacks for a specific club.
     *
     * @param  int  $club_id
     * @return \Illuminate\Http\Response
     */
    public function getClubFeedbacks($club_id)
    {
        return Feedback::with('club')
            ->where('club_id', $club_id)
            ->orderBy('created_at', 'desc')
            ->get();
    }
}
