import apiClient from "../utils/apiClient";

const API_URL = "/clubs";

class ClubService {
  async getAllClubs() {
    try {
      const response = await apiClient.get(API_URL);
      return response.data;
    } catch (error) {
      throw new Error("Không thể tải danh sách câu lạc bộ: " + error.message);
    }
  }

  async getClubById(id) {
    try {
      const response = await apiClient.get(`${API_URL}/${id}`);
      return response.data;
    } catch (error) {
      throw new Error("Không thể tải thông tin câu lạc bộ: " + error.message);
    }
  }

  async createClub(clubData) {
    try {
      const response = await apiClient.post(API_URL, clubData);
      return response.data;
    } catch (error) {
      if (error.response?.status === 422) {
        // Validation error
        const validationErrors = error.response.data.errors;
        const errorMessages = Object.values(validationErrors).flat().join(", ");
        throw new Error("Lỗi xác thực: " + errorMessages);
      }
      throw new Error("Không thể tạo câu lạc bộ: " + error.message);
    }
  }

  async updateClub(id, clubData) {
    try {
      console.log('Preparing FormData for club update:', clubData);
      const formData = new FormData();
      
      // Add basic club data with proper type conversion
      Object.keys(clubData).forEach(key => {
        if (key !== 'logo' && key !== 'images' && key !== 'deleted_image_ids' && 
            key !== 'update_image_id' && key !== 'delete_image_id' && key !== 'update_image') {
          formData.append(key, clubData[key] || '');
        }
      });

      // Add logo if exists
      if (clubData.logo) {
        console.log('Adding logo to FormData');
        formData.append('logo', clubData.logo);
      }

      // Add images if exists
      if (clubData.images && clubData.images.length > 0) {
        console.log('Adding images to FormData');
        clubData.images.forEach(image => {
          formData.append('images[]', image);
        });
      }

      // Add deleted image IDs if exists
      if (clubData.deleted_image_ids && clubData.deleted_image_ids.length > 0) {
        console.log('Adding deleted image IDs to FormData');
        formData.append('deleted_image_ids', clubData.deleted_image_ids.join(','));
      }

      // Add update_image_id if exists
      if (clubData.update_image_id) {
        console.log('Adding update_image_id to FormData');
        formData.append('update_image_id', clubData.update_image_id);
      }

      // Add update_image if exists
      if (clubData.update_image) {
        console.log('Adding update_image to FormData');
        formData.append('update_image', clubData.update_image);
      }

      // Add delete_image_id if exists
      if (clubData.delete_image_id) {
        console.log('Adding delete_image_id to FormData');
        formData.append('delete_image_id', clubData.delete_image_id);
      }

      // Log FormData entries for debugging
      console.log('FormData entries before sending:');
      for (let pair of formData.entries()) {
        console.log(pair[0] + ':', pair[1]);
      }

      const response = await apiClient.post(`${API_URL}/${id}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      
      console.log('Update club response:', response.data);
      return response;
    } catch (error) {
      if (error.response?.status === 422) {
        // Validation error
        const validationErrors = error.response.data.errors;
        const errorMessages = Object.values(validationErrors).flat().join(", ");
        throw new Error("Lỗi xác thực: " + errorMessages);
      }
      throw new Error("Không thể cập nhật câu lạc bộ: " + error.message);
    }
  }

  async deleteClub(id) {
    try {
      const response = await apiClient.delete(`${API_URL}/${id}`);
      return response.data;
    } catch (error) {
      throw new Error("Không thể xóa câu lạc bộ: " + error.message);
    }
  }

  async getClubsOfUser(userId) {
    try {
      const response = await apiClient.get(`${API_URL}/user/${userId}`);
      return response.data;
    } catch (error) {
      throw new Error(
        "Không thể tải danh sách câu lạc bộ của người dùng: " + error.message
      );
    }
  }

  async updateClubImage(clubId, imageId, imageFile, action = null) {
    try {
      const formData = new FormData();
      
      // If action is 'delete', add it to formData
      if (action === 'delete') {
        formData.append('action', 'delete');
      } else if (imageFile) {
        // Otherwise, add the image file
        formData.append('image', imageFile);
      }

      const response = await apiClient.post(`${API_URL}/${clubId}/images/${imageId}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      
      return response.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new Error("Không tìm thấy câu lạc bộ hoặc ảnh");
      } else if (error.response?.status === 400) {
        throw new Error(error.response.data.message || "Không thể cập nhật ảnh");
      }
      throw new Error("Không thể cập nhật ảnh: " + error.message);
    }
  }
}

export default new ClubService();
