<template>
    <!-- Main modal -->
    <Teleport to="body">
        <transition name="fade">
            <div v-if="isOpen" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center overflow-y-auto p-4">
                <transition name="slide-up">
                    <div v-if="isOpen" class="bg-white rounded-xl shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
                        <!-- Header -->
                        <div class="flex items-center justify-between border-b border-gray-200 px-6 py-4">
                            <h2 class="text-xl font-semibold">Chỉnh sửa {{ type === 'blog' ? 'Blog' : 'Sự Kiện' }}</h2>
                            <button @click="closeModal" class="text-gray-500 hover:text-gray-700">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-x">
                                    <path d="M18 6 6 18"/>
                                    <path d="m6 6 12 12"/>
                                </svg>
                            </button>
                        </div>

                        <!-- Form Content -->
                        <div class="overflow-y-auto flex-1 p-6">
                            <form @submit.prevent="handleSubmit">
                                <!-- Image Upload Section -->
                                <div class="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg border border-blue-200 p-5 mb-8 shadow-sm">
                                    <div class="flex justify-between items-center mb-3">
                                        <h2 class="text-blue-600 font-medium text-lg">{{ type === 'blog' ? 'Ảnh bìa Blog' : 'Hình ảnh Sự kiện' }}</h2>
                                        <span class="text-blue-500 text-sm font-medium">Quan trọng</span>
                                    </div>
                                    <div class="border border-blue-200 bg-white rounded-lg p-4 flex flex-col items-center justify-center h-72">
                                        <!-- Preview Image -->
                                        <div v-if="imagePreview" class="relative w-full h-full">
                                            <img :src="imagePreview" class="w-full h-full object-contain rounded-lg" alt="Preview" />
                                            <button @click.prevent="removeImage" class="absolute top-2 right-2 bg-white rounded-full p-1.5 shadow-md hover:bg-gray-100">
                                                <XIcon class="w-5 h-5 text-gray-600" />
                                            </button>
                                        </div>
                                        
                                        <!-- Upload Placeholder -->
                                        <template v-else>
                                            <div class="text-blue-500 mb-4">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-cloud-upload">
                                                    <path d="M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242"/>
                                                    <path d="M12 12v9"/>
                                                    <path d="m16 16-4-4-4 4"/>
                                                </svg>
                                            </div>
                                            <p class="text-gray-700 text-lg mb-1">Kéo và Thả ảnh vào đây</p>
                                            <p class="text-gray-500 text-sm mb-6">hoặc</p>
                                            <input type="file" id="image" @change="handleImageUpload" accept="image/*" class="hidden" />
                                            <label for="image" class="border border-blue-300 bg-blue-50 text-blue-600 rounded-md px-5 py-2.5 text-sm flex items-center gap-2 cursor-pointer hover:bg-blue-100 transition-colors">
                                                <span class="text-lg">+</span> Chọn ảnh
                                            </label>
                                        </template>
                                    </div>
                                    <p class="mt-2 text-sm text-blue-600">Hình ảnh đẹp sẽ thu hút nhiều người {{ type === 'blog' ? 'đọc' : 'tham gia' }} hơn</p>
                                </div>

                                <!-- Basic Information Section -->
                                <div class="bg-white rounded-lg border border-gray-200 p-4 mb-6">
                                    <div class="flex justify-between items-center mb-4">
                                        <h2 class="text-blue-500 font-medium">Thông tin cơ bản</h2>
                                        <span class="text-gray-500 text-sm">0/3</span>
                                    </div>
                                    
                                    <!-- Blog Title or Event Name -->
                                    <div class="mb-4">
                                        <label class="block text-gray-700 mb-2">{{ type === 'blog' ? 'Tiêu đề' : 'Tên Sự Kiện' }} <span class="text-red-500">*</span></label>
                                        <input 
                                            type="text" 
                                            v-model="formData[type === 'blog' ? 'title' : 'name']"
                                            :placeholder="`Nhập ${type === 'blog' ? 'tiêu đề blog' : 'tên sự kiện'}`" 
                                            class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-1 focus:ring-blue-500"
                                            required
                                        >
                                    </div>
                                    
                                    <!-- Category Selection -->
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-gray-700 mb-2">Danh mục <span class="text-red-500">*</span></label>
                                            <div class="relative">
                                                <select 
                                                    v-model="formData.category_id"
                                                    class="w-full border border-gray-300 rounded-md px-3 py-2 appearance-none focus:outline-none focus:ring-1 focus:ring-blue-500"
                                                    required
                                                >
                                                    <option value="">Chọn danh mục</option>
                                                    <option v-for="category in categories" :key="category.id" :value="category.id">
                                                        {{ category.name }}
                                                    </option>
                                                </select>
                                                <div class="absolute inset-y-0 right-0 flex items-center px-2 pointer-events-none">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-chevron-down">
                                                        <path d="m6 9 6 6 6-6"/>
                                                    </svg>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <!-- Event-specific fields -->
                                        <template v-if="type === 'event'">
                                            <div>
                                                <label class="block text-gray-700 mb-2">Địa Điểm <span class="text-red-500">*</span></label>
                                                <input 
                                                    type="text" 
                                                    v-model="formData.location"
                                                    placeholder="Nhập địa điểm..." 
                                                    class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-1 focus:ring-blue-500"
                                                    required
                                                >
                                            </div>
                                        </template>
                                    </div>
                                </div>

                                <!-- Event-specific Date and Time Section -->
                                <div v-if="type === 'event'" class="bg-white rounded-lg border border-gray-200 p-4 mb-6">
                                    <div class="flex justify-between items-center mb-4">
                                        <h2 class="text-blue-500 font-medium">Thời gian</h2>
                                    </div>
                                    
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-gray-700 mb-2">Thời Gian Bắt Đầu <span class="text-red-500">*</span></label>
                                            <input 
                                                type="datetime-local" 
                                                v-model="formData.start_date"
                                                class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-1 focus:ring-blue-500"
                                                required
                                            >
                                        </div>
                                        
                                        <div>
                                            <label class="block text-gray-700 mb-2">Thời Gian Kết Thúc <span class="text-red-500">*</span></label>
                                            <input 
                                                type="datetime-local" 
                                                v-model="formData.end_date"
                                                class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-1 focus:ring-blue-500"
                                                required
                                            >
                                        </div>
                                    </div>
                                </div>

                                <!-- Content Section -->
                                <div class="bg-white rounded-lg border border-gray-200 p-4 mb-6">
                                    <div class="flex justify-between items-center mb-4">
                                        <h2 class="text-blue-500 font-medium">{{ type === 'blog' ? 'Nội dung' : 'Mô tả' }} <span class="text-red-500">*</span></h2>
                                    </div>
                                    
                                    <textarea 
                                        v-model="formData.content"
                                        :placeholder="`Nhập ${type === 'blog' ? 'nội dung blog' : 'mô tả sự kiện'}...`" 
                                        class="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-1 focus:ring-blue-500 h-32 mb-2"
                                        required
                                    ></textarea>
                                    
                                    <div v-if="type === 'blog'" class="flex border-t pt-2">
                                        <button type="button" class="text-gray-500 mr-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-bold">
                                                <path d="M14 12a4 4 0 0 0 0-8H6v8"/>
                                                <path d="M15 20a4 4 0 0 0 0-8H6v8Z"/>
                                            </svg>
                                        </button>
                                        <button type="button" class="text-gray-500 mr-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-italic">
                                                <line x1="19" x2="10" y1="4" y2="4"/>
                                                <line x1="14" x2="5" y1="20" y2="20"/>
                                                <line x1="15" x2="9" y1="4" y2="20"/>
                                            </svg>
                                        </button>
                                        <button type="button" class="text-gray-500 mr-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-underline">
                                                <path d="M6 4v6a6 6 0 0 0 12 0V4"/>
                                                <line x1="4" x2="20" y1="20" y2="20"/>
                                            </svg>
                                        </button>
                                        <button type="button" class="text-gray-500 mr-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-list">
                                                <line x1="8" x2="21" y1="6" y2="6"/>
                                                <line x1="8" x2="21" y1="12" y2="12"/>
                                                <line x1="8" x2="21" y1="18" y2="18"/>
                                                <line x1="3" x2="3.01" y1="6" y2="6"/>
                                                <line x1="3" x2="3.01" y1="12" y2="12"/>
                                                <line x1="3" x2="3.01" y1="18" y2="18"/>
                                            </svg>
                                        </button>
                                        <button type="button" class="text-gray-500 mr-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-list-ordered">
                                                <line x1="10" x2="21" y1="6" y2="6"/>
                                                <line x1="10" x2="21" y1="12" y2="12"/>
                                                <line x1="10" x2="21" y1="18" y2="18"/>
                                                <path d="M4 6h1v4"/>
                                                <path d="M4 10h2"/>
                                                <path d="M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"/>
                                            </svg>
                                        </button>
                                        <button type="button" class="text-gray-500">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-link">
                                                <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>
                                                <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>
                                            </svg>
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <!-- Footer -->
                        <div class="border-t border-gray-200 px-6 py-4 flex justify-end">
                            <button 
                                @click="closeModal" 
                                class="px-4 py-2 border border-gray-300 rounded-md mr-2 hover:bg-gray-50"
                            >
                                Hủy
                            </button>
                            <button 
                                @click="handleSubmit"
                                :disabled="isSubmitting"
                                class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                                <span v-if="isSubmitting" class="flex items-center">
                                    <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                    </svg>
                                    Đang cập nhật...
                                </span>
                                <span v-else>Cập nhật {{ type === 'blog' ? 'Blog' : 'Sự kiện' }}</span>
                            </button>
                        </div>
                    </div>
                </transition>
            </div>
        </transition>
    </Teleport>
    <Notification 
        :type="notificationType" 
        :message="notificationMessage" 
        :duration="notificationDuration" 
        v-model:show="showNotification" 
    />
