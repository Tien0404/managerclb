<template>
    <div class="relative overflow-hidden min-h-screen bg-gradient-to-br from-blue-50 to-cyan-50">
        <!-- Enhanced Dynamic Background with Blob Animations -->
        <div class="absolute inset-0 overflow-hidden">
            <!-- Decorative Blobs -->
            <div class="absolute top-0 left-0 w-64 h-64 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob"></div>
            <div class="absolute top-0 right-0 w-64 h-64 bg-cyan-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-2000"></div>
            <div class="absolute -bottom-8 left-20 w-64 h-64 bg-indigo-200 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-blob animation-delay-4000"></div>

            <!-- Flowing Background Animation -->
            <div class="absolute inset-0">
                <!-- Main Flow -->
                <div class="absolute inset-0 bg-gradient-to-r from-blue-400/20 via-cyan-400/20 to-blue-400/20 animate-flow"></div>
                <!-- Secondary Flows -->
                <div class="absolute inset-0 bg-gradient-to-r from-cyan-300/10 via-blue-400/10 to-cyan-300/10 animate-flow-slow"></div>
                <div class="absolute inset-0 bg-gradient-to-r from-blue-500/10 via-cyan-500/10 to-blue-500/10 animate-flow-slower"></div>
            </div>

            <!-- Enhanced Wave Pattern -->
            <div class="absolute inset-0">
                <div class="wave"></div>
                <div class="wave wave-delayed"></div>
                <div class="wave wave-delayed-2"></div>
            </div>

            <!-- Enhanced Particle Effects -->
            <div class="absolute inset-0">
                <div class="particles blue-particles"></div>
            </div>
        </div>

        <!-- Main Content with Enhanced Animations -->
        <div class="relative z-10">
            <!-- Hero Section with AOS -->
            <div class="max-w-6xl mx-auto px-4 py-8 pt-20 relative">
                <!-- Enhanced Header -->
                <div class="text-center mb-12 relative" data-aos="fade-down">
                    <div class="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-64 h-1 bg-gradient-to-r from-transparent via-blue-400 to-transparent"></div>
                    
                    <h1 class="text-4xl md:text-5xl font-bold mb-4 text-gray-900 relative glow-text-strong animate-gradient">
                        Khám phá 369 Câu Lạc Bộ
                        <div class="absolute top-0 left-0 w-8 h-8 border-t-2 border-l-2 border-blue-400 transform -translate-x-4 -translate-y-4"></div>
                        <div class="absolute top-0 right-0 w-8 h-8 border-t-2 border-r-2 border-blue-400 transform translate-x-4 -translate-y-4"></div>
                    </h1>
                    <h2 class="text-2xl md:text-3xl font-bold text-blue-600 glow-text-strong">
                        phù hợp với bạn!
                    </h2>
                    <div class="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1/2 w-40 h-1 bg-gradient-to-r from-transparent via-blue-400 to-transparent"></div>
                </div>

                <!-- Enhanced Category Icons with AOS -->
                <div class="grid grid-cols-4 md:grid-cols-8 gap-6 mb-12">
    <div
        v-for="(category, index) in categories"
        :key="category.id"
        class="flex flex-col items-center gap-3 group cursor-pointer"
        :data-aos="index % 2 === 0 ? 'fade-right' : 'fade-left'"
        :data-aos-delay="100 * index"
        @click="handleCategoryClick(category.id)"
        :class="{'': selectedCategory === category.id}"
    >
        <div
            class="relative w-16 h-16 rounded-xl border-[3px] border-blue-400 bg-white backdrop-blur-sm flex items-center justify-center transition-all duration-500 group-hover:bg-white group-hover:border-blue-600 group-hover:scale-110 group-hover:shadow-glow-blue-strong overflow-hidden"
        >
            <div class="absolute inset-0 bg-gradient-to-br from-blue-50 to-white opacity-50 group-hover:opacity-100 transition-opacity duration-500"></div>
            <div class="absolute inset-0 border-[3px] border-transparent group-hover:border-blue-500 rounded-xl animate-border-flow"></div>
            
            <component
                :is="category.icon"
                class="w-7 h-7 text-blue-500 group-hover:text-blue-600 transition-all duration-500 transform group-hover:scale-110 relative z-10 stroke-[2.5]"
            />
        </div>
        <span class="text-sm text-center text-gray-900 group-hover:text-blue-500 transition-colors duration-300 font-medium">
            {{ category.name }}
        </span>
    </div>
