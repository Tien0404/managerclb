<template>
    <div class="flex flex-col gap-6 w-full max-w-2xl mx-auto p-4">
        <div v-if="!filteredBlogs || filteredBlogs.length === 0" class="w-full text-center py-12">
            <div class="flex flex-col items-center">
                <InboxIcon class="w-16 h-16 text-gray-400 mb-4" />
                <h3 class="text-lg font-medium text-gray-900 mb-2">Chưa có bài viết nào cho câu lạc bộ này</h3>
                <p class="text-gray-500">Hãy tạo bài viết mới để chia sẻ thông tin với mọi người</p>
            </div>
        </div>
        <div v-else v-for="blog in filteredBlogs" :key="blog.id" 
            class="bg-white rounded-xl shadow-md hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 overflow-hidden">
            <!-- Header with enhanced styling -->
            <div class="p-4 flex items-center space-x-3 border-b border-gray-100">
                <img 
                    :src="getClubLogo(blog.club?.background_images)" 
                    alt="Club Logo" 
                    class="w-12 h-12 rounded-full object-cover ring-2 ring-offset-2 ring-yellow-400 transform hover:scale-105 transition-transform" 
                />
                <div class="flex-grow">
                    <div class="flex items-center gap-2 mb-1">
                        <h2 class="font-semibold text-gray-900 hover:text-yellow-600 transition-colors cursor-pointer">{{ blog.club?.name }}</h2>
                        <span v-if="blog.category" class="px-2 py-0.5 bg-yellow-100 text-yellow-800 text-xs font-medium rounded-full">
                            {{ blog.category.name }}
                        </span>
                    </div>
                    <p class="text-sm text-gray-500 flex items-center">
                        <ClockIcon class="w-4 h-4 mr-1" />
                        {{ formatDate(blog.created_at) }}
                    </p>
                </div>
                <DropDownMenu v-if="showActions" :options="dropdownOptions" @select="(option) => handleSelect(option, blog)">
                    <template #trigger>
                        <button class="p-2 hover:bg-gray-100 rounded-full transition-colors">
                            <MoreVerticalIcon class="w-5 h-5 text-gray-600" />
                        </button>
                    </template>
                </DropDownMenu>
            </div>

            <!-- Content with improved typography and spacing -->
            <div class="px-4 py-3">
                <h3 class="text-xl font-bold text-gray-900 mb-2 hover:text-yellow-600 transition-colors cursor-pointer line-clamp-2">
                    {{ blog.title }}
                </h3>
                <p class="text-gray-700 leading-relaxed line-clamp-3">{{ blog.content }}</p>
            </div>

            <!-- Image with enhanced presentation -->
            <div v-if="blog.background_images && blog.background_images.length > 0" class="relative aspect-video overflow-hidden bg-gray-100">
                <img 
                    :src="blog.background_images[0].image_url" 
                    :alt="blog.title" 
                    class="w-full h-full object-cover hover:scale-105 transition-transform duration-500" 
                />
            </div>
        </div>

        <!-- Modals -->
        <ModalEdit 
            v-if="isEditModalOpen" 
            :isOpen="isEditModalOpen" 
            type="blog"
            :itemData="selectedBlog"
            @close="closeEditModal"
            @blogUpdated="handleBlogUpdated"
        />

        <!-- Delete Confirmation Modal with enhanced styling -->
        <div v-if="isDeleteModalOpen" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div class="bg-white rounded-xl p-6 max-w-md w-full mx-4 transform transition-all">
                <h3 class="text-xl font-semibold text-gray-900 mb-4">Xác nhận xóa</h3>
                <p class="text-gray-600 mb-6">Bạn có chắc chắn muốn xóa blog này?</p>
                <div class="flex justify-end gap-4">
                    <button 
                        @click="closeDeleteModal" 
                        class="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
                    >
                        Hủy
                    </button>
                    <button 
                        @click="confirmDelete" 
                        class="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                    >
                        Xóa
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { MoreVerticalIcon, PenSquare, Trash2, InboxIcon, ThumbsUpIcon, MessageCircleIcon, ShareIcon, ClockIcon } from 'lucide-vue-next';
import DropDownMenu from '../../DropDownMenu.vue';
import ModalEdit from '../ModalEdit.vue';
import { storeToRefs } from 'pinia';
import { useBlogStore } from '../../../stores/blogStore';
import { computed } from 'vue';

export default {
    components: {
        DropDownMenu,
        MoreVerticalIcon,
        ModalEdit,
        InboxIcon,
        ThumbsUpIcon,
        MessageCircleIcon,
        ShareIcon,
        ClockIcon
    },
    props: {
        showActions: {
            type: Boolean,
            default: false
        }
    },
    setup() {
        const blogStore = useBlogStore();
        const { filteredBlogs } = storeToRefs(blogStore);
        
        // Add debugging to see what blogs are available
        console.log('Filtered blogs in BlogList:', filteredBlogs.value);
        
        // Force a reactive update by creating a computed property
        const blogs = computed(() => {
            console.log('Computing blogs:', filteredBlogs.value);
            return filteredBlogs.value || [];
        });
        
        return { filteredBlogs: blogs, blogStore };
    },
    data() {
        return {
            dropdownOptions: [
                { label: "Chỉnh sửa Blog", icon: PenSquare },
                { label: "Xóa Blog", icon: Trash2, danger: true },
            ],
            isEditModalOpen: false,
            isDeleteModalOpen: false,
            selectedBlog: null
        };
    },
    methods: {
        formatDate(dateString) {
            if (!dateString) return '';
            const date = new Date(dateString);
            return date.toLocaleDateString('vi-VN', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        },
        getClubLogo(images) {
            if (!images || !Array.isArray(images) || images.length === 0) {
                console.log('No club logo images available, using placeholder');
                return 'https://via.placeholder.com/40';
            }
            
            const logo = images.find(img => img.is_logo === 1);
            if (logo) {
                console.log('Found club logo:', logo.image_url);
                return logo.image_url;
            }
            
            console.log('No logo found in images, using first image or placeholder');
            return images[0]?.image_url || 'https://via.placeholder.com/40';
        },
        handleSelect(option, blog) {
            this.selectedBlog = blog;
            if (option.label === "Chỉnh sửa Blog") {
                this.openEditModal();
            } else if (option.label === "Xóa Blog") {
                this.openDeleteModal();
            }
        },
        openEditModal() {
            this.isEditModalOpen = true;
        },
        closeEditModal() {
            this.isEditModalOpen = false;
            this.selectedBlog = null;
        },
        openDeleteModal() {
            this.isDeleteModalOpen = true;
        },
        closeDeleteModal() {
            this.isDeleteModalOpen = false;
            this.selectedBlog = null;
        },
        async confirmDelete() {
            if (!this.selectedBlog) return;
            try {
                await this.blogStore.deleteBlog(this.selectedBlog.id);
                this.closeDeleteModal();
            } catch (error) {
                console.error('Error deleting blog:', error);
            }
        },
        handleBlogUpdated(updatedBlog) {
            // Handle the event when a blog is updated
            console.log('Blog updated:', updatedBlog);
            this.closeEditModal();
            // Refresh the blog list for the specific club
            this.blogStore.fetchBlogs(true);
        }
    }
}
</script>
