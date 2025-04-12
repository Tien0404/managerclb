<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Search Section -->
    <div class="container mx-auto px-4 py-6">
      <div class="flex gap-4 flex-wrap">
        <div class="flex-1 min-w-[200px]">
          <div class="relative">
            <SearchIcon class="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="Tìm kiếm Sự kiện"
              class="w-full pl-10 pr-4 py-2 border rounded-md border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500" 
            />
          </div>
        </div>
        <select 
          v-model="selectedLocation"
          class="border rounded-md px-4 py-2 bg-white border-gray-300"
        >
          <option :value="null">Khu vực</option>
          <option value="hanoi">Hà Nội</option>
          <option value="hcm">Hồ Chí Minh</option>
          <option value="danang">Đà Nẵng</option>
        </select>
        <select 
          v-model="selectedSort"
          class="border rounded-md px-4 py-2 bg-white border-gray-300"
        >
          <option :value="null">Sắp xếp theo</option>
          <option value="date">Ngày tổ chức</option>
          <option value="name">Tên sự kiện</option>
        </select>
      </div>
    </div>

    <!-- Events List -->
    <div class="container mx-auto px-4 py-8">
      <div class="space-y-16 lg:space-y-20">
        <!-- Loading State -->
        <div v-if="isLoading" class="text-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="text-center py-12">
          <div class="text-red-500 mb-4">{{ error }}</div>
          <button 
            @click="refreshData"
            class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
          >
            Thử lại
          </button>
        </div>

        <!-- No Events State -->
        <div v-else-if="!filteredEvents.length" class="text-center py-12">
          <div class="text-gray-500">Không có sự kiện nào</div>
        </div>

        <!-- Events Grid -->
        <div v-else class="grid grid-cols-1 gap-6">
          <div 
            v-for="event in filteredEvents" 
            :key="event.id"
            class="w-full grid grid-cols-12 gap-4 md:gap-10 cursor-pointer h-[300px] transition-transform transform hover:scale-105"
            @click="goToEventDetail(event.id)"
          >
            <div class="col-span-12 md:col-span-5 overflow-hidden rounded-2xl shadow-lg relative">
              <img 
                :src="event.background_images[0]?.image_url" 
                :alt="event.name" 
                class="w-full h-full object-cover object-center rounded-2xl" 
              />
            </div>
            <div class="col-span-12 md:col-span-7 flex flex-col justify-between p-4 bg-white rounded-2xl shadow-md">
              <div class="flex flex-col h-full justify-between">
                <div class="flex justify-between items-center mb-2">
                  <div class="text-sm font-medium px-2 py-1 rounded-md w-max bg-accent-red-600 text-base-white">
                    {{ event.category.name }}
                  </div>
                </div>
                <h3 class="text-xl font-semibold text-gray-800">
                  {{ event.name }}
                </h3>
                <div class="flex items-center text-gray-600 mb-2">
                  <UserIcon class="w-4 h-4 mr-2" />
                  <span class="text-lg">{{ event.club.name }}</span>
                </div>
                <div class="flex items-center text-gray-600 mb-2">
                  <MapPinIcon class="w-4 h-4 mr-2" />
                  <span class="text-lg">{{ event.location }}</span>
                </div>
                <div class="flex items-center text-gray-600">
                  <CalendarIcon class="w-4 h-4 mr-2" />
                  <span class="text-lg">
                    {{ new Date(event.start_date).toLocaleDateString('vi-VN') }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "../../stores/authStore";
import { useJoinRequestStore } from "../../stores/joinRequestStore";
import { UserIcon, MapPinIcon, SearchIcon, CalendarIcon, ChevronDown } from "lucide-vue-next";

const router = useRouter();
const events = ref([]);
const authStore = useAuthStore();
const joinRequestStore = useJoinRequestStore();
const isLoading = ref(false);
const error = ref(null);

// Lấy ID của user hiện tại
const userId = authStore.user?.id;

const fetchUserEvents = async () => {
  if (!userId) {
    console.warn("User chưa đăng nhập!");
    return;
  }
  isLoading.value = true;
  error.value = null;
  try {
    const data = await joinRequestStore.getUserEvent(userId);
    events.value = data;
  } catch (error) {
    console.error("Lỗi khi lấy sự kiện người dùng:", error.message);
    error.value = error.message;
  } finally {
    isLoading.value = false;
  }
};

const refreshData = () => {
  fetchUserEvents();
};

onMounted(() => {
  fetchUserEvents();
});

const goToEventDetail = (id) => {
  router.push({ path: `/event/${id}` });
};

// Search and filter functionality
const searchQuery = ref("");
const selectedLocation = ref(null);
const selectedSort = ref(null);

const filteredEvents = computed(() => {
  let filtered = [...events.value];

  // Search filter
  if (searchQuery.value) {
    filtered = filtered.filter(event => 
      event.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      event.club.name.toLowerCase().includes(searchQuery.value.toLowerCase())
    );
  }

  // Location filter
  if (selectedLocation.value) {
    filtered = filtered.filter(event => 
      event.location.toLowerCase().includes(selectedLocation.value.toLowerCase())
    );
  }

  // Sort
  if (selectedSort.value) {
    filtered.sort((a, b) => {
      if (selectedSort.value === 'date') {
        return new Date(a.start_date) - new Date(b.start_date);
      } else if (selectedSort.value === 'name') {
        return a.name.localeCompare(b.name);
      }
      return 0;
    });
  }

  return filtered;
});
</script>

<style>
.bg-accent-red-600 {
  background-color: #dc2626;
}

.text-base-white {
  color: #ffffff;
}
</style>
  