</div>

                <!-- Enhanced Search and Filter with AOS -->
                <div class="flex flex-col md:flex-row gap-4 mb-8" data-aos="fade-up">
                    <div class="relative flex-1 group">
                        <div class="absolute -inset-0.5 bg-gradient-to-r from-blue-400 to-cyan-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-500"></div>
                        
                        <div class="relative flex items-center">
                            <div class="relative w-full">
                               <!-- Replace your existing search input with this enhanced version -->
<div class="relative flex-1 group">
    <div class="absolute -inset-0.5 bg-gradient-to-r from-blue-400 to-cyan-600 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-500"></div>
    
    <div class="relative flex items-center">
        <div class="relative w-full">
            <input 
                type="text" 
                v-model="searchQuery"
                @input="handleSearchInput"
                placeholder="Tìm kiếm Câu Lạc Bộ"
                class="w-full pl-12 pr-4 py-3 rounded-lg border-[3px] border-blue-300 bg-white backdrop-blur-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all duration-300 shadow-soft-blue hover:shadow-glow-blue-strong text-gray-900 placeholder-gray-500 hover:border-blue-400"
            >
            <SearchIcon class="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-400 group-hover:text-blue-500 transition-colors duration-300" />
        </div>
    </div>
</div>
                            </div>
                        </div>
                    </div>

                    <div class="relative group">
                        <div class="absolute -inset-0.5 bg-gradient-to-r from-cyan-600 to-blue-400 rounded-lg blur opacity-0 group-hover:opacity-50 transition duration-500"></div>
                        
                        <div class="relative">
                            <select
                                v-model="sortBy"
                                @change="handleSort"
                                class="appearance-none w-full pl-4 pr-12 py-3 rounded-lg border-[3px] border-blue-300 bg-white backdrop-blur-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-400/50 transition-all duration-300 shadow-soft-blue hover:shadow-glow-blue-strong cursor-pointer text-gray-900 hover:border-blue-400"
                            >
                                <option value="">Sắp xếp theo</option>
                                <option value="newest">Mới nhất</option>
                                <option value="popular">Phổ biến nhất</option>
                                <option value="name">Tên A-Z</option>
                            </select>
                            <ChevronDownIcon class="absolute right-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-400 group-hover:text-blue-500 transition-colors duration-300 pointer-events-none" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Enhanced Club Cards with AOS -->
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <!-- Loading State -->
                <div v-if="isLoading" class="relative">
                    <div class="absolute inset-0 bg-white/50 backdrop-blur-sm z-10"></div>
                    <div class="absolute inset-0 flex items-center justify-center z-20">
                        <div class="flex flex-col items-center gap-4">
                            <div class="relative">
                                <!-- Outer spinning ring -->
                                <div class="w-16 h-16 border-4 border-blue-200 rounded-full animate-spin-slow"></div>
                                <!-- Inner spinning ring -->
                                <div class="absolute inset-0 w-16 h-16 border-4 border-t-blue-400 border-r-blue-400 border-b-transparent border-l-transparent rounded-full animate-spin"></div>
                                <!-- Glow effect -->
                                <div class="absolute inset-0 w-16 h-16 rounded-full shadow-[0_0_15px_rgba(59,130,246,0.3)] animate-pulse"></div>
                            </div>
                            <div class="text-gray-900 font-medium drop-shadow-glow">Đang tải dữ liệu...</div>
                        </div>
                    </div>
                    <!-- Loading Skeleton Cards -->
                    <div v-for="i in 3" :key="i" class="bg-white/90 backdrop-blur-md rounded-2xl shadow-soft-blue overflow-hidden flex flex-col md:flex-row mb-6 h-[250px] animate-pulse">
                        <!-- Left Content Skeleton -->
                        <div class="pt-6 pr-6 pl-6 pb-4 flex-1 min-w-0">
                            <div class="flex gap-6">
                                <div class="flex-shrink-0">
                                    <div class="w-20 h-20 rounded-xl bg-blue-200"></div>
                                </div>
                                <div class="flex-1">
                                    <div class="w-24 h-6 bg-blue-200 rounded-full mb-2"></div>
                                    <div class="w-3/4 h-8 bg-blue-200 rounded-lg mb-2"></div>
                                    <div class="space-y-2">
                                        <div class="w-full h-4 bg-blue-200 rounded"></div>
                                        <div class="w-2/3 h-4 bg-blue-200 rounded"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Right Image Skeleton -->
                        <div class="w-[400px] h-full bg-blue-200"></div>
                    </div>
                </div>

                <!-- Error State -->
                <div v-else-if="error" class="text-center py-12">
                    <div class="mb-4">
                        <XCircle class="w-16 h-16 text-red-500 mx-auto" />
                    </div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-2">Đã có lỗi xảy ra</h3>
                    <button 
                        @click="refreshData"
                        class="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors duration-300"
                    >
                        Thử lại
                    </button>
                </div>

                <!-- No Data State -->
                <div v-else-if="filteredClubs.length === 0" class="text-center py-12">
                    <div class="mb-4">
                        <InboxIcon class="w-16 h-16 text-blue-500 mx-auto" />
                    </div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-2">Không tìm thấy Câu Lạc Bộ</h3>
                    <p class="text-gray-600">Vui lòng thử lại với các tiêu chí tìm kiếm khác</p>
                </div>

                <!-- Club List -->
                <template v-else>
                    <div
                        v-for="club in filteredClubs"
                        :key="club.id"
                        class="bg-white/90 backdrop-blur-md rounded-2xl shadow-soft-blue hover:shadow-glow-blue overflow-hidden flex flex-col md:flex-row mb-6 transition-all duration-300 hover:scale-[1.02] group h-[250px]"
                        :data-aos="'fade-up'"
                        :data-aos-duration="300"
                        :data-aos-offset="50"
                        :data-aos-once="true"
                        :data-aos-anchor-placement="'top-bottom'"
                    >
                        <!-- Left Content -->
                        <div class="pt-6 pr-6 pl-6 pb-4 flex-1 min-w-0">
                            <div class="flex gap-6">
                                <!-- Logo -->
                                <div class="flex-shrink-0">
                                    <img 
                                        :src="club.background_images[0]?.image_url || 'https://via.placeholder.com/80'" 
                                        alt="Club logo"
                                        class="w-20 h-20 rounded-xl object-cover shadow-soft-blue"
                                    />
                                </div>

                                <!-- Content -->
                                <div class="flex flex-col h-full flex-1">
                                    <div class="flex-1">
                                        <span class="inline-block px-3 py-1 bg-blue-100 text-gray-900 text-sm font-medium rounded-full mb-2">
                                            {{ categories.find(cat => cat.id === club.category_id)?.name || 'Chưa phân loại' }}
                                        </span>
                                        <h2 class="text-2xl font-bold text-gray-900 mb-2 group-hover:text-blue-500 transition-colors duration-300 line-clamp-1">
                                            {{ club.name }}
                                        </h2>
                                        <p class="text-gray-900 text-sm leading-relaxed mb-4 line-clamp-2">
                                            {{ club.description }}
                                        </p>
                                    </div>

                                    <div class="flex items-center gap-4 text-sm text-gray-900">
                                        <div class="flex items-center gap-1">
                                            <MapPinIcon class="w-4 h-4 text-blue-400 flex-shrink-0" />
                                            <span class="truncate">{{ club.province }}</span>
                                        </div>
                                        <div class="flex items-center gap-1">
                                            <UsersIcon class="w-4 h-4 text-blue-400 flex-shrink-0" />
                                            <span class="truncate">{{ club.member_count }} thành viên</span>
                                        </div>
                                    </div>

                                    <router-link 
                                        :to="`/clb/${club.id}`" 
                                        class="mt-4 w-80 py-2.5 text-center border-[3px] border-blue-300 text-gray-900 font-medium rounded-lg shadow-soft-blue hover:shadow-glow-blue-strong hover:bg-gradient-to-r hover:from-blue-500 hover:to-blue-600 hover:text-white hover:border-blue-500 transition-all duration-500 mx-auto block hover:scale-105"
                                    >
                                        Chi tiết
                                    </router-link>
                                </div>
                            </div>
                        </div>

                        <!-- Right Image -->
                        <div class="w-[400px] h-full flex-shrink-0 relative overflow-hidden group-hover:opacity-90 transition-opacity duration-300">
                            <img
                                :src="club.background_images[0]?.image_url"
                                alt="Club background"
                                class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                            />
                        </div>
                    </div>
                </template>

                <!-- Enhanced Load More Button with AOS -->
                <div v-if="filteredClubs.length > 0" class="flex items-center justify-center mt-10 max-w-4xl mx-auto" data-aos="fade-up">
                    <div class="flex-1 h-px bg-gradient-to-r from-transparent via-blue-200 to-transparent"></div>
                    <button 
                        @click="loadMore"
                        :disabled="!hasMoreItems"
                        :class="{'opacity-50 cursor-not-allowed': !hasMoreItems}"
                        class="mx-8 px-8 py-2.5 rounded-lg bg-white/90 backdrop-blur-sm border-[3px] border-blue-300 text-gray-900 hover:text-white hover:border-blue-500 hover:bg-gradient-to-r hover:from-blue-500 hover:to-blue-600 transition-all duration-500 shadow-soft-blue hover:shadow-glow-blue-strong flex items-center justify-center font-medium min-w-[160px] hover:scale-105"
                    >
                        {{ hasMoreItems ? 'Xem Thêm' : 'Đã hiển thị tất cả' }}
                        <ChevronDown class="ml-2 w-4 h-4" :class="hasMoreItems ? 'text-blue-400 group-hover:text-white' : 'text-gray-400'" />
                    </button>
                    <div class="flex-1 h-px bg-gradient-to-r from-transparent via-blue-200 to-transparent"></div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import {
    SearchIcon,
    ChevronDownIcon,
    BookOpenIcon,
    CloudIcon,
    HandshakeIcon,
    GlobeIcon,
    GamepadIcon,
    Palette,
    Megaphone,
    Dumbbell,
    MapPinIcon,
    UsersIcon,
    ChevronDown,
    XCircle,
    InboxIcon
} from 'lucide-vue-next'
import { ref, onMounted, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useClubStore } from "../../stores/clubStore";
import AOS from 'aos'
import 'aos/dist/aos.css'

