import apiClient from "../utils/apiClient";

class EventService {
  constructor() {
    this.cache = new Map();
    this.cacheTimeout = 5 * 60 * 1000; // 5 minutes
    this.controllers = new Map();
  }

  _getCacheKey(endpoint, params = {}) {
    return `${endpoint}_${JSON.stringify(params)}`;
  }

  _isCacheValid(cacheKey) {
    const cached = this.cache.get(cacheKey);
    if (!cached) return false;
    return Date.now() - cached.timestamp < this.cacheTimeout;
  }

  _setCache(cacheKey, data) {
    this.cache.set(cacheKey, {
      data,
      timestamp: Date.now()
    });
  }

  _clearCache() {
    this.cache.clear();
  }

  _cancelRequest(key) {
    if (this.controllers.has(key)) {
      this.controllers.get(key).abort();
      this.controllers.delete(key);
    }
  }

  async getEvents(params = {}) {
    const cacheKey = this._getCacheKey('getEvents', params);
    if (this._isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey).data;
    }

    this._cancelRequest('getEvents');
    const controller = new AbortController();
    this.controllers.set('getEvents', controller);

    try {
      const response = await apiClient.get("/events", {
        params,
        signal: controller.signal
      });
      this._setCache(cacheKey, response.data);
      return response.data;
    } catch (error) {
      if (error.name === 'AbortError') {
        throw new Error('Request was cancelled');
      }
      throw new Error(
        error.response?.data?.message || "Không thể lấy danh sách sự kiện"
      );
    }
  }

  async getEventById(id) {
    const cacheKey = this._getCacheKey(`getEventById_${id}`);
    if (this._isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey).data;
    }

    this._cancelRequest(`getEventById_${id}`);
    const controller = new AbortController();
    this.controllers.set(`getEventById_${id}`, controller);

    try {
      const response = await apiClient.get(`/events/${id}`, {
        signal: controller.signal
      });
      this._setCache(cacheKey, response.data);
      return response.data;
    } catch (error) {
      if (error.name === 'AbortError') {
        throw new Error('Request was cancelled');
      }
      throw new Error(
        error.response?.data?.message || "Không thể lấy thông tin sự kiện"
      );
    }
  }

  async getEventClub(clubId) {
    const cacheKey = this._getCacheKey(`getEventClub_${clubId}`);
    if (this._isCacheValid(cacheKey)) {
      return this.cache.get(cacheKey).data;
    }

    this._cancelRequest(`getEventClub_${clubId}`);
    const controller = new AbortController();
    this.controllers.set(`getEventClub_${clubId}`, controller);

    try {
      const response = await apiClient.get(`/events/club/${clubId}`, {
        signal: controller.signal
      });
      this._setCache(cacheKey, response.data);
      return response.data;
    } catch (error) {
      if (error.name === 'AbortError') {
        throw new Error('Request was cancelled');
      }
      throw new Error(
        error.response?.data?.message ||
          "Không thể lấy danh sách sự kiện của CLB"
      );
    }
  }

  async createEvent(eventData) {
    this._clearCache(); // Clear cache on create
    try {
      const formData = new FormData();

      // Handle logo upload
      if (eventData.logo instanceof File) {
        formData.append("logo", eventData.logo);
      }

      // Append other data
      Object.entries(eventData).forEach(([key, value]) => {
        if (key !== "logo" && value !== undefined && value !== null) {
          formData.append(key, value);
        }
      });

      const response = await apiClient.post("/events", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });
      return response.data;
    } catch (error) {
      throw new Error(error.response?.data?.message || "Không thể tạo sự kiện");
    }
  }

  async updateEvent(id, eventData) {
    this._clearCache(); // Clear cache on update
    try {
      const formData = new FormData();

      // Handle logo upload
      if (eventData.logo instanceof File) {
        formData.append("logo", eventData.logo);
      }

      // Append other data
      Object.entries(eventData).forEach(([key, value]) => {
        if (key !== "logo" && value !== undefined && value !== null) {
          formData.append(key, value);
        }
      });

      const response = await apiClient.post(`/events/${id}`, formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });
      return response.data;
    } catch (error) {
      throw new Error(
        error.response?.data?.message || "Không thể cập nhật sự kiện"
      );
    }
  }

  async deleteEvent(id) {
    this._clearCache(); // Clear cache on delete
    try {
      const response = await apiClient.delete(`/events/${id}`);
      return response.data;
    } catch (error) {
      throw new Error(error.response?.data?.message || "Không thể xóa sự kiện");
    }
  }

  // Cleanup method to cancel all pending requests
  cancelAllRequests() {
    this.controllers.forEach(controller => controller.abort());
    this.controllers.clear();
  }
}

export default new EventService();
