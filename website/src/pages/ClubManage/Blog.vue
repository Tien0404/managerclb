<template>
  <div class="p-6 bg-gray-50 min-h-screen" :class="{ 'opacity-50 pointer-events-none': !departmentStore.canManageBlogs }">
    <!-- Header -->
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-xl font-medium">Quản lý Blog</h1>
      <div class="flex gap-3">
        <button class="p-2">
          <MessageCircleIcon class="w-6 h-6" />
        </button>
        <button class="p-2">
          <BellIcon class="w-6 h-6" />
        </button>
        <div
          class="w-10 h-10 rounded-full bg-yellow-400 flex items-center justify-center"
        >
          <UserIcon class="w-6 h-6 text-white" />
        </div>
      </div>
    </div>

    <!-- Search and Filters -->
    <SearchAndFilters 
      type="blog" 
      @openModal="openModal" 
      :disabled="!departmentStore.canManageBlogs"
    />

    <!-- Blog List -->
    <BlogList :showActions="departmentStore.canManageBlogs" />
    <!-- Modal -->
    <ModalCreate 
      :isOpen="isModalOpen && departmentStore.canManageBlogs" 
      :type="'blog'" 
      :clubId="clubId" 
      @close="closeModal" 
      @blogCreated="handleBlogCreated" 
    />
    <ModalEdit
        :isOpen="isEditModalOpen && departmentStore.canManageBlogs"
        type="blog"
        :itemData="selectedBlog"
        @close="closeEditModal"
        @blogUpdated="handleBlogUpdated"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useRoute } from 'vue-router';
import { useBlogStore } from '../../stores/blogStore';
import { useDepartmentStore } from '../../stores/departmentStore';
import ModalCreate from "../../components/ClubManage/ModalCreate.vue";
import ModalEdit from '../../components/ClubManage/ModalEdit.vue';
import BlogList from "../../components/ClubManage/BlogManage/BlogList.vue";
import SearchAndFilters from "../../components/ClubManage/SearchAndFilters.vue";

import { MessageCircleIcon, BellIcon, UserIcon } from "lucide-vue-next";

const route = useRoute();
const blogStore = useBlogStore();
const departmentStore = useDepartmentStore();
const clubId = route.params.id;
const isModalOpen = ref(false);
const selectedBlog = ref(null);
const isEditModalOpen = ref(false);

const openModal = () => {
    isModalOpen.value = true;
};

const closeModal = () => {
    isModalOpen.value = false;
};

const openEditModal = (blog) => {
    selectedBlog.value = blog;
    isEditModalOpen.value = true;
};

const closeEditModal = () => {
    selectedBlog.value = null;
    isEditModalOpen.value = false;
};

const handleBlogCreated = (blog) => {
    // Refresh the blog list
    blogStore.fetchBlogs();
};

const handleBlogUpdated = (updatedBlog) => {
    // Refresh the blog list
    blogStore.fetchBlogs();
};

onMounted(async () => {
    // Set the club ID filter before fetching blogs
    console.log('Setting club ID filter:', clubId);
    blogStore.setFilter('clubId', clubId);
    console.log('Fetching blogs for club ID:', clubId);
    await blogStore.fetchBlogs();
    console.log('Blogs fetched:', blogStore.blogs);
});

onBeforeUnmount(() => {
    blogStore.resetFilters();
});
</script>

<style scoped>
/* Add any scoped styles here if needed */
</style>