const clubStore = useClubStore();
const { clubs, isLoading, error } = storeToRefs(clubStore);
const { fetchClubs, setFilter } = clubStore;

// Local state
const searchQuery = ref('');
const sortBy = ref('');
const currentPage = ref(1);
const itemsPerPage = 10;
const selectedCategory = ref(null);

// Computed
const filteredClubs = computed(() => {
    const start = 0;
    const end = currentPage.value * itemsPerPage;
    return clubStore.filteredClubs.slice(start, end);
});

const hasMoreItems = computed(() => {
    return filteredClubs.value.length < clubStore.filteredClubs.length;
});

// Methods
const initializeData = async () => {
    try {
        // Chỉ gọi API khi chưa có data trong store
        if (clubStore.clubs.length === 0) {
            await fetchClubs();
        }
    } catch (err) {
        console.error('Failed to fetch clubs:', err);
    }
};

const refreshData = async () => {
    try {
        await fetchClubs(true); // Force refresh
    } catch (err) {
        console.error('Failed to refresh clubs:', err);
    }
};

const handleSearchInput = () => {
    setFilter('searchQuery', searchQuery.value);
};

const handleSort = () => {
    setFilter('sortBy', sortBy.value);
    currentPage.value = 1;
};

const handleCategoryClick = (categoryId) => {
    // Toggle category selection
    selectedCategory.value = selectedCategory.value === categoryId ? null : categoryId;
    setFilter('category', selectedCategory.value);
    currentPage.value = 1;
};

