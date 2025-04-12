<template>
  <div class="min-h-screen bg-gray-50" :class="{ 'opacity-50 pointer-events-none': !departmentStore.canManageClubs }">
    <!-- Main Content -->
    <div class="ml-16">
      <!-- Header -->
      <div class="bg-white border-b px-8 py-4 flex items-center justify-between">
        <div class="flex items-center">
          <ChevronLeftIcon class="w-5 h-5 mr-2" />
          <h1 class="text-xl font-medium">Thông tin CLB</h1>
        </div>
        <button 
          @click="toggleEditMode" 
          class="px-4 py-2 rounded-lg" 
          :class="{
            'bg-gray-500 text-white': isEditing,
            'bg-blue-500 text-white': !isEditing,
            'opacity-50 cursor-not-allowed': !departmentStore.canManageClubs
          }"
          :disabled="!departmentStore.canManageClubs"
        >
          {{ isEditing ? 'Hủy chỉnh sửa' : 'Chỉnh sửa' }}
        </button>
      </div>

      <!-- Form Content -->
      <div class="max-w-4xl mx-auto py-8 px-4">
        <form @submit.prevent="handleSubmit" ref="clubForm">
          <!-- Basic Information -->
          <div class="mb-8">
            <h2 class="text-xl text-blue-600 font-medium mb-6">
              Thông tin cơ bản
            </h2>

            <div class="grid grid-cols-2 gap-6 mb-6">
              <div>
                <label class="block mb-2">
                  Logo Câu Lạc Bộ
                  <span class="text-red-500">*</span>
                </label>
                <div
                  class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center cursor-pointer hover:border-blue-500 transition-colors"
                  @click="triggerLogoUpload">
                  <input type="file" ref="logoInput" @change="handleLogoUpload" accept="image/*" class="hidden" />
                  <div v-if="logoPreview || (selectedClub && selectedClub.background_images && selectedClub.background_images.find(img => img.is_logo === 1))" class="relative group">
                    <img 
                      :src="logoPreview || (selectedClub && selectedClub.background_images && selectedClub.background_images.find(img => img.is_logo === 1)?.image_url)" 
                      class="w-32 h-32 mx-auto mb-2 object-cover rounded-lg" 
                      alt="Club Logo"
                    />
                    <!-- Add loading overlay for logo -->
                    <div v-if="updatingLogo" class="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50 rounded-lg">
                      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-white"></div>
                    </div>
                    <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-black bg-opacity-50 rounded-lg">
                      <div class="flex space-x-2">
                        <button
                          v-if="isEditing"
                          @click.stop="triggerLogoUpload"
                          class="bg-blue-500 text-white p-2 rounded-full">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                            <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                          </svg>
                        </button>
                        <button
                          v-if="isEditing"
                          @click.stop="removeLogo"
                          class="bg-red-500 text-white p-2 rounded-full">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                  <template v-else>
                    <UploadIcon class="w-8 h-8 mx-auto mb-2 text-gray-400" />
                    <p class="text-sm text-gray-500">Tải logo lên</p>
                  </template>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  * Khuyến khích sử dụng ảnh 100x100px để hiển thị tốt nhất.
                </p>
              </div>

              <div>
                <label class="block mb-2">
                  Ảnh khác của CLB
                </label>
                <div
                  class="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center cursor-pointer hover:border-blue-500 transition-colors"
                  @click="triggerImagesUpload">
                  <input type="file" ref="imagesInput" @change="handleImagesUpload" accept="image/*" multiple class="hidden" />
                  <div v-if="imagesPreview.length > 0 || (selectedClub && selectedClub.background_images && selectedClub.background_images.filter(img => img.is_logo === 0).length > 0)" class="relative">
                    <div class="grid grid-cols-2 gap-4">
                      <div v-for="(image, index) in imagesPreview.length > 0 ? imagesPreview : (selectedClub && selectedClub.background_images ? selectedClub.background_images.filter(img => img.is_logo === 0) : [])" :key="image.id" class="relative group">
                        <img 
                          :src="image.url || image.image_url" 
                          class="w-32 h-32 mx-auto mb-2 object-cover rounded-lg" 
                          :alt="'Club Image ' + (index + 1)"
                        />
                        <!-- Add loading overlay -->
                        <div v-if="updatingImageId === image.id" class="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50 rounded-lg">
                          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-white"></div>
                        </div>
                        <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-black bg-opacity-50 rounded-lg">
                          <div class="flex space-x-2">
                            <button
                              v-if="isEditing && image.id"
                              @click.stop="triggerImageUpdate(image.id)"
                              class="bg-blue-500 text-white p-2 rounded-full">
                              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                              </svg>
                            </button>
                            <button
                              v-if="isEditing"
                              @click.stop="image.id ? deleteSpecificImage(image.id) : removeImage(index)"
                              class="bg-red-500 text-white p-2 rounded-full">
                              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                              </svg>
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <template v-else>
                    <UploadIcon class="w-8 h-8 mx-auto mb-2 text-gray-400" />
                    <p class="text-sm text-gray-500">Tải nhiều ảnh lên</p>
                  </template>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  * Có thể tải lên nhiều ảnh cùng lúc.
                </p>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-6">
              <div>
                <label class="block mb-2">
                  Tên CLB
                  <span class="text-red-500">*</span>
                </label>
                <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                  <input v-if="isEditing" type="text" v-model="form.name" class="w-full bg-white"
                    placeholder="Nhập tên CLB" />
                  <template v-else>{{ selectedClub?.name || 'Chưa có thông tin' }}</template>
                </div>
              </div>

              <div>
                <label class="block mb-2">
                  Danh mục
                  <span class="text-red-500">*</span>
                </label>
                <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                  <select v-if="isEditing" v-model="form.category_id" class="w-full bg-white">
                    <option v-for="category in categoryStore.categories" :key="category.id" :value="category.id">{{
                      category.name }}
                    </option>
                  </select>
                  <template v-else>{{ categoryStore.getCategoryName(selectedClub?.category_id) || 'Chưa có thông tin'
                    }}</template>
                </div>
              </div>
            </div>
          </div>

          <!-- Description -->
          <div class="mb-8">
            <h2 class="text-xl text-blue-600 font-medium mb-6">
              Mô tả / Giới thiệu Câu Lạc Bộ
            </h2>
            <div>
              <label class="block mb-2">
                Giới thiệu CLB
                <span class="text-red-500">*</span>
              </label>
              <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                <textarea v-if="isEditing" v-model="form.description" rows="4" class="w-full bg-white resize-none"
                  placeholder="Nhập giới thiệu CLB"></textarea>
                <template v-else>{{ selectedClub?.description || 'Chưa có thông tin' }}</template>
              </div>
            </div>
          </div>

          <!-- Contact Information -->
          <div class="mb-8">
            <h2 class="text-xl text-blue-600 font-medium mb-6">
              Thông tin liên hệ
            </h2>

            <div class="grid grid-cols-2 gap-6">
              <div>
                <label class="block mb-2">
                  Email liên hệ
                  <span class="text-red-500">*</span>
                </label>
                <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                  <input v-if="isEditing" type="email" v-model="form.contact_email" class="w-full bg-white"
                    placeholder="Nhập email liên hệ" />
                  <template v-else>{{ selectedClub?.contact_email || 'Chưa có thông tin' }}</template>
                </div>
              </div>

              <div>
                <label class="block mb-2">
                  Số điện thoại
                  <span class="text-red-500">*</span>
                </label>
                <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                  <input v-if="isEditing" type="tel" v-model="form.contact_phone" class="w-full bg-white"
                    placeholder="Nhập số điện thoại" />
                  <template v-else>{{ selectedClub?.contact_phone || 'Chưa có thông tin' }}</template>
                </div>
              </div>

              <div>
                <label class="block mb-2">
                  Địa chỉ
                  <span class="text-red-500">*</span>
                </label>
                <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                  <input v-if="isEditing" type="text" v-model="form.contact_address" class="w-full bg-white"
                    placeholder="Nhập địa chỉ" />
                  <template v-else>{{ selectedClub?.contact_address || 'Chưa có thông tin' }}</template>
                </div>
              </div>

              <div>
                <label class="block mb-2">
                  Tỉnh / Thành phố
                  <span class="text-red-500">*</span>
                </label>
                <div class="w-full px-3 py-2 border rounded-lg" :class="{ 'bg-gray-50': !isEditing }">
                  <input v-if="isEditing" type="text" v-model="form.province" class="w-full bg-white"
                    placeholder="Nhập tỉnh/thành phố" />
                  <template v-else>{{ selectedClub?.province || 'Chưa có thông tin' }}</template>
                </div>
              </div>
            </div>

            <!-- Social Media -->
            <div class="mt-6">
              <h3 class="font-medium mb-4">Mạng xã hội</h3>

              <div class="space-y-4">
                <div class="flex items-center gap-4">
                  <div class="w-32 flex items-center gap-2">
                    <img :src="socials[0].icon" alt="Facebook" class="w-8 h-8" />
                    <span>Facebook</span>
                  </div>
                  <input type="text" v-model="form.facebook_link" :disabled="!isEditing"
                    class="flex-1 px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    :placeholder="form.facebook_link || 'Nhập đường dẫn Facebook'
                      " />
                </div>
                <div class="flex items-center gap-4">
                  <div class="w-32 flex items-center gap-2">
                    <img :src="socials[1].icon" alt="Zalo" class="w-8 h-8" />
                    <span>Zalo</span>
                  </div>
                  <input type="text" v-model="form.zalo_link" :disabled="!isEditing"
                    class="flex-1 px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    :placeholder="form.zalo_link || 'Nhập đường dẫn Zalo'" />
                </div>
              </div>
            </div>
          </div>

          <!-- Form Actions -->
          <div class="flex justify-between pt-6 border-t">
            <div class="flex space-x-4">
            </div>
            <button v-if="isEditing" type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
              :disabled="isSubmitting">
              {{ isSubmitting ? 'Đang lưu...' : 'Lưu thông tin' }}
            </button>
          </div>
        </form>
      </div>
    </div>
    
    <!-- Notification Component -->
    <Notification 
      :type="notificationType" 
      :message="notificationMessage" 
      :duration="notificationDuration" 
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useCategoryStore } from '../../stores/categoryStore'
import { useClubStore } from '../../stores/clubStore'
import { useDepartmentStore } from '../../stores/departmentStore';
import { useNotification } from '../../composables/useNotification'
import Notification from '../../components/Notification.vue'
import {
  HomeIcon,
  UsersIcon,
  FolderIcon,
  ChevronLeftIcon,
  UploadIcon
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const categoryStore = useCategoryStore()
const clubForm = ref(null)
const departmentStore = useDepartmentStore();
const clubStore = useClubStore()
const { selectedClub } = storeToRefs(clubStore)

// Initialize notification
const { 
  showNotification, 
  notificationType, 
  notificationMessage, 
  notificationDuration,
  showSuccess,
  showError,
  showWarning,
  showInfo,
  showUpdateSuccess,
  showUpdateError
} = useNotification()

const isEditing = ref(false)

const form = ref({
  name: '',
  category_id: '',
  description: '',
  contact_email: '',
  contact_phone: '',
  contact_address: '',
  province: '',
  facebook_link: '',
  zalo_link: '',
  logo: null,
  images: [],
  deleted_image_ids: []
})

watch(selectedClub, (newClub) => {
  if (newClub) {
    form.value = {
      name: newClub.name || '',
      category_id: newClub.category_id || '',
      description: newClub.description || '',
      contact_email: newClub.contact_email || '',
      contact_phone: newClub.contact_phone || '',
      contact_address: newClub.contact_address || '',
      province: newClub.province || '',
      facebook_link: newClub.facebook_link || '',
      zalo_link: newClub.zalo_link || '',
      logo: null,
      images: [],
      deleted_image_ids: []
    }
  }
}, { immediate: true })

const logoPreview = ref(null)
const imagesPreview = ref([])
const logoInput = ref(null)
const imagesInput = ref(null)

const socials = [
  { id: 'facebook', name: 'Facebook', icon: 'https://th.bing.com/th/id/R.83e3cc297106767114f2c060f7f5fcbb?rik=FkFOcs3CThcCJQ&pid=ImgRaw&r=0' },
  { id: 'zalo', name: 'Zalo', icon: 'https://th.bing.com/th/id/OIP.-kImg-7dr-QEfCzb17cbEAHaHa?w=175&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7' },
]

// Add a ref to track which image is being updated
const updatingImageId = ref(null);

// Add a ref to track if logo is being updated
const updatingLogo = ref(false);

onMounted(async () => {
  try {
    await categoryStore.fetchCategories()
    
    const clubId = route.params.id
    if (clubId) {
      await clubStore.fetchClubById(clubId)
      await departmentStore.checkUserDepartment(clubId)
      
      console.log('Club data loaded:', selectedClub.value)
      
      // Initialize form data
      if (selectedClub.value) {
        form.value = {
          name: selectedClub.value.name || '',
          category_id: selectedClub.value.category_id || '',
          description: selectedClub.value.description || '',
          contact_email: selectedClub.value.contact_email || '',
          contact_phone: selectedClub.value.contact_phone || '',
          contact_address: selectedClub.value.contact_address || '',
          province: selectedClub.value.province || '',
          facebook_link: selectedClub.value.facebook_link || '',
          zalo_link: selectedClub.value.zalo_link || '',
          logo: null,
          images: [],
          deleted_image_ids: []
        }
      }
      
      // Check and display images
      checkAndDisplayImages();
    }
  } catch (error) {
    console.error('Error fetching club data:', error)
    showError('Không thể tải thông tin câu lạc bộ')
  }
})

const handleLogoUpload = async (event) => {
  const file = event.target.files[0]
  if (file) {
    // Validate file type
    if (!file.type.startsWith('image/')) {
      showError('Vui lòng chọn một file ảnh')
      return
    }

    // Validate file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      showError('Kích thước ảnh không được vượt quá 2MB')
      return
    }

    // Show loading state
    updatingLogo.value = true;
    
    try {
      // Add is_logo flag to the file object
      const fileWithFlag = new File([file], file.name, { type: file.type })
      fileWithFlag.is_logo = 1

      // Update the form
      form.value.logo = fileWithFlag
      
      // Create a temporary URL for immediate preview
      const tempImageUrl = URL.createObjectURL(file)
      logoPreview.value = tempImageUrl
      
      // If we're in edit mode, update the logo on the server
      if (isEditing.value) {
        const clubId = route.params.id;
        const logoImage = selectedClub.value?.background_images?.find(img => img.is_logo === 1);
        
        if (logoImage) {
          // Update existing logo
          await clubStore.updateClubImage(clubId, logoImage.id, fileWithFlag);
          
          // Update the UI
          if (selectedClub.value && selectedClub.value.background_images) {
            const logoIndex = selectedClub.value.background_images.findIndex(img => img.is_logo === 1);
            if (logoIndex !== -1) {
              selectedClub.value.background_images[logoIndex].image_url = tempImageUrl;
            }
          }
          
          showSuccess('Cập nhật logo thành công!');
        } else {
          // Create new logo
          await clubStore.updateClub(clubId, { ...form.value, logo: fileWithFlag });
          showSuccess('Thêm logo thành công!');
        }
      }
    } catch (error) {
      console.error('Error updating logo:', error);
      showError('Không thể cập nhật logo. Vui lòng thử lại.');
    } finally {
      updatingLogo.value = false;
    }
  }
}

