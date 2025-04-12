import { defineStore } from "pinia";
import BlogService from "../services/blog";

export const useBlogStore = defineStore("blog", {
  state: () => ({
    blogs: [],
    selectedBlog: null,
    isLoading: false,
    error: null,
    lastFetched: null,
    filters: {
      category: null,
      searchQuery: "",
      sortBy: null,
      clubId: null,
    },
  }),

  getters: {
    needsRefresh: (state) => {
      if (!state.lastFetched) return true;
      const CACHE_DURATION = 5 * 60 * 1000; // Cache 5 phút
      return Date.now() - state.lastFetched > CACHE_DURATION;
    },

    filteredBlogs: (state) => {
      let filtered = [...state.blogs];
      console.log('Initial blogs before filtering:', filtered);

      // Only filter by active status if not in club management (clubId not set)
      if (!state.filters.clubId) {
        filtered = filtered.filter((blog) => blog.status === "active");
      }
      console.log('After status filtering:', filtered);

      if (state.filters.searchQuery) {
        const query = state.filters.searchQuery.toLowerCase().trim();
        filtered = filtered.filter((blog) =>
          blog.title.toLowerCase().includes(query)
        );
      }

      if (state.filters.category) {
        filtered = filtered.filter(
          (blog) => blog.category_id === state.filters.category
        );
      }

      if (state.filters.clubId) {
        console.log('Filtering by club ID:', state.filters.clubId, 'type:', typeof state.filters.clubId);
        filtered = filtered.filter((blog) => {
          console.log('Blog club_id:', blog.club_id, 'type:', typeof blog.club_id);
          return blog.club_id === parseInt(state.filters.clubId);
        });
        console.log('After club filtering:', filtered);
      }

      if (state.filters.sortBy) {
        switch (state.filters.sortBy) {
          case "newest":
            filtered.sort(
              (a, b) => new Date(b.datetime) - new Date(a.datetime)
            );
            break;
          case "oldest":
            filtered.sort(
              (a, b) => new Date(a.datetime) - new Date(b.datetime)
            );
            break;
          case "title":
            filtered.sort((a, b) => a.title.localeCompare(b.title));
            break;
        }
      }

      return filtered;
    },
  },

  actions: {
    async fetchBlogs(forceRefresh = false) {
      if (!forceRefresh && !this.needsRefresh && this.blogs.length > 0) {
        console.log("Using cached blogs data");
        return this.blogs;
      }

      this.isLoading = true;
      this.error = null;

      try {
        console.log("Fetching fresh blogs data");
        let data;
        
        // If clubId filter is set, fetch blogs for that club only
        if (this.filters.clubId) {
          console.log(`Fetching blogs for club ID: ${this.filters.clubId}`);
          data = await BlogService.getClubBlog(this.filters.clubId);
          console.log('Received club blogs:', data);
        } else {
          data = await BlogService.getAllBlogs();
        }

        if (Array.isArray(data)) {
          this.blogs = data;
          this.lastFetched = Date.now();
          return this.blogs;
        } else {
          throw new Error("Invalid data format received from API");
        }
      } catch (err) {
        this.error = err.message || "Failed to fetch blogs";
        console.error("Error fetching blogs:", err);
        throw err;
      } finally {
        this.isLoading = false;
      }
    },

    async fetchBlogById(id) {
      const existingBlog = this.blogs.find((b) => b.id === id);
      if (existingBlog && !this.needsRefresh) {
        console.log("Using cached blog data");
        this.selectedBlog = existingBlog;
        return existingBlog;
      }

      this.isLoading = true;
      this.error = null;

      try {
        console.log("Fetching fresh blog data");
        const data = await BlogService.getBlogById(id);

        if (data) {
          this.selectedBlog = data;
          if (!existingBlog) {
            this.blogs.push(data);
          }
          return data;
        }
        throw new Error("Blog not found");
      } catch (err) {
        this.error = err.message || `Failed to fetch blog with id ${id}`;
        console.error("Error fetching blog:", err);
        throw err;
      } finally {
        this.isLoading = false;
      }
    },

    async createBlog(blogData) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await BlogService.createBlog(blogData);
        // Fetch fresh data to ensure we have the latest state
        await this.fetchBlogs(true);
        return data;
      } catch (err) {
        this.error = err.message || "Failed to create blog";
        console.error("Error creating blog:", err);
        throw err;
      } finally {
        this.isLoading = false;
      }
    },

    async updateBlog(id, blogData) {
      this.isLoading = true;
      this.error = null;

      try {
        const data = await BlogService.updateBlog(id, blogData);
        // Fetch fresh data to ensure we have the latest state
        await this.fetchBlogs(true);
        return data;
      } catch (err) {
        this.error = err.message || "Failed to update blog";
        console.error("Error updating blog:", err);
        throw err;
      } finally {
        this.isLoading = false;
      }
    },

    async deleteBlog(id) {
      this.isLoading = true;
      this.error = null;

      try {
        await BlogService.deleteBlog(id);
        this.blogs = this.blogs.filter((blog) => blog.id !== id);
        if (this.selectedBlog?.id === id) {
          this.selectedBlog = null;
        }
      } catch (err) {
        this.error = err.message || "Failed to delete blog";
        console.error("Error deleting blog:", err);
        throw err;
      } finally {
        this.isLoading = false;
      }
    },

    setFilter(filterType, value) {
      // Convert category_id to category for consistency
      if (filterType === "category_id") {
        this.filters.category = value;
      } else {
        this.filters[filterType] = value;
      }
    },

    resetFilters() {
      this.filters = {
        category: null,
        searchQuery: "",
        sortBy: null,
        clubId: null,
      };
    },
  },
});
