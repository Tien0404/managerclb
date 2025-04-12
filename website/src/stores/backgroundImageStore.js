import { defineStore } from 'pinia';
import BackgroundImageService from '../services/backgroundImage';

export const useBackgroundImageStore = defineStore('backgroundImage', {
    state: () => ({
        backgroundImages: [],
        currentBackgroundImage: null,
        loading: false,
        error: null
    }),

    getters: {
        getBackgroundImageById: (state) => (id) => {
            return state.backgroundImages.find(image => image.id === id);
        }
    },

    actions: {
        async fetchBackgroundImages() {
            this.loading = true;
            try {
                const data = await BackgroundImageService.getAllBackgroundImages();
                this.backgroundImages = data;
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching background images:', error);
            } finally {
                this.loading = false;
            }
        },

        async fetchBackgroundImageById(id) {
            this.loading = true;
            try {
                const data = await BackgroundImageService.getBackgroundImageById(id);
                this.currentBackgroundImage = data;
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching background image:', error);
            } finally {
                this.loading = false;
            }
        },

        async uploadImage(imageFile) {
            this.loading = true;
            try {
                const data = await BackgroundImageService.uploadImage(imageFile);
                this.backgroundImages.push(data);
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error uploading image:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async uploadVideo(videoFile) {
            this.loading = true;
            try {
                const data = await BackgroundImageService.uploadVideo(videoFile);
                this.backgroundImages.push(data);
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error uploading video:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updateBackgroundImage(id, updateData) {
            this.loading = true;
            try {
                const data = await BackgroundImageService.updateBackgroundImage(id, updateData);
                const index = this.backgroundImages.findIndex(image => image.id === id);
                if (index !== -1) {
                    this.backgroundImages[index] = data;
                }
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error updating background image:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deleteImage(id) {
            this.loading = true;
            try {
                await BackgroundImageService.deleteImage(id);
                this.backgroundImages = this.backgroundImages.filter(image => image.id !== id);
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error deleting image:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deleteVideo(id) {
            this.loading = true;
            try {
                await BackgroundImageService.deleteVideo(id);
                this.backgroundImages = this.backgroundImages.filter(image => image.id !== id);
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error deleting video:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        }
    }
}); 