const handleImagesUpload = (event) => {
  const files = Array.from(event.target.files)
  if (files.length > 0) {
    // Validate files
    for (const file of files) {
      if (!file.type.startsWith('image/')) {
        showError('Vui lòng chọn các file ảnh')
        return
      }
      if (file.size > 2 * 1024 * 1024) {
        showError('Kích thước ảnh không được vượt quá 2MB')
        return
      }
    }

    // Add new images to form
    form.value.images = [...form.value.images, ...files]
    
    // Add previews
    files.forEach(file => {
      imagesPreview.value.push({
        id: Date.now() + Math.random(), // Temporary ID for preview
        url: URL.createObjectURL(file)
      })
    })
  }
}

const removeImage = (index) => {
  const image = imagesPreview.value[index]
  if (image.id) {
    // If it's an existing image (has ID), add to deleted_image_ids
    form.value.deleted_image_ids.push(image.id)
  }
  
  // Remove from previews and form
  imagesPreview.value.splice(index, 1)
  
  // If it's a new image (no ID), remove from form.images
  if (!image.id) {
    const newImageIndex = form.value.images.findIndex(img => 
      URL.createObjectURL(img) === image.url
    )
    if (newImageIndex !== -1) {
      form.value.images.splice(newImageIndex, 1)
    }
  }
}

