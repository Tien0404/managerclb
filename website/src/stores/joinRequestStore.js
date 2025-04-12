import { defineStore } from "pinia";
import JoinRequestService from "../services/joinRequest";

export const useJoinRequestStore = defineStore("joinRequest", {
  state: () => ({
    joinRequests: [],
    isLoading: false,
    error: null,
  }),

  actions: {
    async fetchClubRequests(clubId) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.getClubRequests(clubId);
        this.joinRequests = data;
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async createJoinRequest(clubId, eventId) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.createJoinRequest(clubId, eventId);
        this.joinRequests.push(data);
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async updateJoinRequest(id, requestData) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.updateJoinRequest(id, requestData);
        const index = this.joinRequests.findIndex((req) => req.id === id);
        if (index !== -1) {
          this.joinRequests[index] = data;
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async deleteJoinRequest(id) {
      this.isLoading = true;
      this.error = null;

      try {
        await JoinRequestService.deleteJoinRequest(id);
        this.joinRequests = this.joinRequests.filter((req) => req.id !== id);
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async fetchUserRequests() {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.getUserRequests();
        this.joinRequests = data;
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async checkClubStatus(clubId) {
      this.isLoading = true;
      this.error = null;

      try {
        return await JoinRequestService.checkClubStatus(clubId);
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async fetchEventRequests(eventId) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.getEventRequests(eventId);
        this.joinRequests = data;
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async checkEventStatus(eventId) {
      this.isLoading = true;
      this.error = null;

      try {
        return await JoinRequestService.checkEventStatus(eventId);
      } catch (error) {
        this.error = error.message;
      } finally {
        this.isLoading = false;
      }
    },

    async inviteUser(requestData) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.inviteUser(requestData);
        return data;
      } catch (error) {
        this.error = error.message;
        throw error;
      } finally {
        this.isLoading = false;
      }
    },

    async getUserEvent(userId) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.getUserEvent(userId);
        return data;
      } catch (error) {
        this.error = error.message;
        throw error;
      } finally {
        this.isLoading = false;
      }
    },

    async getUserClubs(userId) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await JoinRequestService.getUserClubs(userId);
        return data;
      } catch (error) {
        this.error = error.message;
        throw error;
      } finally {
        this.isLoading = false;
      }
    },
  },
});