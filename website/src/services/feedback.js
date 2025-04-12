import apiClient from "../utils/apiClient";

const API_URL = '/feedbacks';

class FeedbackService {
    async getAllFeedbacks() {
        const response = await apiClient.get(API_URL);
        return response.data;
    }

    async getClubFeedbacks(clubId) {
        const response = await apiClient.get(`${API_URL}/club/${clubId}`);
        return response.data;
    }

    async getFeedbackById(id) {
        const response = await apiClient.get(`${API_URL}/${id}`);
        return response.data;
    }

    async createFeedback(feedbackData) {
        const response = await apiClient.post(API_URL, feedbackData);
        return response.data;
    }

    async updateFeedback(id, feedbackData) {
        const response = await apiClient.patch(`${API_URL}/${id}`, feedbackData);
        return response.data;
    }

    async deleteFeedback(id) {
        const response = await apiClient.delete(`${API_URL}/${id}`);
        return response.data;
    }
}

export default new FeedbackService();