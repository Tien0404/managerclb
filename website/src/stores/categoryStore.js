import { defineStore } from "pinia";
import { ref } from "vue";
import { getCategories, getCategoryById } from "../services/category";

export const useCategoryStore = defineStore("category", {
  state: () => ({
    categories: [],
    selectedCategory: null,
    isLoading: false,
    error: null,
  }),

  getters: {
    getCategoryById: (state) => (id) => {
      return state.categories.find((cat) => cat.id === parseInt(id));
    },

    getCategoryName: (state) => (id) => {
      const category = state.categories.find((cat) => cat.id === parseInt(id));
      return category ? category.name : null;
    },

    // Get categories by type (club, event, blog)
    getCategoriesByType: (state) => (type) => {
      return state.categories.filter(
        (cat) => cat.type === type && cat.status === "active"
      );
    },

    // Get all club categories
    clubCategories: (state) => {
      return state.categories.filter(
        (cat) => cat.type === "club" && cat.status === "active"
      );
    },

    // Get all event categories
    eventCategories: (state) => {
      return state.categories.filter(
        (cat) => cat.type === "event" && cat.status === "active"
      );
    },

    // Get all blog categories
    blogCategories: (state) => {
      return state.categories.filter(
        (cat) => cat.type === "blog" && cat.status === "active"
      );
    },
  },

  actions: {
    // Action: Fetch all categories
    async fetchCategories() {
      this.isLoading = true;
      this.error = null;
      try {
        const data = await getCategories();
        if (Array.isArray(data)) {
          this.categories = data.map((category) => ({
            ...category,
            id: parseInt(category.id),
          }));
        } else {
          throw new Error("Invalid data format received from API");
        }
      } catch (err) {
        console.error("Error fetching categories:", err);
        this.error = err.message || "Failed to fetch categories";
      } finally {
        this.isLoading = false;
      }
    },

    // Action: Fetch category by ID
    async fetchCategoryById(id) {
      this.isLoading = true;
      this.error = null;
      try {
        const data = await getCategoryById(id);
        if (data) {
          this.selectedCategory = {
            ...data,
            id: parseInt(data.id),
          };
        } else {
          throw new Error(`Category with ID ${id} not found`);
        }
      } catch (err) {
        console.error(`Error fetching category ${id}:`, err);
        this.error = err.message || `Failed to fetch category with ID ${id}`;
      } finally {
        this.isLoading = false;
      }
    },

    // Select a category
    selectCategory(category) {
      this.selectedCategory = category;
    },

    // Clear selected category
    clearSelectedCategory() {
      this.selectedCategory = null;
    },
  },
});