function filterClubsByCategory(categoryId) {
    filteredClubs.value = clubs.value.filter(club => club.category_id === categoryId);
}   

const loadMore = () => {
    if (hasMoreItems.value) {
        currentPage.value++;
    }
};

onMounted(async () => {
    try {
        await fetchClubs();
        console.log(clubs.value);
    } catch (error) {
        console.error('Error fetching clubs:', error);
    }
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
    })
});

const categories = [
    { id: 1, name: 'Học thuật, Chuyên môn', icon: BookOpenIcon },
    { id: 2, name: 'Nghệ thuật, Sáng tạo', icon: Palette},
    { id: 3, name: 'Truyền thông, Báo trí', icon: Megaphone },
    { id: 4, name: 'Thể thao, Sức khỏe', icon: Dumbbell },
    { id: 5, name: 'Kỹ năng, Giá trị', icon: CloudIcon },
    { id: 6, name: 'Tình nguyện, Cộng đồng', icon: HandshakeIcon },
    { id: 7, name: 'Ngoại ngữ, Văn hóa', icon: GlobeIcon },
    { id: 8, name: 'Thể thao, Giải trí', icon: GamepadIcon },
]
</script>
<style scoped>
.selected-category > div {
    background-color: rgba(59, 130, 246, 0.1);
    border-color: rgb(37, 99, 235);
    transform: scale(1.1);
    box-shadow: 0 0 15px rgba(37, 99, 235, 0.5);
}

