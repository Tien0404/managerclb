import apiClient from "../utils/apiClient";

const API_URL = "/join-requests";

class JoinRequestService {
  async getJoinRequestById(id) {
    try {
      const response = await apiClient.get(`${API_URL}/${id}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy thông tin yêu cầu tham gia"
      );
    }
  }

  async createJoinRequest(clubId = null, eventId = null) {
    try {
      const user = JSON.parse(localStorage.getItem("user"));
      if (!user || !user.id) {
        throw new Error("Vui lòng đăng nhập để đăng ký tham gia");
      }

      if (!clubId && !eventId) {
        throw new Error("Vui lòng cung cấp ID của CLB hoặc sự kiện");
      }
      if (clubId && eventId) {
        throw new Error(
          "Chỉ được phép đăng ký tham gia CLB hoặc sự kiện, không phải cả hai"
        );
      }

      const requestData = {
        user_id: user.id,
        type: clubId ? "club" : "event",
        ...(clubId ? { club_id: clubId } : { event_id: eventId }),
        status: clubId ? "request" : "approved"
      };

      const response = await apiClient.post(API_URL, requestData);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể tạo yêu cầu tham gia"
      );
    }
  }

  async inviteUser(requestData) {
    try {
      const response = await apiClient.post(`${API_URL}/email`, requestData);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể gửi lời mời tham gia"
      );
    }
  }

  async updateJoinRequest(id, requestData) {
    try {
      const response = await apiClient.patch(`${API_URL}/${id}`, requestData);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể cập nhật yêu cầu tham gia"
      );
    }
  }

  async deleteJoinRequest(id) {
    try {
      const response = await apiClient.delete(`${API_URL}/${id}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể xóa yêu cầu tham gia"
      );
    }
  }

  async getClubRequests(clubId) {
    try {
      const response = await apiClient.get(`${API_URL}/club/${clubId}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy danh sách yêu cầu tham gia CLB"
      );
    }
  }

  async getEventRequests(eventId) {
    try {
      const response = await apiClient.get(`${API_URL}/event/${eventId}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy danh sách yêu cầu tham gia sự kiện"
      );
    }
  }

  async getUserRequests() {
    try {
      const user = JSON.parse(localStorage.getItem("user"));
      if (!user || !user.id) {
        throw new Error("Vui lòng đăng nhập để xem yêu cầu tham gia");
      }

      const response = await apiClient.get(`${API_URL}/user/${user.id}`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy danh sách yêu cầu tham gia của người dùng"
      );
    }
  }

  async checkClubStatus(clubId) {
    try {
      const user = JSON.parse(localStorage.getItem("user"));
      if (!user || !user.id) {
        throw new Error("Vui lòng đăng nhập để kiểm tra trạng thái tham gia");
      }

      const response = await apiClient.get(
        `${API_URL}/check-club/${user.id}/${clubId}`
      );
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể kiểm tra trạng thái tham gia CLB"
      );
    }
  }

  async checkEventStatus(eventId) {
    try {
      const user = JSON.parse(localStorage.getItem("user"));
      if (!user || !user.id) {
        throw new Error("Vui lòng đăng nhập để kiểm tra trạng thái tham gia");
      }

      const response = await apiClient.get(
        `${API_URL}/check-event/${user.id}/${eventId}`
      );
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể kiểm tra trạng thái tham gia sự kiện"
      );
    }
  }

  async getUserClubs(userId) {
    try {
      const response = await apiClient.get(`${API_URL}/user/${userId}/clubs`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy danh sách câu lạc bộ của người dùng"
      );
    }
  }

  async getUserEvent(userId) {
    try {
      const response = await apiClient.get(`${API_URL}/user/${userId}/events`);
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy danh sách sự kiện của người dùng"
      );
    }
  }
}

export default new JoinRequestService();