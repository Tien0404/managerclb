import apiClient from "../utils/apiClient";

const API_URL = "/departments";

class DepartmentService {
  async getAllDepartmentsClub(clubId) {
    try {
      const response = await apiClient.get(`${API_URL}/club/${clubId}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể lấy danh sách phòng ban"
      );
    }
  }

  async getDepartmentById(id) {
    try {
      const response = await apiClient.get(`${API_URL}/${id}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể lấy thông tin phòng ban"
      );
    }
  }

  async createDepartment(departmentData) {
    try {
      const response = await apiClient.post(API_URL, departmentData);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể tạo phòng ban"
      );
    }
  }

  async updateDepartment(id, departmentData) {
    try {
      const response = await apiClient.patch(
        `${API_URL}/${id}`,
        departmentData
      );
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể cập nhật phòng ban"
      );
    }
  }

  async deleteDepartment(id) {
    try {
      const response = await apiClient.delete(`${API_URL}/${id}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể xóa phòng ban"
      );
    }
  }

  async getAllDepartmentsClub(id) {
    try {
      const response = await apiClient.get(`${API_URL}/club/${id}`);
      return {
        club: response.data.club,
        departments: response.data.departments
      };
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể lấy phòng ban của CLB"
      );
    }
  }
  async checkUserDepartment(clubId) {
    try {
      const userData = JSON.parse(localStorage.getItem("user"));
      const userId = userData?.id;

      if (!userId) {
        throw new Error("Người dùng chưa đăng nhập");
      }

      const response = await apiClient.get(
        `${API_URL}/check/${userId}/${clubId}`
      );
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể kiểm tra vai trò người dùng"
      );
    }
  }
}

export default new DepartmentService();