.selected-category span {
    color: rgb(37, 99, 235);
}
/* 1. Base Animations */
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

/* 2. Background Grid Pattern */
.bg-grid {
    background-image: 
        linear-gradient(to right, rgba(99, 102, 241, 0.2) 1px, transparent 1px),
        linear-gradient(to bottom, rgba(99, 102, 241, 0.2) 1px, transparent 1px);
    background-size: 50px 50px;
}

/* 3. Gradient Circle Animations */
.animate-rotate-slow {
    animation: rotate 20s linear infinite;
}

.animate-rotate-reverse {
    animation: rotate 25s linear infinite reverse;
}

.animate-pulse-slow {
    animation: pulse 15s ease-in-out infinite;
}

/* 4. Lotus Flower Styling */
.lotus-flower {
    position: absolute;
    width: 60px;
    height: 60px;
    background: radial-gradient(circle at 30% 30%, 
        rgba(255, 182, 193, 0.2) 0%,
        rgba(147, 197, 253, 0.2) 100%);
    clip-path: path('M30,0 C40,10 50,30 30,50 C10,30 20,10 30,0');
    animation: float 8s ease-in-out infinite;
}

.lotus-flower::before,
.lotus-flower::after {
    content: '';
    position: absolute;
    inset: 0;
    background: inherit;
    animation: rotate 10s linear infinite;
}

.lotus-flower::before {
    transform: rotate(60deg);
}

.lotus-flower::after {
    transform: rotate(-60deg);
}

/* 5. Glowing Orbs */
.orb {
    position: absolute;
    width: 15px;
    height: 15px;
    background: radial-gradient(circle at center,
        rgba(255, 255, 255, 0.8) 0%,
        rgba(255, 255, 255, 0) 70%);
    border-radius: 50%;
    animation: float 6s ease-in-out infinite;
}

.orb-delayed-1 {
    animation-delay: -2s;
    left: 25%;
    top: 30%;
}

.orb-delayed-2 {
    animation-delay: -4s;
    right: 35%;
    top: 60%;
}

/* 6. Light Rays */
.light-ray {
    position: absolute;
    top: -100%;
    left: -100%;
    width: 300%;
    height: 300%;
    background: linear-gradient(45deg,
        transparent 0%,
        rgba(255, 255, 255, 0.03) 45%,
        rgba(255, 255, 255, 0.05) 50%,
        rgba(255, 255, 255, 0.03) 55%,
        transparent 100%);
    transform-origin: 0 0;
    animation: rotate 30s linear infinite;
}

.ray-delayed-1 {
    animation-delay: -10s;
    opacity: 0.7;
}

.ray-delayed-2 {
    animation-delay: -20s;
    opacity: 0.5;
}

/* 7. Content Enhancement */
.backdrop-blur {
    backdrop-filter: blur(10px);
}

/* 8. Responsive Adjustments */
@media (max-width: 768px) {
    .lotus-flower {
        transform: scale(0.7);
    }
    
    .orb {
        transform: scale(0.8);
    }
}

/* Enhanced Glow Effects */
.glow-effect {
    filter: drop-shadow(0 0 8px rgba(255, 255, 255, 0.3));
}

.glow-strong {
    filter: drop-shadow(0 0 15px rgba(255, 255, 255, 0.5));
}

.glow-text {
    text-shadow: 0 0 10px rgba(99, 102, 241, 0.3);
}

