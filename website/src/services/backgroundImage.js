import apiClient from "../utils/apiClient";

const API_URL = '/background-images';

class BackgroundImageService {
    async getAllBackgroundImages() {
        const response = await apiClient.get(API_URL);
        return response.data;
    }

    async getBackgroundImageById(id) {
        const response = await apiClient.get(`${API_URL}/${id}`);
        return response.data;
    }

    async uploadImage(imageFile) {
        const formData = new FormData();
        formData.append('image', imageFile);
        const response = await apiClient.post(`${API_URL}/upload-image`, formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        });
        return response.data;
    }

    async uploadVideo(videoFile) {
        const formData = new FormData();
        formData.append('video', videoFile);
        const response = await apiClient.post(`${API_URL}/upload-video`, formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        });
        return response.data;
    }

    async updateBackgroundImage(id, updateData) {
        const response = await apiClient.put(`${API_URL}/${id}`, updateData);
        return response.data;
    }

    async deleteImage(id) {
        const response = await apiClient.delete(`${API_URL}/${id}/delete-image`);
        return response.data;
    }

    async deleteVideo(id) {
        const response = await apiClient.delete(`${API_URL}/${id}/delete-video`);
        return response.data;
    }
}

export default new BackgroundImageService(); 