const toggleEditMode = () => {
  if (isEditing.value) {
    // Reset form when canceling edit
    form.value = {
      name: selectedClub.value?.name || '',
      category_id: selectedClub.value?.category_id || '',
      description: selectedClub.value?.description || '',
      contact_email: selectedClub.value?.contact_email || '',
      contact_phone: selectedClub.value?.contact_phone || '',
      contact_address: selectedClub.value?.contact_address || '',
      province: selectedClub.value?.province || '',
      facebook_link: selectedClub.value?.facebook_link || '',
      zalo_link: selectedClub.value?.zalo_link || '',
      logo: null,
      images: [],
      deleted_image_ids: []
    }
    
    // Reset image previews
    logoPreview.value = null;
    imagesPreview.value = [];
    
    // Check and display images from the club data
    checkAndDisplayImages();
  }
  isEditing.value = !isEditing.value
}

// Add a flag to track if a submission is in progress
const isSubmitting = ref(false)

const handleSubmit = async () => {
  // Prevent duplicate submissions
  if (isSubmitting.value) {
    console.log('Submission already in progress, ignoring duplicate call');
    return;
  }
  
  console.log('Form submit triggered');
  console.log('Current form data:', form.value);

  // Check if form exists
  if (!clubForm.value) {
    console.error('Form reference not found');
    return;
  }

  try {
    // Set the submitting flag
    isSubmitting.value = true;
    
    // Validate required fields and ensure they are not empty strings
    const requiredFields = {
      name: form.value.name?.trim(),
      category_id: form.value.category_id,
      description: form.value.description?.trim(),
      contact_email: form.value.contact_email?.trim(),
      contact_phone: form.value.contact_phone?.trim(),
      contact_address: form.value.contact_address?.trim(),
      province: form.value.province?.trim()
    };

    console.log('Required fields:', requiredFields);

    const emptyFields = Object.entries(requiredFields)
      .filter(([_, value]) => !value)
      .map(([key]) => key);

    if (emptyFields.length > 0) {
      console.error('Empty required fields:', emptyFields);
      showError(`Vui lòng điền đầy đủ các trường: ${emptyFields.join(', ')}`)
      return
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(form.value.contact_email)) {
      console.error('Invalid email format');
      showError('Email không đúng định dạng')
      return
    }

    const clubId = route.params.id;
    console.log('Club ID:', clubId);

    // Send form data directly to the service
    console.log('Sending form data to service:', form.value);
    const response = await clubStore.updateClub(clubId, form.value);
    console.log('Update response:', response);

    if (response) {
      showUpdateSuccess('CLB')

      // Reload club data from server
      await clubStore.fetchClubById(clubId)

      // Reset form data
      form.value = {
        name: selectedClub.value?.name || '',
        category_id: selectedClub.value?.category_id || '',
        description: selectedClub.value?.description || '',
        contact_email: selectedClub.value?.contact_email || '',
        contact_phone: selectedClub.value?.contact_phone || '',
        contact_address: selectedClub.value?.contact_address || '',
        province: selectedClub.value?.province || '',
        facebook_link: selectedClub.value?.facebook_link || '',
        zalo_link: selectedClub.value?.zalo_link || '',
        logo: null,
        images: [],
        deleted_image_ids: []
      }

      // Check and display images
      checkAndDisplayImages();

      // Exit edit mode
      isEditing.value = false;
    } else {
      showUpdateError('CLB')
    }
  } catch (error) {
    console.error('Error in handleSubmit:', error)
    if (error.response?.status === 422) {
      const validationErrors = error.response.data.errors
      const errorMessages = Object.values(validationErrors).flat().join('\n')
      showError('Lỗi xác thực:\n' + errorMessages)
    } else {
      showUpdateError('CLB')
    }
  } finally {
    // Reset the submitting flag
    isSubmitting.value = false;
  }
}

