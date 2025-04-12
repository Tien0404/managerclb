<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\ClubController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\FeedbackController;
use App\Http\Controllers\Api\BlogController;
use App\Http\Controllers\Api\JoinRequestController;
use App\Http\Controllers\Api\InvitationController;
use App\Http\Controllers\Api\UserEventController;
use App\Http\Controllers\Api\BackgroundImageController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\RegisterControllerAD;
use App\Http\Controllers\Auth\VerificationController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\LoginControllerAD;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\Api\NotificationController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::prefix('users')->group(function () {
    Route::get('/', [UserController::class, 'index']);
    Route::post('/', [UserController::class, 'store']);
    Route::get('/{user}', [UserController::class, 'show']);
    Route::match(['put', 'patch', 'post'], '/{user}', [UserController::class, 'update']);
    Route::delete('/{user}', [UserController::class, 'destroy']);
});

Route::prefix('clubs')->group(function () {
    Route::get('/', [ClubController::class, 'index']);
    Route::post('/', [ClubController::class, 'store']);
    Route::get('/search', [ClubController::class, 'search']);
    Route::get('/user/{userId}', [ClubController::class, 'getClbUser']);
    Route::get('/{club}', [ClubController::class, 'show']);
    Route::match(['put', 'patch', 'post'], '/{club}', [ClubController::class, 'update']);
    Route::delete('/{club}', [ClubController::class, 'destroy']);
    Route::match(['put', 'patch', 'post'], '/{clubId}/images/{imageId}', [ClubController::class, 'updateImage']);
});

Route::prefix('categories')->group(function () {
    Route::get('/', [CategoryController::class, 'index']);
    Route::post('/', [CategoryController::class, 'store']);
    Route::get('/{category}', [CategoryController::class, 'show']);
    Route::patch('/{category}', [CategoryController::class, 'update']);
    Route::delete('/{category}', [CategoryController::class, 'destroy']);
});

Route::prefix('departments')->group(function () {
    Route::get('/club/{club_id} ', [DepartmentController::class, 'index']); // get all departments by club id
    Route::post('/', [DepartmentController::class, 'store']); // create a new department
    Route::get('/{department}', [DepartmentController::class, 'show']); // get a single department
    Route::patch('/{department}', [DepartmentController::class, 'update']); // update a department
    Route::delete('/{department}', [DepartmentController::class, 'destroy']); // delete a department
    Route::get('/check/{user_id}/{club_id}', [DepartmentController::class, 'checkDepartment']); // check user's role in a club
    Route::get('/club/{club_id}', [DepartmentController::class, 'getDepartmentByClubId']); // get all departments by club id
});

Route::prefix('events')->group(function () {
    Route::get('/search', [EventController::class, 'search']); // search events
    Route::get('/club/{event}', [EventController::class, 'showClbEvent']); // get events by club id
    Route::get('/', [EventController::class, 'index']); // get all events
    Route::post('/', [EventController::class, 'store']); // create a new event
    Route::get('/{event}', [EventController::class, 'show']); // get a single event
    Route::match(['put', 'patch', 'post'], '/{event}', [EventController::class, 'update']); //Update event
    Route::delete('/{event}', [EventController::class, 'destroy']); // delete an event
});

Route::prefix('feedbacks')->group(function () {
    Route::get('/', [FeedbackController::class, 'index']);
    Route::post('/', [FeedbackController::class, 'store']);
    Route::get('/{feedback}', [FeedbackController::class, 'show']);
    Route::match(['put', 'patch', 'post'], '/{feedback}', [FeedbackController::class, 'update']);
    Route::delete('/{feedback}', [FeedbackController::class, 'destroy']);
    Route::get('/club/{club_id}', [FeedbackController::class, 'getClubFeedbacks']);
});

Route::prefix('blogs')->group(function () {
    Route::get('/', [BlogController::class, 'index']); // get all blogs 
    Route::post('/', [BlogController::class, 'store']); // create a new blog
    Route::get('/{blog}', [BlogController::class, 'show']); // get a single blog
    Route::match(['put', 'patch', 'post'], '/{blog}', [BlogController::class, 'update']); // update a blog
    Route::delete('/{blog}', [BlogController::class, 'destroy']); // delete a blog
    Route::get('/club/{club_id}', [BlogController::class, 'getClubBlogs']); // get all blogs by club id
});

Route::prefix('join-requests')->group(function () {
    Route::get('/club/{club_id}', [JoinRequestController::class, 'getClubRequests']); // Lấy tất cả requests của một club
    Route::get('/event/{event_id}', [JoinRequestController::class, 'getEventRequests']); // Lấy tất cả requests của một event
    Route::get('/user/{user_id}', [JoinRequestController::class, 'getUserRequests']); // Lấy tất cả requests của một user
    Route::get('/user/{user_id}/clubs', [JoinRequestController::class, 'getUserClubs']); // Lấy danh sách CLB mà user đã tham gia
    Route::get('/user/{user_id}/events', [JoinRequestController::class, 'getUserEvents']); // Lấy danh sách sự kiện mà user đã đăng ký
    Route::post('/', [JoinRequestController::class, 'store']); // create a new join request
    Route::post('/email', [JoinRequestController::class, 'inviteUser']);
    Route::get('/{joinRequest}', [JoinRequestController::class, 'show']); // get a single join request
    Route::patch('/{joinRequest}', [JoinRequestController::class, 'update']); // update a join request
    Route::delete('/{joinRequest}', [JoinRequestController::class, 'destroy']); // delete a join request
    Route::get('/check-club/{user_id}/{club_id}', [JoinRequestController::class, 'checkClubStatus']); // Kiểm tra trạng thái tham gia club
    Route::get('/check-event/{user_id}/{event_id}', [JoinRequestController::class, 'checkEventStatus']); // Kiểm tra trạng thái tham gia event  
});


Route::prefix('background-images')->group(function () {
    Route::get('/', [BackgroundImageController::class, 'index']); // get all background images
    Route::post('/upload-image', [BackgroundImageController::class, 'uploadImage']); // upload an image
    Route::post('/upload-video', [BackgroundImageController::class, 'uploadVideo']); // upload a video
    Route::get('/{backgroundImage}', [BackgroundImageController::class, 'show']); // get a single background image
    Route::put('/{backgroundImage}', [BackgroundImageController::class, 'update']); // update a background image
    Route::delete('/{backgroundImage}/delete-image', [BackgroundImageController::class, 'deleteImage']); // delete an image
    Route::delete('/{backgroundImage}/delete-video', [BackgroundImageController::class, 'deleteVideo']); // delete a video
});


Route::prefix('auth')->group(function () {
    Route::post('register', [RegisterController::class, 'register'])->middleware('validate.registration');
    Route::post('verify-email', [VerificationController::class, 'verify']);
    Route::post('login', [LoginController::class, 'login']);
    Route::post('forgotpass', [ForgotPasswordController::class, 'sendResetLinkEmail']);
    Route::post('reset-password', [ResetPasswordController::class, 'resetPassword']);
});


Route::prefix('authad')->group(function () {
    Route::post('login', [LoginControllerAD::class, 'login']);
});

// Notification routes
Route::prefix('notifications')->middleware(['auth:sanctum', 'notifications'])->group(function () {
    Route::get('/', [NotificationController::class, 'index']);
    Route::post('/{id}/mark-as-read', [NotificationController::class, 'markAsRead']);
    Route::post('/mark-all-read', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/{id}', [NotificationController::class, 'destroy']);
    Route::delete('/', [NotificationController::class, 'destroyAll']);
});
