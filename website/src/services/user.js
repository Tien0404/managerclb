import apiClient from "../utils/apiClient";

const API_URL = '/users';

// Individual API functions
export const getInfo = async (id) => {
    const response = await apiClient.get(`${API_URL}/${id}`);
    return response.data;
};

export const updateInfo = async (id, data) => {
    const response = await apiClient.post(`${API_URL}/${id}`, data);
    return response.data;
};

// UserService class
class UserService {
    async getAllUsers() {
        const response = await apiClient.get(API_URL);
        return response.data;
    }

    async getUserById(id) {
        return getInfo(id);
    }

    async createUser(userData) {
        const response = await apiClient.post(API_URL, userData);
        return response.data;
    }

    async updateUser(id, userData) {
        try {
            // Create FormData object for handling file upload
            let formData;
            
            // Handle avatar file if present
            if (userData instanceof FormData) {
                // If userData is already FormData, use it directly
                formData = userData;
            } else {
                // If userData is a regular object, create new FormData
                formData = new FormData();
                
                if (userData.avatar) {
                    formData.append('avatar', userData.avatar);
                    delete userData.avatar; // Remove avatar from userData
                }

                // Append all other user data
                Object.keys(userData).forEach(key => {
                    if (userData[key] !== null && userData[key] !== undefined && userData[key] !== '') {
                        formData.append(key, userData[key]);
                    }
                });
            }

            // Log FormData contents for debugging
            console.log('FormData being sent to API:');
            for (let pair of formData.entries()) {
                console.log(pair[0] + ': ' + pair[1]);
            }

            const response = await apiClient.post(`${API_URL}/${id}`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            return response.data;
        } catch (error) {
            console.error('Error in updateUser:', error);
            throw new Error(
                error.response?.data?.message || 
                "Không thể cập nhật thông tin người dùng"
            );
        }
    }

    async deleteUser(id) {
        const response = await apiClient.delete(`${API_URL}/${id}`);
        return response.data;
    }

}

export default new UserService();
