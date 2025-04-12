import { defineStore } from 'pinia';
import * as userService from '../services/userService';

export const useUserStore = defineStore('userStore', {
  state: () => ({
    users: [],
    loading: false,
    error: null,
  }),
  actions: {
    async fetchUsers() {
      this.loading = true;
      this.error = null;
      try {
        const users = await userService.getUsers();
        this.users = users;
        return users;
      } catch (err) {
        this.error = err.message || 'Error fetching users';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async fetchUser(id) {
      this.loading = true;
      this.error = null;
      try {
        return await userService.getUser(id);
      } catch (err) {
        this.error = err.message || 'Error fetching the user';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async createUser(userData) {
      this.loading = true;
      this.error = null;
      try {
        const newUser = await userService.createUser(userData);
        this.users.push(newUser);
      } catch (err) {
        this.error = err.message || 'Error creating the user';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async updateUser(id, userData) {
      this.loading = true;
      this.error = null;
      try {
        const updatedUser = await userService.updateUser(id, userData);
        const index = this.users.findIndex(user => user.id === id);
        if (index !== -1) {
          this.users[index] = updatedUser;
        }
      } catch (err) {
        this.error = err.message || 'Error updating the user';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
    async deleteUser(id) {
      this.loading = true;
      this.error = null;
      try {
        await userService.deleteUser(id);
        this.users = this.users.filter(user => user.id !== id);
      } catch (err) {
        this.error = err.message || 'Error deleting the user';
        console.error(this.error);
      } finally {
        this.loading = false;
      }
    },
  },
});