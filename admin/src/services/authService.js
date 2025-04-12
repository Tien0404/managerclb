import axios from 'axios';

const API_URL = 'http://localhost:8000/api/authad'; // Thay đổi đường dẫn này theo API của bạn

const authService = {
    async login(credentials) {
        try {
            const response = await axios.post(`${API_URL}/login`, credentials);
            const { access_token, user } = response.data; // Lấy access_token và user từ phản hồi

            // Lưu token và thông tin người dùng vào localStorage
            localStorage.setItem('authToken', access_token);
            localStorage.setItem('user', JSON.stringify(user));

            return response.data; // Trả về dữ liệu người dùng hoặc thông tin khác nếu cần
        } catch (error) {
            console.error('Đăng nhập không thành công:', error);
            throw error; // Ném lỗi lên để xử lý ở nơi gọi
        }
    },

    logout() {
        localStorage.removeItem('authToken'); 
        localStorage.removeItem('user'); 
    },

    isAuthenticated() {
        return !!localStorage.getItem('authToken');
    },

    getUser() {
        const user = localStorage.getItem('user'); 
        return user ? JSON.parse(user) : null; 
    },

    isTokenExpired(token) {
        const tokenPayload = JSON.parse(atob(token.split('.')[1])); 
        const expirationTime = tokenPayload.exp * 1000; 
        if (Date.now() >= expirationTime) {
            localStorage.removeItem('authToken');
            localStorage.removeItem('user');
            return true; 
        }    
        return false; 
    }
};

export default authService;