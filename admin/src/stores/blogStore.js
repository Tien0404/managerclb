import { defineStore } from 'pinia';
import * as blogService from '../services/blogService';

export const useBlogStore = defineStore('blogStore', {
  state: () => ({
    blogs: [],
    loading: false,
    error: null,
  }),
  actions: {
    async fetchBlogs() {
      this.loading = true;
      this.error = null;
      try {
        const blogs = await blogService.getBlogs();
        this.blogs = blogs;
        return blogs;
      } catch (err) {
        this.error = err.message || 'Error fetching blogs';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async fetchBlog(id) {
      this.loading = true;
      this.error = null;
      try {
        return await blogService.getBlog(id);
      } catch (err) {
        this.error = err.message || 'Error fetching the blog';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async createBlog(blogData) {
      this.loading = true;
      this.error = null;
      try {
        const newBlog = await blogService.createBlog(blogData);
        this.blogs.push(newBlog);
      } catch (err) {
        this.error = err.message || 'Error creating the blog';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async updateBlog(id, blogData) {
      this.loading = true;
      this.error = null;
      try {
        const updatedBlog = await blogService.updateBlog(id, blogData);
        const index = this.blogs.findIndex(blog => blog.id === id);
        if (index !== -1) {
          this.blogs[index] = updatedBlog;
        }
      } catch (err) {
        this.error = err.message || 'Error updating the blog';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
    async deleteBlog(id) {
      this.loading = true;
      this.error = null;
      try {
        await blogService.deleteBlog(id);
        this.blogs = this.blogs.filter(blog => blog.id !== id);
      } catch (err) {
        this.error = err.message || 'Error deleting the blog';
        console.error(this.error);
        return [];
      } finally {
        this.loading = false;
      }
    },
  },
});