// Update the updateSpecificImage method
const updateSpecificImage = async (imageId, imageFile) => {
  try {
    // Set the updating image ID
    updatingImageId.value = imageId;
    
    const clubId = route.params.id;
    const response = await clubStore.updateClubImage(clubId, imageId, imageFile);
    
    // Create a temporary URL for the new image
    const tempImageUrl = URL.createObjectURL(imageFile);
    
    // Update the UI immediately
    if (selectedClub.value && selectedClub.value.background_images) {
      // Find the image in the club's background_images array
      const imageIndex = selectedClub.value.background_images.findIndex(img => img.id === imageId);
      
      if (imageIndex !== -1) {
        // Update the image URL in the selectedClub object
        selectedClub.value.background_images[imageIndex].image_url = tempImageUrl;
        
        // Also update the imagesPreview array if it contains this image
        const previewIndex = imagesPreview.value.findIndex(img => img.id === imageId);
        if (previewIndex !== -1) {
          imagesPreview.value[previewIndex].url = tempImageUrl;
        }
      }
    }
    
    showSuccess('Cập nhật ảnh thành công!');
  } catch (error) {
    console.error('Error updating specific image:', error);
    showError(error.message || 'Không thể cập nhật ảnh. Vui lòng thử lại.');
  } finally {
    // Clear the updating image ID
    updatingImageId.value = null;
  }
}

