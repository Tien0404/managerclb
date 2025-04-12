import { defineStore } from 'pinia';
import FeedbackService from '../services/feedback';

export const useFeedbackStore = defineStore('feedback', {
    state: () => ({
        feedbacks: [],
        currentFeedback: null,
        clubFeedbacks: [],
        loading: false,
        error: null
    }),

    getters: {
        getFeedbackById: (state) => (id) => {
            return state.feedbacks.find(feedback => feedback.id === id);
        }
    },

    actions: {
        async fetchFeedbacks() {
            this.loading = true;
            try {
                const data = await FeedbackService.getAllFeedbacks();
                this.feedbacks = data;
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching feedbacks:', error);
            } finally {
                this.loading = false;
            }
        },

        async fetchFeedbackById(id) {
            this.loading = true;
            try {
                const data = await FeedbackService.getFeedbackById(id);
                this.currentFeedback = data;
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching feedback:', error);
            } finally {
                this.loading = false;
            }
        },

        async createFeedback(feedbackData) {
            this.loading = true;
            try {
                const data = await FeedbackService.createFeedback(feedbackData);
                this.feedbacks.push(data);
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error creating feedback:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updateFeedback(id, feedbackData) {
            this.loading = true;
            try {
                const data = await FeedbackService.updateFeedback(id, feedbackData);
                const index = this.feedbacks.findIndex(feedback => feedback.id === id);
                if (index !== -1) {
                    this.feedbacks[index] = data;
                }
                this.error = null;
                return data;
            } catch (error) {
                this.error = error.message;
                console.error('Error updating feedback:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deleteFeedback(id) {
            this.loading = true;
            try {
                await FeedbackService.deleteFeedback(id);
                this.feedbacks = this.feedbacks.filter(feedback => feedback.id !== id);
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error deleting feedback:', error);
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async fetchClubFeedbacks(clubId) {
            this.loading = true;
            try {
                const data = await FeedbackService.getClubFeedbacks(clubId);
                this.clubFeedbacks = data;
                this.error = null;
            } catch (error) {
                this.error = error.message;
                console.error('Error fetching club feedbacks:', error);
            } finally {
                this.loading = false;
            }
        }
    }
});