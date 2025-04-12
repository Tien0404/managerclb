import { defineStore } from 'pinia';
import * as feedbackService from '../services/feedbackService';

export const useFeedbackStore = defineStore('feedbackStore', {
  state: () => ({
    feedbacks: [],
    loading: false,
    error: null,
  }),
  actions: {
    async fetchFeedbacks() {
      this.loading = true;
      this.error = null;
      try {
        const feedbacks = await feedbackService.getFeedbacks();
        this.feedbacks = feedbacks;
        return feedbacks;
      } catch (err) {
        this.error = err.message || 'Error fetching feedbacks';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async fetchFeedback(id) {
      this.loading = true;
      this.error = null;
      try {
        return await feedbackService.getFeedback(id);
      } catch (err) {
        this.error = err.message || 'Error fetching the feedback';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async createFeedback(feedbackData) {
      this.loading = true;
      this.error = null;
      try {
        const newFeedback = await feedbackService.createFeedback(feedbackData);
        this.feedbacks.push(newFeedback);
      } catch (err) {
        this.error = err.message || 'Error creating the feedback';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async updateFeedback(id, feedbackData) {
      this.loading = true;
      this.error = null;
      try {
        const updatedFeedback = await feedbackService.updateFeedback(id, feedbackData);
        const index = this.feedbacks.findIndex(feedback => feedback.id === id);
        if (index !== -1) {
          this.feedbacks[index] = updatedFeedback;
        }
      } catch (err) {
        this.error = err.message || 'Error updating the feedback';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async deleteFeedback(id) {
      this.loading = true;
      this.error = null;
      try {
        await feedbackService.deleteFeedback(id);
        this.feedbacks = this.feedbacks.filter(feedback => feedback.id !== id);
      } catch (err) {
        this.error = err.message || 'Error deleting the feedback';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
  },
});