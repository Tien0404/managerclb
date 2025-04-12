<template>
  <div class="relative overflow-hidden min-h-screen bg-gradient-to-br from-lime-50 to-yellow-50">
    <div class="absolute inset-0 overflow-hidden">
      <!-- Decorative Blobs -->
      <div class="absolute top-0 left-0 w-64 h-64 bg-lime-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob"></div>
      <div class="absolute top-0 right-0 w-64 h-64 bg-yellow-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000"></div>
      <div class="absolute -bottom-8 left-20 w-64 h-64 bg-green-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000"></div>

      <!-- Flowing Background Animation -->
      <div class="absolute inset-0">
        <div class="absolute inset-0 bg-gradient-to-r from-lime-400/20 via-lime-300/20 to-lime-400/20 animate-flow"></div>
        <div class="absolute inset-0 bg-gradient-to-r from-lime-300/10 via-lime-400/10 to-lime-300/10 animate-flow-slow"></div>
        <div class="absolute inset-0 bg-gradient-to-r from-lime-500/10 via-lime-400/10 to-lime-500/10 animate-flow-slower"></div>
      </div>

      <!-- Wave Pattern -->
      <div class="absolute inset-0">
        <div class="wave"></div>
        <div class="wave wave-delayed"></div>
        <div class="wave wave-delayed-2"></div>
      </div>

      <!-- Particle Effects -->
      <div class="absolute inset-0">
        <div class="particles lime-particles"></div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="relative z-10">
      
      <div class="max-w-6xl mx-auto px-4 py-8 pt-20 relative">
          <div class="text-center mb-12 relative" data-aos="fade-down">
            <div class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-64 h-1 bg-gradient-to-r from-transparent via-lime-400 to-transparent"></div>
            
            <h1 class="text-4xl md:text-5xl font-bold mb-4 text-gray-900 relative glow-text-strong animate-gradient">
              Khám phá hành động
              <div class="absolute top-0 left-0 w-8 h-8 border-t-2 border-l-2 border-lime-400 transform -translate-x-4 -translate-y-4"></div>
              <div class="absolute top-0 right-0 w-8 h-8 border-t-2 border-r-2 border-lime-400 transform translate-x-4 -translate-y-4"></div>
            </h1>
            <h2 class="text-2xl md:text-3xl font-bold text-lime-600 glow-text-strong">
              17 Sự kiện hấp dẫn
            </h2>
            <div class="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1/2 w-40 h-1 bg-gradient-to-r from-transparent via-lime-400 to-transparent"></div>
          </div>
                <!-- Category Icons -->
        <div class="grid grid-cols-4 md:grid-cols-8 gap-6 mb-12">
          <div v-for="(category, index) in categories" 
               :key="category.id" 
               class="flex flex-col items-center gap-3 group cursor-pointer"
               :data-aos="index % 2 === 0 ? 'fade-right' : 'fade-left'"
               :data-aos-delay="100 * index"
               @click="handleCategorySelect(category.id)">
            <div class="relative w-16 h-16 rounded-xl border-[3px] border-lime-300 bg-white backdrop-blur-sm flex items-center justify-center transition-all duration-500 group-hover:bg-white group-hover:border-lime-500 group-hover:scale-110 group-hover:shadow-glow-lime-strong overflow-hidden">
              <div class="absolute inset-0 bg-gradient-to-br from-lime-50 to-white opacity-50 group-hover:opacity-100 transition-opacity duration-500"></div>
              <div class="absolute inset-0 border-[3px] border-transparent group-hover:border-lime-400 rounded-xl animate-border-flow"></div>
              <component :is="category.icon" class="w-7 h-7 text-lime-500 group-hover:text-lime-600 transition-all duration-500 transform group-hover:scale-110 relative z-10 stroke-[2.5]" />
            </div>
            <div class="text-sm text-center">
              <div class="font-medium text-gray-900 group-hover:text-lime-500 transition-colors duration-300">{{ category.name }}</div>
              <div class="text-gray-600">{{ category.subtext }}</div>
            </div>
          </div>
        </div>

      <!-- Search Section -->
 
        <div class="flex flex-col md:flex-row gap-4" data-aos="fade-up">
          <div class="relative flex-1 group">
            <div class="absolute -inset-0.5 bg-gradient-to-r from-lime-400 to-lime-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-500"></div>
            <div class="relative flex items-center">
              <div class="absolute left-4 flex items-center justify-center w-6 h-6 rounded-full transition-all duration-300 group-hover:bg-lime-100 group-hover:scale-110">
                <SearchIcon class="w-5 h-5 text-lime-400 group-hover:text-lime-500 transition-all duration-300 transform group-hover:rotate-12 stroke-[2.5]" />
              </div>
              <input 
                v-model="searchQuery"
                type="text" 
                placeholder="Tìm kiếm Sự kiện"
                class="w-full pl-12 pr-4 py-3 rounded-lg border-[3px] border-lime-300 bg-white backdrop-blur-sm focus:border-lime-500 focus:outline-none focus:ring-2 focus:ring-lime-400/50 transition-all duration-300 shadow-soft-lime hover:shadow-glow-lime-strong text-gray-900 placeholder-gray-500 hover:border-lime-400 input-focus-effect" />
            </div>
          </div>

          <div class="flex gap-4 flex-wrap">

            <div class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-lime-600 to-lime-400 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-500"></div>
              <div class="relative">
                <select 
                  v-model="selectedLocation"
                  class="appearance-none pl-4 pr-12 py-3 rounded-lg border-[3px] border-lime-300 bg-white backdrop-blur-sm focus:border-lime-500 focus:outline-none focus:ring-2 focus:ring-lime-400/50 transition-all duration-300 shadow-soft-lime hover:shadow-glow-lime-strong cursor-pointer text-gray-900 hover:border-lime-400">
                  <option :value="null">Khu vực</option>
                  <option value="hanoi">Hà Nội</option>
                  <option value="hcm">Hồ Chí Minh</option>
                  <option value="danang">Đà Nẵng</option>
                </select>
                <ChevronDownIcon class="absolute right-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-lime-400 group-hover:text-lime-500 transition-colors duration-300 pointer-events-none" />
              </div>
            </div>

            <div class="relative group">
              <div class="absolute -inset-0.5 bg-gradient-to-r from-lime-600 to-lime-400 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-500"></div>
              <div class="relative">
                <select 
                  v-model="selectedSort"
                  class="appearance-none pl-4 pr-12 py-3 rounded-lg border-[3px] border-lime-300 bg-white backdrop-blur-sm focus:border-lime-500 focus:outline-none focus:ring-2 focus:ring-lime-400/50 transition-all duration-300 shadow-soft-lime hover:shadow-glow-lime-strong cursor-pointer text-gray-900 hover:border-lime-400">
                  <option :value="null">Sắp xếp theo</option>
                  <option value="date">Ngày tổ chức</option>
                  <option value="name">Tên sự kiện</option>
                </select>
                <ChevronDownIcon class="absolute right-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-lime-400 group-hover:text-lime-500 transition-colors duration-300 pointer-events-none" />
              </div>
            </div>
          </div>
        </div>
        </div>



      <!-- Events List -->
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="space-y-8 mt-8">
          <!-- Loading State -->
          <div v-if="isLoading" class="relative">
            <div class="absolute inset-0 bg-white/50 backdrop-blur-sm z-10"></div>
            <div class="absolute inset-0 flex items-center justify-center z-20">
              <div class="flex flex-col items-center gap-4">
                <div class="relative">
                  <div class="w-16 h-16 border-4 border-lime-200 rounded-full animate-spin-slow"></div>
                  <div class="absolute inset-0 w-16 h-16 border-4 border-t-lime-400 border-r-lime-400 border-b-transparent border-l-transparent rounded-full animate-spin"></div>
                  <div class="absolute inset-0 w-16 h-16 rounded-full shadow-[0_0_15px_rgba(132,204,22,0.3)] animate-pulse"></div>
                </div>
                <div class="text-gray-900 font-medium drop-shadow-glow">Đang tải dữ liệu...</div>
              </div>
            </div>
            <div v-for="i in 3" :key="i" class="bg-white/90 backdrop-blur-md rounded-2xl shadow-soft-lime overflow-hidden flex flex-col md:flex-row mb-6 h-[250px] animate-pulse">
              <div class="w-[400px] h-full flex-shrink-0 bg-gray-200"></div>
              <div class="pt-6 pr-6 pl-6 pb-4 flex-1 min-w-0">
                <div class="flex gap-6">
                  <div class="flex flex-col h-full flex-1">
                    <div class="flex-1">
                      <div class="w-24 h-6 bg-gray-200 rounded-full mb-2"></div>
                      <div class="h-8 bg-gray-200 rounded-lg mb-2 w-3/4"></div>
                      <div class="space-y-2 mb-4">
                        <div class="h-4 bg-gray-200 rounded w-full"></div>
                        <div class="h-4 bg-gray-200 rounded w-5/6"></div>
                      </div>
                    </div>
                    <div class="flex items-center gap-4">
                      <div class="w-32 h-4 bg-gray-200 rounded"></div>
                      <div class="w-32 h-4 bg-gray-200 rounded"></div>
                    </div>
                  </div>
                  <div class="flex-shrink-0 w-24 h-24 bg-gray-200 rounded-xl"></div>
                </div>
                <div class="mt-4 w-80 h-10 bg-gray-200 rounded-lg mx-auto"></div>
              </div>
            </div>
          </div>

          <!-- Error State -->
          <div v-else-if="error" class="text-center py-12">
            <div class="mb-4">
              <XCircle class="w-16 h-16 text-red-500 mx-auto" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-2">{{ error }}</h3>
            <button 
              @click="refreshData"
              class="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors duration-300"
            >
              Thử lại
            </button>
          </div>

          <!-- No Data State -->
          <div v-else-if="!events.length" class="text-center py-12">
            <div class="text-gray-500 text-xl">Không có sự kiện nào</div>
            <button 
              @click="refreshData"
              class="mt-4 px-6 py-2 bg-lime-500 text-white rounded-lg hover:bg-lime-600 transition-colors duration-300"
            >
              Tải lại dữ liệu
            </button>
          </div>

          <!-- Event Cards -->
          <div v-else v-for="event in events" 
               :key="event.id"
               class="bg-white/90 backdrop-blur-md rounded-2xl shadow-soft-lime hover:shadow-glow-lime-strong overflow-hidden flex flex-col md:flex-row mb-6 transition-all duration-300 hover:scale-[1.02] group h-[250px]"
               :data-aos="'fade-up'"
               :data-aos-duration="300"
               :data-aos-offset="50"
               :data-aos-once="true"
               :data-aos-anchor-placement="'top-bottom'"
               @click="goToEventDetail(event.id)">
            <div class="w-[400px] h-full flex-shrink-0 relative overflow-hidden group-hover:opacity-90 transition-opacity duration-300">
                <img
                    :src="event.background_images[0]?.image_url"
                    alt="Event background"
                    class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                />
            </div>

            <div class="pt-6 pr-6 pl-6 pb-4 flex-1 min-w-0">
                <div class="flex gap-6">
                    <div class="flex flex-col h-full flex-1">
                        <div class="flex-1">
                            <span class="inline-block px-3 py-1 bg-lime-100 text-gray-900 text-sm font-medium rounded-full mb-2">
                                {{ event.category.name }}
                            </span>
                            <h2 class="text-2xl font-bold text-gray-900 mb-2 group-hover:text-lime-500 transition-colors duration-300 line-clamp-1">
                                {{ event.name }}
                            </h2>
                            <p class="text-gray-900 text-sm leading-relaxed mb-4 line-clamp-2">
                                {{ event.description }}
                            </p>
                        </div>

                        <div class="flex items-center gap-4 text-sm text-gray-900">
                            <div class="flex items-center gap-1">
                                <UserIcon class="w-4 h-4 text-lime-400 flex-shrink-0" />
                                <span class="truncate max-w-[150px]">{{ event.club.name }}</span>
                            </div>
                            <div class="flex items-center gap-1">
                                <MapPinIcon class="w-4 h-4 text-lime-400 flex-shrink-0" />
                                <span class="truncate max-w-[150px]">{{ event.location }}</span>
                            </div>
                        </div>
                    </div>

                    <div class="flex-shrink-0 flex flex-col items-center justify-center bg-lime-50 rounded-xl p-4 w-24 h-24 border-2 border-lime-200">
                        <CalendarIcon class="w-6 h-6 text-lime-500 mb-1" />
                        <div class="text-sm font-medium text-gray-900">
                            {{ new Date(event.start_date).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' }) }}
                        </div>
                        <div class="text-xs text-gray-600">
                            {{ new Date(event.start_date).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' }) }}
                        </div>
                    </div>
                </div>

                <router-link 
                    :to="`/event/${event.id}`" 
                    class="mt-4 w-80 py-2.5 text-center border-[3px] border-lime-300 text-gray-900 font-medium rounded-lg shadow-soft-lime hover:shadow-glow-lime-strong hover:bg-gradient-to-r hover:from-lime-500 hover:to-lime-600 hover:text-white hover:border-lime-500 transition-all duration-500 mx-auto block hover:scale-105"
                >
                    Chi tiết
                </router-link>
            </div>
          </div>
        </div>

        <!-- Load More Button -->
        <div v-if="events.length > 0" class="flex items-center justify-center mt-10 max-w-4xl mx-auto" data-aos="fade-up">
            <div class="flex-1 h-px bg-gradient-to-r from-transparent via-lime-200 to-transparent"></div>
            <button class="mx-8 px-8 py-2.5 rounded-lg bg-white/90 backdrop-blur-sm border-[3px] border-lime-300 text-gray-900 hover:text-white hover:border-lime-500 hover:bg-gradient-to-r hover:from-lime-500 hover:to-lime-600 transition-all duration-500 shadow-soft-lime hover:shadow-glow-lime-strong flex items-center justify-center font-medium min-w-[160px] hover:scale-105">
                Xem Thêm
                <ChevronDown class="ml-2 w-4 h-4 text-lime-400 group-hover:text-white" />
            </button>
            <div class="flex-1 h-px bg-gradient-to-r from-transparent via-lime-200 to-transparent"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { ref, onMounted, computed, watch } from 'vue';
import { useEventStore } from "../stores/eventStore";
import AOS from 'aos'
import 'aos/dist/aos.css'
import { storeToRefs } from 'pinia';

const router = useRouter();
import {
  BookOpenIcon,
  UserIcon,
  MapPinIcon,
  SearchIcon,
  UtensilsIcon,
  HeartIcon,
  UsersIcon,
  CalendarIcon,
  ChevronDownIcon,
  ChevronDown,
  XCircle,
} from "lucide-vue-next";

const eventStore = useEventStore();
const { isLoading, error } = storeToRefs(eventStore);

// Computed property for filtered events
const events = computed(() => {
  // Chỉ lấy các sự kiện có trạng thái active
  return eventStore.filteredEvents.filter(event => event.status === 'active');
});

// Search query
const searchQuery = ref('');
const selectedCategory = ref(null);
const selectedLocation = ref(null);
const selectedSort = ref(null);

// Apply filters
const applyFilters = () => {
  eventStore.setFilter('searchQuery', searchQuery.value);
  eventStore.setFilter('category', selectedCategory.value);
  eventStore.setFilter('location', selectedLocation.value);
  eventStore.setFilter('sortBy', selectedSort.value);
};

// Watch for filter changes
watch([searchQuery, selectedCategory, selectedLocation, selectedSort], () => {
  applyFilters();
}, { deep: true });

// Hàm khởi tạo dữ liệu
const initializeData = async () => {
  try {
    console.log('Initializing data...');
    await eventStore.fetchEvents(true); // Force refresh on initial load
    console.log('Data initialized successfully');
  } catch (err) {
    console.error('Failed to initialize data:', err);
  }
};

// Gọi initializeData khi component được mount
onMounted(async () => {
  console.log('Component mounted');
  await initializeData();
  
  AOS.init({
    duration: 300,
    easing: 'ease-out-cubic',
    once: true,
    mirror: false,
    offset: 50,
    anchorPlacement: 'top-bottom',
    throttleDelay: 0,
    debounceDelay: 0,
    startEvent: 'DOMContentLoaded',
    disable: 'mobile'
  });
});

// Hàm refresh data thủ công
const refreshData = async () => {
  try {
    console.log('Manually refreshing data...');
    await eventStore.fetchEvents(true); // Force refresh
    console.log('Manual refresh completed');
  } catch (err) {
    console.error('Failed to refresh data:', err);
  }
};

// Hàm chuyển đến trang chi tiết
const goToEventDetail = (id) => {
  router.push(`/event/${id}`);
};

const categories = ref([
  { id: 9, name: "Workshop", subtext: "Học tập", icon: BookOpenIcon },
  { id: 10, name: "Âm nhạc", subtext: "Tiết tấu", icon: BookOpenIcon },
  { id:11, name: "Ẩm thực", subtext: "Trải nghiệm", icon: UtensilsIcon },
  { id: 12, name: "Thể thao", subtext: "Sức khỏe", icon: HeartIcon },
  { id: 13, name: "Sở thích", subtext: "Giải trí", icon: BookOpenIcon },
  { id: 14, name: "Hoạt động", subtext: "Cộng đồng", icon: UsersIcon },
  { id: 15, name: "Văn hóa", subtext: "Lễ hội", icon: CalendarIcon },
  { id: 16, name: "Nghề nghiệp", subtext: "Định hướng", icon: BookOpenIcon },
]);

const selectedCategoryId = ref(null);

// Handle category selection
const handleCategorySelect = (categoryId) => {
  // Toggle selection
  selectedCategory.value = selectedCategory.value === categoryId ? null : categoryId;
  // Update store filter with the category ID
  eventStore.setFilter('category', selectedCategory.value);
  // Reset page when changing category
  eventStore.setPage(1);
};

</script>

<style scoped>
/* Base Animations */
@keyframes rotate {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

@keyframes pulse {
    0%, 100% { transform: scale(1) translate(-25%, 25%); opacity: 0.5; }
    50% { transform: scale(1.1) translate(-25%, 25%); opacity: 0.7; }
}

@keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-20px); }
}

/* Flow Animations */
@keyframes flow {
    0% { transform: translateX(-50%); }
    100% { transform: translateX(50%); }
}

/* Enhanced Title Glow */
.glow-text-strong {
    text-shadow: 
        0 0 10px rgba(59, 130, 246, 0.3),
        0 0 20px rgba(59, 130, 246, 0.2),
        0 0 30px rgba(59, 130, 246, 0.1),
        2px 2px 2px rgba(0, 0, 0, 0.1);
    position: relative;
    z-index: 1;
}

/* Title Background Highlight */
h1.glow-text-strong::before {
    content: '';
    position: absolute;
    inset: -10px -20px;
    background: radial-gradient(circle at center, rgba(255, 255, 255, 0.9) 0%, transparent 70%);
    z-index: -1;
    opacity: 0.8;
}

h2.glow-text-strong::before {
    content: '';
    position: absolute;
    inset: -5px -15px;
    background: radial-gradient(circle at center, rgba(255, 255, 255, 0.8) 0%, transparent 70%);
    z-index: -1;
    opacity: 0.7;
}

.shadow-glow-blue-strong {
    box-shadow: 
        0 0 15px rgba(37, 99, 235, 0.4),
        0 0 30px rgba(37, 99, 235, 0.2),
        inset 0 0 10px rgba(37, 99, 235, 0.1);
}

.animate-flow {
    animation: flow 15s linear infinite;
}

.animate-flow-slow {
    animation: flow 20s linear infinite;
}

.animate-flow-slower {
    animation: flow 25s linear infinite;
}

/* Wave Animation */
@keyframes wave {
    0% { transform: translateX(-100%) translateY(0) rotate(0); }
    50% { transform: translateX(0) translateY(-20px) rotate(1deg); }
    100% { transform: translateX(100%) translateY(0) rotate(0); }
}

.wave {
    position: absolute;
    width: 200%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(132, 204, 22, 0.1), transparent);
    animation: wave 8s linear infinite;
}

.wave-delayed {
    animation-delay: -4s;
    opacity: 0.7;
}

.wave-delayed-2 {
    animation-delay: -6s;
    opacity: 0.5;
}

/* Blob Animation */
@keyframes blob {
    0%, 100% {
        transform: translate(0, 0) scale(1);
    }
    25% {
        transform: translate(20px, -20px) scale(1.1);
    }
    50% {
        transform: translate(0, 20px) scale(1);
    }
    75% {
        transform: translate(-20px, -20px) scale(0.9);
    }
}

.animate-blob {
    animation: blob 10s infinite;
}

.animation-delay-2000 {
    animation-delay: 2s;
}

.animation-delay-4000 {
    animation-delay: 4s;
}

@keyframes gradient {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

.animate-gradient {
    background-size: 200% auto;
    animation: gradient 4s linear infinite;
}

/* Particles */
.particles {
    position: absolute;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle at center,
        rgba(255, 255, 255, 0.1) 0%,
        transparent 60%);
    animation: particle-pulse 4s ease-in-out infinite;
}

@keyframes particle-pulse {
    0%, 100% { opacity: 0.3; }
    50% { opacity: 0.7; }
}

.lime-particles {
    background: radial-gradient(circle at center,
        rgba(132, 204, 22, 0.1) 0%,
        transparent 60%);
}

/* Shadow Effects */
.shadow-soft-lime {
    box-shadow: 0 4px 6px -1px rgba(132, 204, 22, 0.1),
                0 2px 4px -1px rgba(132, 204, 22, 0.06);
}

.shadow-glow-lime-strong {
    box-shadow: 
        0 0 15px rgba(132, 204, 22, 0.4),
        0 0 30px rgba(132, 204, 22, 0.2),
        inset 0 0 10px rgba(132, 204, 22, 0.1);
}

/* Text Effects */
.glow-text-strong {
    text-shadow: 
        0 0 10px rgba(132, 204, 22, 0.3),
        0 0 20px rgba(132, 204, 22, 0.2),
        0 0 30px rgba(132, 204, 22, 0.1),
        2px 2px 2px rgba(0, 0, 0, 0.1);
    position: relative;
    z-index: 1;
}

/* Border Animation */
@keyframes border-flow {
    0% { clip-path: inset(0 0 98% 0); }
    25% { clip-path: inset(0 0 0 98%); }
    50% { clip-path: inset(98% 0 0 0); }
    75% { clip-path: inset(0 98% 0 0); }
    100% { clip-path: inset(0 0 98% 0); }
}

.animate-border-flow {
    animation: border-flow 4s linear infinite;
}

/* Input and Button Effects */
input:focus, select:focus {
    transform: translateY(-1px);
    box-shadow: 
        0 0 0 2px rgba(132, 204, 22, 0.1),
        0 0 20px rgba(132, 204, 22, 0.2);
}

input:hover, select:hover {
    transform: translateY(-1px);
}

/* Button Hover Animation */
@keyframes gradient-shift {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
}

button:hover {
    background-size: 200% 200%;
    animation: gradient-shift 3s ease infinite;
}

/* Category Icon Effects */
.category-icon-effect {
    transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.category-icon-effect:hover {
    transform: translateY(-5px) scale(1.1);
    box-shadow: 
        0 0 20px rgba(132, 204, 22, 0.3),
        0 0 40px rgba(132, 204, 22, 0.2);
}

/* Custom Scrollbar */
::-webkit-scrollbar {
    width: 8px;
}

::-webkit-scrollbar-track {
    background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
    background: linear-gradient(to bottom, #84cc16, #65a30d);
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(to bottom, #65a30d, #84cc16);
}

/* Smooth Scrolling */
html {
    scroll-behavior: smooth;
}

/* Add these new styles */
.line-clamp-1 {
    display: -webkit-box;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.rounded-xl {
    border-radius: 0.75rem;
}

/* Add these new animations */
@keyframes spin-slow {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(-360deg);
  }
}

.animate-spin-slow {
  animation: spin-slow 3s linear infinite;
}

.drop-shadow-glow {
  filter: drop-shadow(0 0 8px rgba(132,204,22,0.5));
}
</style>
