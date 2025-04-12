import { defineStore } from 'pinia';
import * as categoryService from '../services/categoryService';

export const useCategoryStore = defineStore('categoryStore', {
  state: () => ({
    categories: [],
    loading: false,
    error: null,
  }),
  actions: {
    async fetchCategories() {
      this.loading = true;
      this.error = null;
      try {
        const categories = await categoryService.getCategories();
        this.categories = categories;
        return categories;
      } catch (err) {
        this.error = err.message || 'Error fetching categories';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async fetchCategory(id) {
      this.loading = true;
      this.error = null;
      try {
        return await categoryService.getCategory(id);
      } catch (err) {
        this.error = err.message || 'Error fetching the category';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async createCategory(categoryData) {
      this.loading = true;
      this.error = null;
      try {
        const newCategory = await categoryService.createCategory(categoryData);
        this.categories.push(newCategory);
      } catch (err) {
        this.error = err.message || 'Error creating the category';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async updateCategory(id, categoryData) {
      this.loading = true;
      this.error = null;
      try {
        const updatedCategory = await categoryService.updateCategory(id, categoryData);
        const index = this.categories.findIndex(category => category.id === id);
        if (index !== -1) {
          this.categories[index] = updatedCategory; // Update the category in the state
        }
      } catch (err) {
        this.error = err.message || 'Error updating the category';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async deleteCategory(id) {
      this.loading = true;
      this.error = null;
      try {
        await categoryService.deleteCategory(id);
        this.categories = this.categories.filter(category => category.id !== id); // Remove the category from the state
      } catch (err) {
        this.error = err.message || 'Error deleting the category';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
  },
});