</template>

<script>
import { ref, onMounted, computed, watch } from 'vue';
import { XIcon } from 'lucide-vue-next';
import { useBlogStore } from '../../stores/blogStore';
import { useEventStore } from '../../stores/eventStore';
import { useCategoryStore } from '../../stores/categoryStore';
import { useRoute } from 'vue-router';
import Notification from '../Notification.vue';
import { useNotification } from '../../composables/useNotification';

export default {
    components: {
        XIcon,
        Notification
    },
    props: {
        isOpen: {
            type: Boolean,
            default: false
        },
        type: {
            type: String,
            default: 'blog',
            validator: (value) => ['blog', 'event'].includes(value)
        },
        itemData: {
            type: Object,
            required: true
        }
    },
    emits: ['close', 'eventUpdated', 'blogUpdated'],
    setup(props, { emit }) {
        const route = useRoute();
        const blogStore = useBlogStore();
        const eventStore = useEventStore();
        const categoryStore = useCategoryStore();
        const isSubmitting = ref(false);
        const imageFile = ref(null);
        const imagePreview = ref(null);
        
        // Initialize notification
        const {
            showNotification,
            notificationType,
            notificationMessage,
            notificationDuration,
            showSuccess,
            showError
        } = useNotification();

        // Initialize form data based on type
        const formData = ref(props.type === 'blog' ? {
            title: '',
            club_id: '',
            description: '',
            category_id: '',
            content: '',
            imageUrl: '',
            imageFile: null
        } : {
            club_id: '',
            category_id: '',
            name: '',
            start_date: '',
            end_date: '',
            location: '',
            max_participants: 1,
            content: '',
            status: 'active',
            logo: null
        });

        // Add computed property for categories
        const categories = computed(() => {
            return props.type === 'blog' ? categoryStore.blogCategories : categoryStore.eventCategories;
        });

        // Watch for changes in itemData
        watch(() => props.itemData, (newData) => {
            if (newData) {
                if (props.type === 'blog') {
                    formData.value = {
                        title: newData.title,
                        club_id: newData.club_id,
                        description: newData.description || '',
                        category_id: newData.category_id,
                        content: newData.content,
                        imageUrl: newData.background_images?.[0]?.image_url || '',
                        imageFile: null
                    };
                    
                    // Set image preview if available
                    if (newData.background_images && newData.background_images.length > 0) {
                        imagePreview.value = newData.background_images[0].image_url;
                    }
                } else {
                    formData.value = { 
                        ...newData,
                        club_id: route.params.id
                    };
                    
                    // Set image preview if available
                    if (newData.background_images && newData.background_images.length > 0) {
                        const logoImage = newData.background_images.find(img => img.is_logo);
                        if (logoImage) {
                            imagePreview.value = logoImage.image_url;
                        }
                    }
                }
            }
        }, { immediate: true });

        const handleImageUpload = (event) => {
            const file = event.target.files[0];
            if (file) {
                imageFile.value = file;
                imagePreview.value = URL.createObjectURL(file);
                
                // Set the image in formData based on type
                if (props.type === 'blog') {
                    formData.value.imageFile = file;
                } else {
                    // For event, set the logo property
                    formData.value.logo = file;
                }
            }
        };

        const removeImage = () => {
            imageFile.value = null;
            imagePreview.value = null;
            // Reset file input
            const fileInput = document.getElementById('image');
            if (fileInput) fileInput.value = '';
            
            // Clear the image in formData based on type
            if (props.type === 'blog') {
                formData.value.imageFile = null;
            } else {
                formData.value.logo = null;
            }
        };

        const validateForm = () => {
            const errors = {};
            
            if (props.type === 'blog') {
                if (!formData.value.title?.trim()) {
                    errors.title = 'Vui lòng nhập tiêu đề blog';
                }
                
                if (!formData.value.category_id) {
                    errors.category = 'Vui lòng chọn danh mục';
                }
                
                if (!formData.value.content?.trim()) {
                    errors.content = 'Vui lòng nhập nội dung blog';
                }
            } else {
                if (!formData.value.name?.trim()) {
                    errors.name = 'Vui lòng nhập tên sự kiện';
                }
                
                if (!formData.value.location?.trim()) {
                    errors.location = 'Vui lòng nhập địa điểm';
                }
                
                if (!formData.value.category_id) {
                    errors.category = 'Vui lòng chọn thể loại';
                }
                
                if (!formData.value.start_date) {
                    errors.start_date = 'Vui lòng chọn thời gian bắt đầu';
                }
                
                if (!formData.value.end_date) {
                    errors.end_date = 'Vui lòng chọn thời gian kết thúc';
                }
            }

            return errors;
        };

        const handleSubmit = async () => {
            const errors = validateForm();
            if (Object.keys(errors).length > 0) {
                // Show error notification
                showError('Vui lòng điền đầy đủ thông tin');
                return;
            }

            isSubmitting.value = true;
            try {
                if (props.type === 'blog') {
                    const formDataToSend = new FormData();
                    Object.keys(formData.value).forEach(key => {
                        if (key !== 'imageUrl' && key !== 'imageFile') {
                            formDataToSend.append(key, formData.value[key]);
                        }
                    });
                    
                    if (imageFile.value) {
                        formDataToSend.append('image', imageFile.value);
                    }

                    const response = await blogStore.updateBlog(props.itemData.id, formDataToSend);
                    showSuccess('Cập nhật blog thành công');
                    emit('blogUpdated', response);
                } else {
                    const eventData = {
                        ...formData.value,
                        logo: imageFile.value
                    };

                    const response = await eventStore.updateEvent(props.itemData.id, eventData);
                    showSuccess('Cập nhật sự kiện thành công');
                    emit('eventUpdated', response);
                }
                emit('close');
            } catch (error) {
                console.error(`Error updating ${props.type}:`, error);
                showError(`Có lỗi xảy ra khi cập nhật ${props.type === 'blog' ? 'blog' : 'sự kiện'}`);
            } finally {
                isSubmitting.value = false;
            }
        };

        const closeModal = () => {
            emit('close');
        };

        onMounted(async () => {
            await categoryStore.fetchCategories();
        });

        return {
            formData,
            imageFile,
            imagePreview,
            categories,
            isSubmitting,
            handleImageUpload,
            removeImage,
            handleSubmit,
            closeModal,
            showNotification,
            notificationType,
            notificationMessage,
            notificationDuration,
            showSuccess,
            showError
        };
    }
};
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(20px);
  opacity: 0;
}

img {
  border: 1px solid #ddd;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style> 