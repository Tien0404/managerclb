<template>
    <div class="p-6 bg-gray-50 min-h-screen"> 
      
        <!-- Loading State -->
        <div v-if="loading" class="flex justify-center items-center h-screen">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
  
        <!-- Error State -->
        <div v-else-if="error" class="flex justify-center items-center h-screen">
          <div class="text-center">
            <p class="text-red-600 mb-4">{{ error }}</p>
            <button @click="fetchClubData" class="px-4 py-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200">
              Thử lại
            </button>
          </div>
        </div>
  
        <div v-else>
          <!-- Header -->
          <div class="flex justify-between items-center mb-8">
            <h1 class="text-xl font-semibold">Dashboard</h1>
            <div class="w-8 h-8 bg-gray-200 rounded-full">
              <img v-if="club?.background_images?.[0]?.image_url" 
                   :src="club.background_images[0].image_url"
                   class="w-full h-full object-cover rounded-full"
                   alt="Club logo" />
            </div>
          </div>
  
          <!-- Content -->
          <div class="p-8">
            <h2 class="text-2xl font-semibold mb-6">
              Chào mừng đến với {{ club?.name || 'Câu lạc bộ' }} 👋
            </h2>
  
            <!-- Warning Banner -->
            <div v-if="!isClubComplete" class="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-6">
              <div class="flex items-start">
                <AlertTriangleIcon class="w-5 h-5 text-orange-500 mt-0.5 mr-2" />
                <div>
                  <p class="font-medium text-orange-800">
                    Hồ sơ CLB còn thiếu ({{ completedSteps }}/3 hoàn tất)
                  </p>
                  <p class="text-orange-700 text-sm">
                    Hoàn thiện các bước cuối cùng bên dưới để Câu Lạc Bộ của bạn đi vào hoạt động
                  </p>
                </div>
              </div>
            </div>
  
            <!-- Action Cards -->
            <div class="grid grid-cols-3 gap-6 mb-8">
              <!-- Basic Info Card -->
              <div class="bg-green-50 rounded-lg p-6" :class="{'opacity-50': hasBasicInfo}">
                <h3 class="font-medium mb-2">Bổ sung Thông tin</h3>
                <p class="text-sm text-gray-600 mb-4">Thông tin cơ bản của Câu Lạc Bộ</p>
                <router-link :to="`/club/${clubId}/update-info-club`">
                  <button class="bg-black text-white px-4 py-2 rounded-lg text-sm" :disabled="hasBasicInfo">
                    {{ hasBasicInfo ? 'Đã hoàn thành' : 'Bắt đầu' }}
                  </button>
                </router-link>
              </div>
  
              <!-- Profile Page Card -->
              <div class="bg-blue-50 rounded-lg p-6" :class="{'opacity-50': hasProfilePage}">
                <h3 class="font-medium mb-2">Tạo Trang đại diện</h3>
                <p class="text-sm text-gray-600 mb-4">Trang đại diện của CLB và công khai trang</p>
                <router-link :to="`/club/${clubId}/profile`">
                  <button class="bg-black text-white px-4 py-2 rounded-lg text-sm" :disabled="hasProfilePage">
                    {{ hasProfilePage ? 'Đã hoàn thành' : 'Bắt đầu' }}
                  </button>
                </router-link>
              </div>
  
              <!-- Members Card -->
              <div class="bg-purple-50 rounded-lg p-6" :class="{'opacity-50': hasMembers}">
                <h3 class="font-medium mb-2">Thêm Thành viên</h3>
                <p class="text-sm text-gray-600 mb-4">Tạo phòng ban để quản lý thông tin thành viên</p>
                <router-link :to="`/club/${clubId}/members`">
                  <button class="bg-black text-white px-4 py-2 rounded-lg text-sm" :disabled="hasMembers">
                    {{ hasMembers ? 'Đã hoàn thành' : 'Bắt đầu' }}
                  </button>
                </router-link>
              </div>
            </div>
  
            <!-- Main Sections -->
            <div class="grid grid-cols-3 gap-6">
              <!-- Events Section -->
              <div class="col-span-2 bg-white border rounded-lg p-6">
                <div class="flex justify-between items-center mb-8">
                  <h3 class="font-medium">Sự kiện</h3>
                  <router-link :to="`/club/${clubId}/events/create`" class="text-blue-600 hover:text-blue-700">
                    Tạo sự kiện mới
                  </router-link>
                </div>
                
                <div v-if="club?.events?.length" class="space-y-4">
                  <div v-for="event in club.events" :key="event.id" 
                       class="border rounded-lg p-4 hover:shadow-md transition-shadow">
                    <div class="flex items-center justify-between">
                      <div>
                        <h4 class="font-medium">{{ event.name }}</h4>
                        <p class="text-sm text-gray-500">{{ formatDate(event.start_date) }}</p>
                      </div>
                      <span :class="getEventStatusClass(event.status)" class="px-3 py-1 rounded-full text-sm">
                        {{ event.status }}
                      </span>
                    </div>
                  </div>
                </div>
                
                <div v-else class="flex flex-col items-center justify-center py-12">
                  <p class="font-medium mb-2">Chưa có sự kiện nào</p>
                  <p class="text-sm text-gray-500 mb-4">Tạo sự kiện để thu hút các nhà tài trợ</p>
                  <router-link :to="`/club/${clubId}/events/create`">
                    <button class="flex items-center bg-black text-white px-4 py-2 rounded-lg text-sm">
                      <PlusIcon class="w-4 h-4 mr-2" />
                      Tạo Sự kiện
                    </button>
                  </router-link>
                </div>
              </div>
  
              <!-- Members Section -->
              <div class="bg-white border rounded-lg p-6">
                <div class="flex justify-between items-center mb-6">
                  <h3 class="font-medium">Thành viên</h3>
                  <router-link :to="`/club/${clubId}/members/invite`">
                    <button class="p-1 hover:bg-gray-100 rounded">
                      <PlusIcon class="w-5 h-5" />
                    </button>
                  </router-link>
                </div>
  
                <div v-if="club?.member_count" class="space-y-4">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                      <div class="w-8 h-8 bg-gray-200 rounded-full overflow-hidden">
                        <img v-if="club.background_images?.[0]?.image_url" 
                             :src="club.background_images[0].image_url"
                             class="w-full h-full object-cover"
                             alt="Club logo" />
                      </div>
                      <div>
                        <p class="text-sm font-medium">{{ club.name }}</p>
                        <p class="text-xs text-gray-500">{{ club.member_count }} thành viên</p>
                      </div>
                    </div>
                  </div>
                </div>
                
                <div v-else class="flex flex-col items-center justify-center py-8">
                  <p class="text-sm text-gray-500">Chưa có thành viên</p>
                  <router-link :to="`/club/${clubId}/members/invite`" class="mt-2 text-blue-600 hover:text-blue-700">
                    Mời thành viên
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, onMounted } from 'vue'
  import { useRoute } from 'vue-router'
  import { useClubStore } from '../../stores/clubStore'
  import { 
    HomeIcon,
    UsersIcon,
    FolderIcon,
    AlertTriangleIcon,
    PlusIcon
  } from 'lucide-vue-next'
  
  const route = useRoute()
  const clubStore = useClubStore()
  const clubId = computed(() => route.params.id)
  const loading = ref(false)
  const error = ref(null)
  
  // Get club data from store
  const club = computed(() => clubStore.selectedClub)
  
  // Computed properties for completion status
  const hasBasicInfo = computed(() => {
    return club.value?.name && club.value?.description && club.value?.category_id
  })
  
  const hasProfilePage = computed(() => {
    return club.value?.background_images?.length > 0
  })
  
  const hasMembers = computed(() => {
    return club.value?.member_count > 0
  })
  
  const completedSteps = computed(() => {
    let steps = 0
    if (hasBasicInfo.value) steps++
    if (hasProfilePage.value) steps++
    if (hasMembers.value) steps++
    return steps
  })
  
  const isClubComplete = computed(() => completedSteps.value === 3)
  
  // Fetch club data
  const fetchClubData = async () => {
    try {
      loading.value = true
      error.value = null
      await clubStore.fetchClubById(clubId.value)
    } catch (err) {
      console.error('Error fetching club:', err)
      error.value = 'Không thể tải thông tin câu lạc bộ'
    } finally {
      loading.value = false
    }
  }
  
  // Format date helper
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }
  
  // Get event status class
  const getEventStatusClass = (status) => {
    const classes = {
      'Sắp diễn ra': 'bg-blue-100 text-blue-800',
      'Đang diễn ra': 'bg-green-100 text-green-800',
      'Đã kết thúc': 'bg-gray-100 text-gray-800'
    }
    return classes[status] || 'bg-gray-100 text-gray-800'
  }
  
  // Initialize component
  onMounted(() => {
    fetchClubData()
  })
  </script>
  
  <style scoped>
  .grid {
    display: grid;
  }
  
  /* Add smooth transitions */
  .transition-shadow {
    transition: box-shadow 0.3s ease;
  }
  
  /* Add hover effects */
  .hover\:shadow-md:hover {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  }
  </style>