// Add a new method to delete a specific image
const deleteSpecificImage = async (imageId) => {
  try {
    const clubId = route.params.id;
    await clubStore.updateClubImage(clubId, imageId, null, 'delete');
    showSuccess('Xóa ảnh thành công!');
  } catch (error) {
    console.error('Error deleting specific image:', error);
    showError(error.message || 'Không thể xóa ảnh. Vui lòng thử lại.');
  }
}

const goToDashboard = () => {
  router.push('/dashboard')
}

const triggerLogoUpload = () => {
  logoInput.value.click()
}

const triggerImagesUpload = () => {
  imagesInput.value.click()
}

const triggerImageUpdate = (imageId) => {
  // Create a hidden input element
  const input = document.createElement('input');
  input.type = 'file';
  input.accept = 'image/*';
  input.style.display = 'none';
  
  // Add change event listener
  input.addEventListener('change', async (e) => {
    if (e.target.files && e.target.files[0]) {
      // Show loading state
      const loadingMessage = showInfo('Đang cập nhật ảnh...');
      
      try {
        await updateSpecificImage(imageId, e.target.files[0]);
        // Loading message will be replaced by success message in updateSpecificImage
      } catch (error) {
        // Error message will be shown in updateSpecificImage
      }
    }
  });
  
  // Trigger file selection
  document.body.appendChild(input);
  input.click();
  document.body.removeChild(input);
}

