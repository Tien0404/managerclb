# Manager CLB - Hệ thống Quản lý Câu lạc bộ

Hệ thống quản lý câu lạc bộ toàn diện với website người dùng, trang quản trị, API server và ứng dụng di động.

## Tổng quan

Manager CLB là một nền tảng toàn diện được thiết kế để hỗ trợ quản lý câu lạc bộ, sự kiện và thành viên. Hệ thống bao gồm:

- **Website** (Vue.js): Giao diện người dùng
- **Admin Dashboard** (Vue.js + Vuetify): Giao diện quản trị
- **Server API** (Laravel): Backend xử lý dữ liệu
- **Ứng dụng di động** (Flutter): Trải nghiệm di động đa nền tảng

## Kiến trúc hệ thống

![Kiến trúc hệ thống](https://via.placeholder.com/800x400?text=System+Architecture)

- **Frontend**: Giao diện người dùng (Vue.js) và giao diện quản trị (Vue.js + Vuetify)
- **Backend**: API RESTful (Laravel) với xác thực và phân quyền
- **Mobile**: Ứng dụng đa nền tảng (Flutter) với khả năng làm việc ngoại tuyến
- **Database**: MySQL/PostgreSQL (quản lý bởi Laravel)
- **File Storage**: Cloudinary (quản lý hình ảnh và video)

## Tính năng chính

### Website
- Xem danh sách câu lạc bộ và sự kiện
- Đăng ký tham gia câu lạc bộ và sự kiện
- Đọc bài viết và tin tức
- Xem thông tin cá nhân và hoạt động
- Gửi phản hồi

### Admin Dashboard
- Quản lý người dùng và phân quyền
- Quản lý câu lạc bộ và bộ phận
- Quản lý sự kiện và đăng ký
- Quản lý bài viết và nội dung
- Xem báo cáo và thống kê

### Server API
- Xác thực và phân quyền
- Quản lý CRUD cho tất cả đối tượng
- Xử lý file và hình ảnh
- Thông báo và email
- Quản lý yêu cầu tham gia

### Ứng dụng di động
- Đăng nhập và quản lý hồ sơ
- Xem và tham gia câu lạc bộ/sự kiện
- Đọc bài viết
- Nhận thông báo
- Hỗ trợ làm việc ngoại tuyến

## Công nghệ sử dụng

### Frontend (Website)
- Vue.js 3
- Vite
- Tailwind CSS
- Pinia (State Management)
- Vue Router
- Axios

### Frontend (Admin)
- Vue.js 3
- TypeScript
- Vuetify 3
- Pinia
- Vue Router
- ApexCharts
- Axios

### Backend (Server)
- Laravel 9
- PHP 8.0+
- Laravel Sanctum (Authentication)
- Cloudinary
- MySQL/PostgreSQL

### Mobile
- Flutter
- Dart
- Provider/Bloc (State Management)
- Hive (Local Storage)
- Dio/HTTP (Network)
- Flutter Local Notifications

## Cấu trúc thư mục

```
managerclb/
├── admin/                # Admin Dashboard
│   ├── public/           # Static assets
│   ├── src/              # Source code
│   └── ...
├── website/              # User Website
│   ├── public/           # Static assets
│   ├── src/              # Source code
│   └── ...
├── server/               # Backend API
│   ├── app/              # Application code
│   ├── config/           # Configuration files
│   ├── database/         # Migrations and seeds
│   ├── routes/           # API routes
│   └── ...
└── Application/          # Mobile App
    ├── android/          # Android platform code
    ├── ios/              # iOS platform code
    ├── lib/              # Dart source code
    └── ...
```

## Cài đặt và triển khai

### Yêu cầu hệ thống
- Node.js 16+
- PHP 8.0+
- Composer
- MySQL/PostgreSQL
- Flutter SDK 3.5+
- Git

### Backend (Server)
```bash
# Clone repository
git clone https://github.com/username/managerclb.git
cd managerclb/server

# Cài đặt dependencies
composer install

# Cấu hình môi trường
cp .env.example .env
php artisan key:generate

# Cấu hình database
# Chỉnh sửa file .env

# Chạy migrations
php artisan migrate --seed

# Khởi động server
php artisan serve
```

### Frontend (Website)
```bash
# Đi đến thư mục website
cd managerclb/website

# Cài đặt dependencies
npm install

# Cấu hình API endpoint
# Chỉnh sửa file .env

# Khởi động server dev
npm run dev

# Build cho production
npm run build
```

### Admin Dashboard
```bash
# Đi đến thư mục admin
cd managerclb/admin

# Cài đặt dependencies
npm install

# Cấu hình API endpoint
# Chỉnh sửa file .env

# Khởi động server dev
npm run dev

# Build cho production
npm run build
```

### Ứng dụng di động
```bash
# Đi đến thư mục Application
cd managerclb/Application

# Lấy Flutter dependencies
flutter pub get

# Cấu hình API endpoint
# Chỉnh sửa file lib/config/constants.dart

# Chạy ứng dụng (development)
flutter run

# Build cho Android
flutter build apk

# Build cho iOS
flutter build ios
```

## Tài liệu API

API được tổ chức theo RESTful với các endpoint chính:

- `/api/auth` - Xác thực và đăng ký
- `/api/users` - Quản lý người dùng
- `/api/clubs` - Quản lý câu lạc bộ
- `/api/departments` - Quản lý bộ phận
- `/api/events` - Quản lý sự kiện
- `/api/blogs` - Quản lý bài viết
- `/api/feedbacks` - Quản lý phản hồi
- `/api/join-requests` - Quản lý yêu cầu tham gia
- `/api/notifications` - Quản lý thông báo

Chi tiết API có thể tìm thấy trong tệp tin `server/routes/api.php`.

## Mô hình dữ liệu

### Các đối tượng chính
- **User**: Người dùng hệ thống
- **Club**: Câu lạc bộ
- **Department**: Bộ phận trong câu lạc bộ
- **Event**: Sự kiện
- **Blog**: Bài viết
- **Feedback**: Phản hồi
- **JoinRequest**: Yêu cầu tham gia
- **Notification**: Thông báo

## Đóng góp

1. Fork dự án
2. Tạo nhánh tính năng (`git checkout -b feature/amazing-feature`)
3. Commit thay đổi (`git commit -m 'Add some amazing feature'`)
4. Push lên nhánh (`git push origin feature/amazing-feature`)
5. Mở Pull Request

## Giấy phép

Dự án này được cấp phép theo [MIT License](LICENSE).

## Liên hệ

- Email: example@example.com
- Website: https://example.com
- GitHub: https://github.com/username/managerclb 