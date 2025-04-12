import apiClient from "../utils/apiClient";
// import { useAuthStore } from "../stores/authStore";

const saveUserData = (data) => {
  localStorage.setItem('user', JSON.stringify(data.user));
  localStorage.setItem('access_token', data.access_token);
  // Update Authorization header for future requests
  apiClient.defaults.headers.common['Authorization'] = `Bearer ${data.access_token}`;
};

// Khôi phục trạng thái authentication khi refresh
const initializeAuth = () => {
  const token = localStorage.getItem('access_token');
  if (token) {
    apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }
};

// Gọi hàm khởi tạo khi import module
initializeAuth();

export const register = async (userData) => {
  try {
    const response = await apiClient.post("auth/register", userData);
    return response;
  } catch (error) {
    throw new Error(
      "Lỗi khi đăng ký người dùng: " + error.response?.data?.message ||
        error.message
    );
  }
};

export const login = async (userData) => {
  try {
    const response = await apiClient.post("auth/login", userData);
    const data = response.data;
    
    // Save user data and token
    saveUserData(data);
    
    return data;
  } catch (error) {
    console.error("Lỗi khi đăng nhập:", error);
    throw new Error(error.response?.data?.message || error.message);
  }
};

export const logout = () => {
  localStorage.removeItem('user');
  localStorage.removeItem('access_token');
  delete apiClient.defaults.headers.common['Authorization'];
};

export const getCurrentUser = () => {
  const user = localStorage.getItem('user');
  return user ? JSON.parse(user) : null;
};

export const isAuthenticated = () => {
  const token = localStorage.getItem('access_token');
  const user = getCurrentUser();
  return !!(token && user);
};

export const verifyEmail = async (verificationData) => {
  try {
    const response = await apiClient.post("auth/verify-email", verificationData);
    return response.data;
  } catch (error) {
    if (error.response?.status === 400) {
      throw new Error('Mã xác thực không hợp lệ hoặc đã hết hạn');
    } else if (error.response?.status === 404) {
      throw new Error('Email không tồn tại trong hệ thống');
    } else {
      throw new Error(
        error.response?.data?.message || 'Có lỗi xảy ra khi xác thực email'
      );
    }
  }
};

export const forgotPassword = async (email) => {
  try {
    const response = await apiClient.post("auth/forgotpass", { email });
    return response.data;
  } catch (error) {
    throw new Error(
      "Lỗi khi yêu cầu đặt lại mật khẩu: " + error.response?.data?.message ||
        error.message
    );
  }
};

export const resetPassword = async (resetData) => {
  try {
    const response = await apiClient.post("auth/reset-password", resetData);
    return response.data;
  } catch (error) {
    throw new Error(
      "Lỗi khi đặt lại mật khẩu: " + error.response?.data?.message ||
        error.message
    );
  }
};

export const resendVerificationCode = async (email) => {
  try {
    const response = await apiClient.post("auth/resend-verification", email);
    if (response.data.success) {
      return response.data;
    } else {
      throw new Error(response.data.message || 'Không thể gửi lại mã xác thực');
    }
  } catch (error) {
    if (error.response?.status === 429) {
      throw new Error('Vui lòng đợi một thời gian trước khi gửi lại mã');
    } else if (error.response?.status === 404) {
      throw new Error('Email không tồn tại trong hệ thống');
    } else {
      throw new Error(
        error.response?.data?.message || 'Có lỗi xảy ra khi gửi lại mã xác thực'
      );
    }
  }
};
