import { defineStore } from 'pinia';
import * as clubService from '../services/clubService';

export const useClubStore = defineStore('clubStore', {
  state: () => ({
    clubs: [],
    loading: false,
    error: null,
  }),
  actions: {
    async fetchClubs() {
      this.loading = true;
      this.error = null;
      try {
        const clubs = await clubService.getClubs();
        this.clubs = clubs;
        return clubs;
      } catch (err) {
        this.error = err.message || 'Error fetching clubs';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async fetchClub(id) {
      this.loading = true;
      this.error = null;
      try {
        return await clubService.getClub(id);
      } catch (err) {
        this.error = err.message || 'Error fetching the club';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async createClub(clubData) {
      this.loading = true;
      this.error = null;
      try {
        const newClub = await clubService.createClub(clubData);
        this.clubs.push(newClub);
      } catch (err) {
        this.error = err.message || 'Error creating the club';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async updateClub(id, clubData) {
      this.loading = true;
      this.error = null;
      try {
        const updatedClub = await clubService.updateClub(id, clubData);
        const index = this.clubs.findIndex(club => club.id === id);
        if (index !== -1) {
          this.clubs[index] = updatedClub;
        }
        return updatedClub;
      } catch (err) {
        this.error = err.message || 'Error updating the club';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async deleteClub(id) {
      this.loading = true;
      this.error = null;
      try {
        await clubService.deleteClub(id);
        this.clubs = this.clubs.filter(club => club.id !== id);
      } catch (err) {
        this.error = err.message || 'Error deleting the club';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
  },
});