/* Enhanced Shadows */
.shadow-soft {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
                0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.shadow-glow {
    box-shadow: 0 0 15px rgba(99, 102, 241, 0.3);
}

/* Enhanced Light Ray */
.light-ray.enhanced {
    background: linear-gradient(45deg,
        transparent 0%,
        rgba(255, 255, 255, 0.05) 45%,
        rgba(255, 255, 255, 0.1) 50%,
        rgba(255, 255, 255, 0.05) 55%,
        transparent 100%);
}

/* New Particle System */
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

/* Enhanced Animations */
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

/* Responsive Enhancements */
@media (max-width: 768px) {
    .shadow-glow {
        box-shadow: 0 0 10px rgba(99, 102, 241, 0.2);
    }
    
    .glow-effect {
        filter: drop-shadow(0 0 5px rgba(255, 255, 255, 0.2));
    }
}

/* Blue Shadow Variants */
.shadow-soft-blue {
    box-shadow: 0 4px 6px -1px rgba(59, 130, 246, 0.1),
                0 2px 4px -1px rgba(59, 130, 246, 0.06);
}

.shadow-glow-blue {
    box-shadow: 0 0 15px rgba(59, 130, 246, 0.3);
}

/* Blue Glow Text */
.text-glow-blue {
    text-shadow: 0 0 10px rgba(59, 130, 246, 0.3);
}

/* Enhanced Input Focus */
input:focus::placeholder,
select:focus::placeholder {
    color: rgba(59, 130, 246, 0.5);
}

/* Blue Border Animation */
@keyframes border-pulse-blue {
    0%, 100% { border-color: rgba(59, 130, 246, 0.4); }
    50% { border-color: rgba(59, 130, 246, 0.8); }
}

.animate-border-blue {
    animation: border-pulse-blue 2s ease-in-out infinite;
}

/* Enhanced Text Colors */
.text-gray-900 {
    color: #000000;
}

.text-gray-700 {
    color: #374151;
}

.text-gray-600 {
    color: #4B5563;
}

/* Enhanced Button Alignment */
.min-w-\[160px\] {
    min-width: 160px;
}

/* Update text colors */
input::placeholder {
    color: #6B7280;
}

select option {
    color: #000000;
}

/* New Flow Animations */
@keyframes flow {
    0% { transform: translateX(-50%); }
    100% { transform: translateX(50%); }
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
    background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.1), transparent);
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

/* Blue Particles */
.blue-particles {
    background: radial-gradient(circle at center,
        rgba(59, 130, 246, 0.1) 0%,
        transparent 60%);
}

/* Update existing color classes */
.text-blue-400 {
    color: #60A5FA;
}

.text-blue-500 {
    color: #3B82F6;
}

.border-blue-200 {
    border-color: #BFDBFE;
}

.border-blue-300 {
    border-color: #93C5FD;
}

.border-blue-400 {
    border-color: #60A5FA;
}

.bg-blue-100 {
    background-color: #DBEAFE;
}

/* Update icon container styles */
.group:hover .bg-white {
    background-color: rgba(255, 255, 255, 1);
}

/* Add new white glow effect */
.white-glow {
    box-shadow: 0 0 20px rgba(255, 255, 255, 0.5);
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

/* Enhanced Input and Button Styles */
input:focus, select:focus {
    transform: translateY(-1px);
    box-shadow: 
        0 0 0 2px rgba(59, 130, 246, 0.1),
        0 0 20px rgba(59, 130, 246, 0.2);
}

input:hover, select:hover {
    transform: translateY(-1px);
}

/* Input Focus Animation */
@keyframes input-glow {
    0% { box-shadow: 0 0 5px rgba(37, 99, 235, 0.2); }
    50% { box-shadow: 0 0 20px rgba(37, 99, 235, 0.4); }
    100% { box-shadow: 0 0 5px rgba(37, 99, 235, 0.2); }
}

input:focus, select:focus {
    animation: input-glow 2s ease-in-out infinite;
}

/* Button Click Effect */
button:active {
    transform: scale(0.98);
    transition: transform 0.1s;
    box-shadow: 0 0 5px rgba(37, 99, 235, 0.3);
}

/* Enhanced Animations */
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

/* Enhanced Card Styles */
.card-shadow {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    transition: box-shadow 0.3s ease-in-out;
}

.card-shadow:hover {
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

/* Smooth Scrolling */
html {
    scroll-behavior: smooth;
}

/* Custom Scrollbar */
::-webkit-scrollbar {
    width: 8px;
}

::-webkit-scrollbar-track {
    background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
    background: linear-gradient(to bottom, #3b82f6, #2563eb);
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(to bottom, #2563eb, #3b82f6);
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

/* Add new styles for logo */
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
  filter: drop-shadow(0 0 8px rgba(59,130,246,0.5));
}
</style>
