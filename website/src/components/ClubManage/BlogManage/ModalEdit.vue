<template>
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg p-6 max-w-2xl w-full mx-4">
            <div class="flex justify-between items-center mb-6">
                <h3 class="text-lg font-semibold">Chỉnh sửa Blog</h3>
                <button @click="$emit('close')" class="text-gray-500 hover:text-gray-700">
                    <XIcon class="w-6 h-6" />
                </button>
            </div>

            <form @submit.prevent="handleSubmit" class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Tiêu đề</label>
                    <input 
                        v-model="formData.title"
                        type="text"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                        required
                    />
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Danh mục</label>
                    <select 
                        v-model="formData.category_id"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                        required
                    >
                        <option value="">Chọn danh mục</option>
                        <option v-for="category in categories" :key="category.id" :value="category.id">
                            {{ category.name }}
                        </option>
                    </select>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Mô tả ngắn</label>
                    <textarea 
                        v-model="formData.description"
                        rows="2"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                    ></textarea>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Nội dung</label>
                    <textarea 
                        v-model="formData.content"
                        rows="6"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-yellow-500"
                        required
                    ></textarea>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Ảnh bìa</label>
                    <div class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md">
                        <div class="space-y-1 text-center">
                            <div v-if="formData.imageUrl" class="relative cursor-pointer" @click="$refs.fileInput.click()">
                                <img 
                                    :src="formData.imageUrl" 
                                    class="mx-auto h-32 w-32 object-cover"
                                />
                                <button 
                                    @click.stop="removeImage"
                                    class="absolute -top-2 -right-2 bg-white rounded-full p-1 shadow-md hover:bg-gray-100"
                                >
                                    <XIcon class="w-4 h-4 text-gray-600" />
                                </button>
                                <input 
                                    ref="fileInput"
                                    type="file" 
                                    class="hidden" 
                                    accept="image/*"
                                    @change="handleImageChange"
                                >
                            </div>
                            <div v-else class="flex flex-col items-center">
                                <ImageIcon class="mx-auto h-12 w-12 text-gray-400" />
                                <div class="flex text-sm text-gray-600">
                                    <label class="relative cursor-pointer bg-white rounded-md font-medium text-yellow-600 hover:text-yellow-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-yellow-500">
                                        <span>Upload a file</span>
                                        <input 
                                            type="file" 
                                            class="sr-only" 
                                            accept="image/*"
                                            @change="handleImageChange"
                                        >
                                    </label>
                                    <p class="pl-1">or drag and drop</p>
                                </div>
                                <p class="text-xs text-gray-500">PNG, JPG, GIF up to 10MB</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex justify-end gap-4 mt-6">
                    <button 
                        type="button"
                        @click="$emit('close')"
                        class="px-4 py-2 text-gray-600 hover:text-gray-800"
                    >
                        Hủy
                    </button>
                    <button 
                        type="submit"
                        class="px-4 py-2 bg-yellow-500 text-white rounded hover:bg-yellow-600"
                        :disabled="isLoading"
                    >
                        {{ isLoading ? 'Đang lưu...' : 'Lưu thay đổi' }}
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue';
import { ImageIcon, XIcon } from 'lucide-vue-next';
import { useBlogStore } from '../../../stores/blogStore';
import { useCategoryStore } from '../../../stores/categoryStore';

export default {
    components: {
        ImageIcon,
        XIcon
    },
    props: {
        isOpen: {
            type: Boolean,
            required: true
        },
        blog: {
            type: Object,
            required: true
        }
    },
    setup(props, { emit }) {
        const blogStore = useBlogStore();
        const categoryStore = useCategoryStore();
        const isLoading = ref(false);

        const formData = ref({
            title: '',
            club_id: '',
            description: '',
            category_id: '',
            content: '',
            imageUrl: '',
            imageFile: null
        });

        const categories = computed(() => categoryStore.blogCategories);

        onMounted(async () => {
            await categoryStore.fetchCategories();
            if (props.blog) {
                formData.value = {
                    title: props.blog.title,
                    club_id: props.blog.club_id,
                    description: props.blog.description || '',
                    category_id: props.blog.category_id,
                    content: props.blog.content,
                    imageUrl: props.blog.background_images?.[0]?.image_url || '',
                    imageFile: null
                };
            }
        });

        const handleImageChange = (event) => {
            const file = event.target.files[0];
            if (file) {
                formData.value.imageFile = file;
                formData.value.imageUrl = URL.createObjectURL(file);
            }
        };

        const removeImage = () => {
            formData.value.imageFile = null;
            formData.value.imageUrl = '';
        };

        const handleSubmit = async () => {
            isLoading.value = true;
            try {
                const formDataToSend = new FormData();
                Object.keys(formData.value).forEach(key => {
                    if (key !== 'imageUrl' && key !== 'imageFile') {
                        formDataToSend.append(key, formData.value[key]);
                    }
                });
                
                if (formData.value.imageFile) {
                    formDataToSend.append('image', formData.value.imageFile);
                }

                await blogStore.updateBlog(props.blog.id, formDataToSend);
                emit('close');
            } catch (error) {
                console.error('Error updating blog:', error);
            } finally {
                isLoading.value = false;
            }
        };

        return {
            formData,
            categories,
            isLoading,
            handleImageChange,
            handleSubmit,
            removeImage
        };
    }
}
</script> 