const removeLogo = () => {
  const logoImage = selectedClub.value?.background_images?.find(img => img.is_logo === 1)
  if (logoImage) {
    form.value.deleted_image_ids.push(logoImage.id)
  }
  form.value.logo = null
  logoPreview.value = null
}

const debugImageData = () => {
  console.log('Selected Club:', selectedClub.value);
  if (selectedClub.value && selectedClub.value.background_images) {
    const logoImage = selectedClub.value.background_images.find(img => img.is_logo === 1);
    console.log('Logo Image:', logoImage);
    if (logoImage) {
      logoPreview.value = logoImage.image_url;
    }
    const otherImages = selectedClub.value.background_images.filter(img => img.is_logo === 0);
    console.log('Other Images:', otherImages);
    imagesPreview.value = otherImages.map(img => ({
      url: img.image_url,
      id: img.id
    }));
  } else {
    console.log('No background images found in club data');
  }
}

// Add a method to directly check and display images from the API response
const checkAndDisplayImages = () => {
  console.log('Checking and displaying images...');
  console.log('Selected Club:', selectedClub.value);
  
  if (selectedClub.value && selectedClub.value.background_images) {
    console.log('Background Images:', selectedClub.value.background_images);
    
    // Check for logo image
    const logoImage = selectedClub.value.background_images.find(img => img.is_logo === 1);
    console.log('Logo Image:', logoImage);
    if (logoImage) {
      logoPreview.value = logoImage.image_url;
      console.log('Logo preview set to:', logoPreview.value);
    } else {
      console.log('No logo image found');
      logoPreview.value = null;
    }
    
    // Check for other images
    const otherImages = selectedClub.value.background_images.filter(img => img.is_logo === 0);
    console.log('Other Images:', otherImages);
    imagesPreview.value = otherImages.map(img => ({
      id: img.id,
      url: img.image_url
    }));
    console.log('Images preview set to:', imagesPreview.value);
  } else {
    console.log('No background images found in club data');
  }
}
</script>

<style scoped>
/* Add any additional styles here */
</style>
